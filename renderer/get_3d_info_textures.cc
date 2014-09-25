#include "common.h"
#include "common_jpeg.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

vector<xform> xforms;
vector<string> xffilenames;

// TriMesh::BSphere global_bsph;
int current_mesh = -1;

bool draw_edges = false;
bool draw_2side = false;//true;//false;
bool draw_shiny = true;
bool draw_lit = true;
bool draw_falsecolor = false;
bool draw_index = false;
bool white_bg = false;

bool useInputCamera = 1;

char out_png_fname[1000];
char out_png_render[1000];
// const char *out_png_fname;
// const char *out_png_render;

int Ntextures = 0;
const char *modelFolder;
GLuint *texture;
float **textureCoords;
bool *is_depth_mesh;
int NtotalFaces = 0;

void redraw() {
  redraw_helper();
}

// Signal a redraw
void need_redraw()
{
	glutPostRedisplay();
}


// Clear the screen
void cls()
{
	glDisable(GL_DITHER);
	glDisable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_NORMALIZE);
	glDisable(GL_LIGHTING);
	glDisable(GL_NORMALIZE);
	glDisable(GL_COLOR_MATERIAL);
// 	glEnable(GL_POLYGON_SMOOTH);

// 	glDisable(GL_MULTISAMPLE);
// 	glDisable(GL_POLYGON_SMOOTH);

	if(white_bg) {
	  glClearColor(bg_color[0], bg_color[1], bg_color[2], 0); // White background
//	  glClearColor(1, 1, 1, 0); // White background
	}
	else {
	  glClearColor(0, 0, 0, 0); // Black background
// 	glClearColor(0.08, 0.08, 0.08, 0);
	}

	glClearDepth(1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

}

// Set up lights and materials
void setup_lighting_orig(int id)
{
	Color c(1.0f);
	if (draw_falsecolor)
		c = Color::hsv(-3.88 * id, 0.6 + 0.2 * sin(0.42 * id), 1.0);
	glColor3fv(c);

	if (!draw_lit || meshes[id]->normals.empty()) {
		glDisable(GL_LIGHTING);
		return;
	}

	GLfloat mat_specular[4] = { 0.18, 0.18, 0.18, 0.18 };
	if (!draw_shiny) {
		mat_specular[0] = mat_specular[1] =
		mat_specular[2] = mat_specular[3] = 0.0f;
	}
	GLfloat mat_shininess[] = { 64 };
	GLfloat global_ambient[] = { 0.02, 0.02, 0.05, 0.05 };
	GLfloat light0_ambient[] = { 0.2, 0.2, 0.2, 0.2 };
	GLfloat light0_diffuse[] = { 0.85, 0.85, 0.8, 0.85 };
	GLfloat light1_diffuse[] = { -0.01, -0.01, -0.03, -0.03 };
	GLfloat light0_specular[] = { 0.85, 0.85, 0.85, 0.85 };
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
	glLightfv(GL_LIGHT0, GL_AMBIENT, light0_ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light0_diffuse);
	glLightfv(GL_LIGHT0, GL_SPECULAR, light0_specular);
	glLightfv(GL_LIGHT1, GL_DIFFUSE, light1_diffuse);

	// TO DO: Change light position to live above camera:
	GLfloat light0_position[] = {1.0f, 1.0f, 1.0f, 1.0f};
	glLightfv(GL_LIGHT0, GL_POSITION, light0_position);

	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient);
	glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_FALSE);
	glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, draw_2side);
	glDisable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_LIGHT1);
	glEnable(GL_COLOR_MATERIAL);
	glEnable(GL_NORMALIZE);
}

// Set up lights and materials
void setup_lighting(int id)
{
//   glDisable(GL_LIGHTING);
//   return;

  if(textureMode && visible[id] && !is_depth_mesh[id]) {
    setup_lighting_orig(id);
  }
  else {
    glDisable(GL_LIGHT0);
    glDisable(GL_LIGHT1);
    glDisable(GL_COLOR_MATERIAL);
    glDisable(GL_NORMALIZE);
  }
}


// Draw triangle strips.  They are stored as length followed by values.
void draw_tstrips(const TriMesh *themesh)
{
	static bool use_glArrayElement = false;
	static bool tested_renderer = false;
	if (!tested_renderer) {
		use_glArrayElement = !!strstr(
			(const char *) glGetString(GL_RENDERER), "Intel");
		tested_renderer = true;
	}

	const int *t = &themesh->tstrips[0];
	const int *end = t + themesh->tstrips.size();
	if (use_glArrayElement) {
		while (likely(t < end)) {
			glBegin(GL_TRIANGLE_STRIP);
			int striplen = *t++;
			for (int i = 0; i < striplen; i++)
				glArrayElement(*t++);
			glEnd();
		}
	} else {
		while (likely(t < end)) {
			int striplen = *t++;
			glDrawElements(GL_TRIANGLE_STRIP, striplen, GL_UNSIGNED_INT, t);
			t += striplen;
		}
	}
}


// Draw the mesh
void draw_mesh(int i)
{
	const TriMesh *themesh = meshes[i];

	glPushMatrix();
	glMultMatrixd(xforms[i]);

	glDepthFunc(GL_LESS);
	glEnable(GL_DEPTH_TEST);

	if (draw_2side) {
		glDisable(GL_CULL_FACE);
	} else {
		glCullFace(GL_BACK);
		glEnable(GL_CULL_FACE);
	}

	// Vertices
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT,
			sizeof(themesh->vertices[0]),
			&themesh->vertices[0][0]);

	// Normals
	if (!themesh->normals.empty() && !draw_index) {
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer(GL_FLOAT,
				sizeof(themesh->normals[0]),
				&themesh->normals[0][0]);
	} else {
		glDisableClientState(GL_NORMAL_ARRAY);
	}

	// Colors
	if (!themesh->colors.empty() && !draw_falsecolor && !draw_index) {
		glEnableClientState(GL_COLOR_ARRAY);
		glColorPointer(3, GL_FLOAT,
			       sizeof(themesh->colors[0]),
			       &themesh->colors[0][0]);
	} else {
		glDisableClientState(GL_COLOR_ARRAY);
	}

	/***********************************************/
	/***********************************************/
	/***********************************************/

	if(textureMode && visible[i] && !is_depth_mesh[i]) {
	  glEnable( GL_TEXTURE_2D );
// 	  bool wrap = true;

// 	  // select modulate to mix texture with color for shading
// 	  glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	  
// 	  // when texture area is small, bilinear filter the closest mipmap
// 	  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
// 			   GL_LINEAR_MIPMAP_NEAREST );
// 	  // when texture area is large, bilinear filter the first mipmap
// 	  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	  
// 	  // if wrap is true, the texture wraps over at the edges (repeat)
// 	  //       ... false, the texture ends at the edges (clamp)
// 	  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
// 			   wrap ? GL_REPEAT : GL_CLAMP );
// 	  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
// 			   wrap ? GL_REPEAT : GL_CLAMP );

	  // select our current texture
	  glBindTexture( GL_TEXTURE_2D, texture[i/2] );
	  
	  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	  glTexCoordPointer(2, GL_FLOAT, 0, textureCoords[i/2]);
	}
	else {
	  glDisable( GL_TEXTURE_2D );
	}

	/***********************************************/
	/***********************************************/
	/***********************************************/

	// Main drawing pass
	if (themesh->tstrips.empty()) {
		// No triangles - draw as points
		glPointSize(1);
		glDrawArrays(GL_POINTS, 0, themesh->vertices.size());
		glPopMatrix();
		return;
	}

	draw_tstrips(themesh);
	glDisable(GL_POLYGON_OFFSET_FILL);

	glPopMatrix();
}

// Update global bounding sphere.
void update_bsph()
{
  fprintf(stdout,"***Updating bsphere...\n");
  fflush(stdout);

	point boxmin(1e38, 1e38, 1e38);
	point boxmax(-1e38, -1e38, -1e38);
	bool some_vis = false;
	for (int i = 0; i < meshes.size(); i++) {
		if (!visible[i])	
			continue;
		some_vis = true;
		point c = xforms[i] * meshes[i]->bsphere.center;
		float r = meshes[i]->bsphere.r;
		for (int j = 0; j < 3; j++) {
			boxmin[j] = min(boxmin[j], c[j]-r);
			boxmax[j] = max(boxmax[j], c[j]+r);
		}
	}
	if (!some_vis)
		return;
	point &gc = global_bsph.center;
	float &gr = global_bsph.r;
	gc = 0.5f * (boxmin + boxmax);
	gr = 0.0f;
	for (int i = 0; i < meshes.size(); i++) {
		if (!visible[i])	
			continue;
		point c = xforms[i] * meshes[i]->bsphere.center;
		float r = meshes[i]->bsphere.r;
		gr = max(gr, dist(c, gc) + r);
	}
}


// Set the view...
void resetview()
{
	update_bsph();
	global_xf = xform::trans(0, 0, -5.0f * global_bsph.r) *
		    xform::trans(-global_bsph.center);

	camera.stopspin();
	if(!useInputCamera) {
	for (int i = 0; i < meshes.size(); i++)
		if (!xforms[i].read(xffilenames[i]))
			xforms[i] = xform();

	update_bsph();
	global_xf = xform::trans(0, 0, -5.0f * global_bsph.r) *
		    xform::trans(-global_bsph.center);

	// Special case for 1 mesh
	if (meshes.size() == 1 && xforms[0].read(xffilenames[0])) {
		global_xf = xforms[0];
		xforms[0] = xform();
		update_bsph();
	}
	}
}

// Idle callback
void idle()
{
	xform tmp_xf = global_xf;
	if (current_mesh >= 0)
		tmp_xf = global_xf * xforms[current_mesh];

	if (camera.autospin(tmp_xf))
		need_redraw();
	else
		usleep(10000);

	if (current_mesh >= 0) {
		xforms[current_mesh] = inv(global_xf) * tmp_xf;
		update_bsph();
	} else {
		global_xf = tmp_xf;
	}
}

// Save the current image to a PPM file
void dump_image(const char *out_png_fname)
{
  FILE *f = fopen(out_png_fname, "wb");
  printf("\n\nSaving image %s... ", out_png_fname);
  fflush(stdout);

  // Read pixels
//   GLUI_Master.auto_set_viewport();
  GLint V[4];
  glGetIntegerv(GL_VIEWPORT, V);
  GLint width = V[2], height = V[3];
  glPixelStorei(GL_PACK_ALIGNMENT, 1);
  
  char *buf = new char[width*height*3];
  glReadPixels(V[0], V[1], width, height, GL_RGB, GL_UNSIGNED_BYTE, buf);
  
  // Flip top-to-bottom
  for (int i = 0; i < height/2; i++) {
    char *row1 = buf + 3 * width * i;
    char *row2 = buf + 3 * width * (height - 1 - i);
    for (int j = 0; j < 3 * width; j++)
      swap(row1[j], row2[j]);
  }
  
  // Write out file
  fprintf(f, "P6\n%d %d\n255\n", width, height);
  fwrite(buf, width*height*3, 1, f);
  fclose(f);
  delete [] buf;
  
  printf("Done.\n\n");
}

void ParsePointsFile(FILE *FP,float *x,float *y,int N) {
  for(int i = 0; i < N; i++) fscanf(FP,"%f %f ",x+i,y+i);
}

void StoreFaceIndicesAsColors(int start_val) {
  // Allocate temporary memory:
  int Nvertices = themesh->vertices.size();
  int Nfaces = themesh->faces.size();
  float *tverts = (float*)malloc(3*themesh->vertices.size()*sizeof(float));

  // Copy vertices into temporary memory:
  for(int i = 0; i < themesh->vertices.size(); i++) {
    for(int j = 0; j < 3; j++) {
      tverts[j+i*3] = themesh->vertices[i][j];
    }
  }

  // Duplicate vertices for each face:
  themesh->vertices.resize(3*Nfaces);
  themesh->colors.resize(3*Nfaces);
  int f;
  int r,g,b;
  int ndx;
  for(int i = 0; i < Nfaces; i++) {
    for(int j = 0; j < 3; j++) {
      // Get vertex index:
      f = themesh->faces[i][j];
      
      // Copy vertex into updated mesh:
      for(int k = 0; k < 3; k++) {
	themesh->vertices[j+i*3][k] = tverts[k+f*3];
      }

      // Get colors for face (only 256^3 faces allowed):
      ndx = i+1 + start_val;
      r = ndx%256;
      g = ((ndx-r)/256)%256;
      b = (((ndx-r)/256)-g)/256;
      
      // Set face colors:
      themesh->colors[j+i*3][0] = ((float)r)/255;
      themesh->colors[j+i*3][1] = ((float)g)/255;
      themesh->colors[j+i*3][2] = ((float)b)/255;

      // Update face index:
      themesh->faces[i][j] = j+3*i;
    }
  }

  // Free temporary memory:
  free(tverts);
}

int GetStr(char *str,char *str_out) {
  int pp = 0;
  while(str[pp]!=' ') {
    str_out[pp] = str[pp];
    pp++;
  }
  str_out[pp] = 0;
  return pp+1;
}

void usage(const char *myname)
{
	fprintf(stderr, "Usage: %s out_png mesh_name cam_file out_png_render (points_file)\n", myname);
	exit(1);
}


bool ProcessMesh(const char *mesh_fname,char *cam_fname,char *readbuf,const char *pipe_fname,const char *log_name) {
  // Variables:
  float mat[12];
  char cam_info[1000];
  FILE *FP;

  // Get camera information:
  FP = fopen(cam_fname,"r");
  if(FP) {
    if(!fgets(cam_info,1000,FP)) {
      FILE *fp_out = fopen(log_name,"w");
      fprintf(fp_out,"Problem with fgets: %s\nreadbuf: %s\n\n",cam_fname,readbuf);
      fclose(fp_out);
      exit(0);
    }
    fclose(FP);
  }
  else {
    FILE *fp_out = fopen(log_name,"w");
    fprintf(fp_out,"Could not open: %s\nreadbuf: %s\n\n",cam_fname,readbuf);
    fclose(fp_out);
    exit(0);
  }

  // Parse camera parameters for first camera (to get window size):
  int ww, hh;
  ParseCameraFile(cam_info,mat,&hh,&ww,&focal_x,&focal_y,&prin_x,&prin_y,&skew);

  if((ww!=imgWidth) || (hh!=imgHeight)) {
    FILE *fp_out = fopen(pipe_fname,"w");
    fprintf(fp_out,"ERROR: image dimensions do not match window dimensions");
    fclose(fp_out);
    return false;
  }

  // Set window size and initial viewpoint:
  global_xf = xform(mat[0],mat[4],mat[8],0,mat[1],mat[5],mat[9],0,mat[2],mat[6],mat[10],0,mat[3],mat[7],mat[11],1);

  
  /***********************************************/
  // Perform drawing for depth values:
  for(int i = 0; i < meshes.size(); i++) {
    if(is_depth_mesh[i]) visible[i] = true;
    else visible[i] = false;
  }
  white_bg = false;
  redraw();
  dump_image(out_png_fname);
  /***********************************************/


  /***********************************************/
  // Perform drawing for colored mesh:
  for(int i = 0; i < meshes.size(); i++) {
    if(!is_depth_mesh[i]) visible[i] = true;
    else visible[i] = false;
  }
  white_bg = true;
  redraw();
  dump_image(out_png_render);
  /***********************************************/

  return true;
}

void LoadModel(const char *mesh_fname,char *argv[]) {
  string xffilename = xfname(mesh_fname);

  // Read mesh:
  themesh = TriMesh::read(mesh_fname);
  if (!themesh) usage(argv[0]);
  themesh->need_normals();
  themesh->need_tstrips();
  themesh->need_bsphere();

  meshes.push_back(themesh);
  xffilenames.push_back(xffilename);
  xforms.push_back(xform());
  visible.push_back(false);

  // Make copy of mesh with "colored" vertices (for depth computations):
  themesh = TriMesh::read(mesh_fname);
  int nn = themesh->faces.size();
  StoreFaceIndicesAsColors(NtotalFaces);
  NtotalFaces += nn;
  themesh->need_normals();
  themesh->need_tstrips();
  themesh->need_bsphere();
  meshes.push_back(themesh);
  xffilenames.push_back(xffilename);
  xforms.push_back(xform());
  visible.push_back(false);
}


void LoadTextures() {
  fprintf(stdout,"Loading textures...\n");
  fflush(stdout);

  textureCoords = (float**)malloc(Ntextures*sizeof(float*));

  // Read texture coordinates:
  char filename[1000];
  for(int i = 0; i < Ntextures; i++) {
    sprintf(filename,"%s/texture_coords_%04d.bin",modelFolder,i);
    FILE *FP = fopen(filename,"r");
    int Nfaces;
    fread(&Nfaces,sizeof(int),1,FP);
    textureCoords[i] = (float*)malloc(2*Nfaces*sizeof(float));
    fread(textureCoords[i],sizeof(float),2*Nfaces,FP);
    fclose(FP);
  }


  bool wrap = true;
  
  glEnable( GL_TEXTURE_2D );
  
  // select modulate to mix texture with color for shading
  glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
  
  // when texture area is small, bilinear filter the closest mipmap
  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
		   GL_LINEAR_MIPMAP_NEAREST );
  // when texture area is large, bilinear filter the first mipmap
  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
  
  // if wrap is true, the texture wraps over at the edges (repeat)
  //       ... false, the texture ends at the edges (clamp)
  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
		   wrap ? GL_REPEAT : GL_CLAMP );
  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
		   wrap ? GL_REPEAT : GL_CLAMP );
  
  // allocate a texture name
  texture = new GLuint[Ntextures];
  glGenTextures( Ntextures, texture );

  for(int i = 0; i < Ntextures; i++) {
    // Read in textures:
    char infilename[1000];
    sprintf(infilename,"%s/textures/img_%04d.jpg",modelFolder,i);
    unsigned char *image_buf;
    int width, height;
    read_JPEG_file(infilename,&image_buf,&width,&height);

    // Flip image top-to-bottom
    for (int ii = 0; ii < height/2; ii++) {
      unsigned char *row1 = image_buf + 3 * width * ii;
      unsigned char *row2 = image_buf + 3 * width * (height - 1 - ii);
      for (int j = 0; j < 3 * width; j++)
	swap(row1[j], row2[j]);
    }
    
//     write_JPEG_file("./nacho.jpg",100,image_buf,width,height);
    
    // select our current texture
    glBindTexture( GL_TEXTURE_2D, texture[i] );
    
    // build our texture mipmaps
    gluBuild2DMipmaps( GL_TEXTURE_2D, 3, width, height,
		       GL_RGB, GL_UNSIGNED_BYTE, image_buf );
    
    delete [] image_buf;
  }
}


// Old inputs:
// OUT_PNG_FILE_NAME
// MESH_NAME
// CAM_FILE (P)
// OUT_PNG_RENDER
// POINTS_FILE (x,y)

// Inputs:
// MESH_NAME
// PIPE_NAME
int main(int argc, char *argv[]) {
  if (argc < 3) usage(argv[0]);

  if(strcmp(argv[argc-2],"--texture")==0) {
    textureMode = true;
    Ntextures = atoi(argv[argc-1]);
    argc -= 2;
  }

  if (argc < 3) usage(argv[0]);

  fprintf(stdout,"Starting OpenGL server.\n\n");
  fflush(stdout);

  const char *mesh_fname = argv[1];
  const char *pipe_fname = argv[2];

  /***********************************************/
  if(textureMode) {
    modelFolder = argv[1];
    char filename[1000];
    is_depth_mesh = (bool*)malloc(2*Ntextures*sizeof(bool));
    for(int i = 0; i < Ntextures; i++) {
      fprintf(stdout,"Loading mesh %d\n",i);
      fflush(stdout);

      sprintf(filename,"%s/model_%04d.ply",modelFolder,i);
      LoadModel(filename,argv);
      is_depth_mesh[2*i] = false;
      is_depth_mesh[2*i+1] = true;
    }
  }
  else {
    LoadModel(mesh_fname,argv);
    is_depth_mesh = (bool*)malloc(2*sizeof(bool));
    is_depth_mesh[0] = false;
    is_depth_mesh[1] = true;
  }
  /***********************************************/

  // Get window dimensions:
  imgHeight = atoi(argv[3]);//118;
  imgWidth = atoi(argv[4]);//113;

  // Get log file name:
  const char *log_name = argv[5];

  glutInitWindowSize(imgWidth,imgHeight);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
  glutInit(&argc, argv);

  glutCreateWindow(argv[2]);
  glutDisplayFunc(redraw);
//   glutMouseFunc(mousebuttonfunc);
//   glutMotionFunc(mousemotionfunc);
//   glutKeyboardFunc(keyboardfunc);
  glutIdleFunc(idle);

  // Make all meshes visible for global bounding sphere computation:
  for(int i = 0; i < meshes.size(); i++) visible[i] = true;
  resetview();
  for(int i = 0; i < meshes.size(); i++) visible[i] = false;


  // Load textures:
  if(textureMode) {
    LoadTextures();
  }

  FILE *fp_pipe;
  char readbuf[1000];
  bool loop_wait = true;
  while(loop_wait) {
    fp_pipe = fopen(pipe_fname,"r");
    if(fp_pipe != NULL) {
      if(fgets(readbuf,1000,fp_pipe)) {
	if(strstr(readbuf,"END")) {
	  // Parse input string:
	  char cam_fname[1000];
	  int len = 0;
	  len += GetStr(readbuf+len,cam_fname);
	  len += GetStr(readbuf+len,out_png_fname);
	  len += GetStr(readbuf+len,out_png_render);
	  
// 	FILE *fp_out = fopen(log_name,"w");
// 	fprintf(fp_out,"Received string: %s\n",readbuf);
// 	fprintf(fp_out,"Parsed string: %s %s %s\n",cam_fname,out_png_fname,out_png_render);
// 	fclose(fp_out);

	  // Process mesh:
	  if(ProcessMesh(mesh_fname,cam_fname,readbuf,pipe_fname,log_name)) {
	    // Write output message to pipe:
	    fp_pipe = fopen(pipe_fname,"w");
	    fprintf(fp_pipe,"SERVER_DONE");
	    fclose(fp_pipe);
	  }
	}
	else if(strstr(readbuf,"EXIT_SERVER")) {
	  loop_wait = false;
	  
	  // Write output message to pipe:
	  fp_pipe = fopen(pipe_fname,"w");
	  fprintf(fp_pipe,"SERVER_STOPPED");
	  fclose(fp_pipe);
	}
      }
      fclose(fp_pipe);
    }
  }

  fprintf(stdout,"Stopping OpenGL server.\n\n");
  fflush(stdout);

  exit(0);

  return 0;
}
