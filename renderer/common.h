#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TriMesh.h"
#include "XForm.h"
#include "GLCamera.h"
#include "ICP.h"
#include <GL/glut.h>
#include <string>

using std::string;
using std::vector;
using std::max;
using std::min;
using std::swap;


#define DOF 10.0f
#define MAXDOF 100.0f//5.0f//2.0f//10000.0f

using namespace trimesh;

TriMesh::BSphere global_bsph;

xform global_xf;
GLCamera camera;
TriMesh *themesh;
point viewpos;

float skew = 0.0f;
float focal_x;
float focal_y;
float prin_x;
float prin_y;
int imgWidth;
int imgHeight;
float bg_color[3];// = {1,1,1};

vector<TriMesh *> meshes;
vector<bool> visible;

bool interactive_tool = false;
bool textureMode = false;

void cls();
void setup_lighting(int id);
void draw_mesh(int i);

void ParseCameraFile(char *str,float *mat,int *wht,int *wwid,float *focal_x,float *focal_y,float *prin_x,float *prin_y,float *skew) {
  sscanf(str,"%f %f %f %f %f %f %f %f %f %f %f %f %d %d %f %f %f %f %f %f %f %f",mat,mat+1,mat+2,mat+3,mat+4,mat+5,mat+6,mat+7,mat+8,mat+9,mat+10,mat+11,wht,wwid,focal_x,focal_y,prin_x,prin_y,skew,bg_color,bg_color+1,bg_color+2);
}

// Draw the scene
void redraw_helper()
{
  timestamp t = now();
  
  viewpos = inv(global_xf) * point(0,0,0);
  
  float fardist;
  float neardist;
  
  point scene_center;
  float scene_size;
  if(textureMode) {
    scene_center = global_xf * global_bsph.center;
    scene_size = global_bsph.r;
  }
  else {
    scene_center = global_xf * themesh->bsphere.center;
    scene_size = themesh->bsphere.r;
  }
  
  GLint V[4];
  glGetIntegerv(GL_VIEWPORT, V);
  int width = V[2], height = V[3];
  
  // float surface_depth = camera.GetSurfaceDepth();
  // point surface_point;
  // if (camera.read_depth(width/2, height/2, surface_point))
  //   surface_depth = -surface_point[2];
  
  fardist  = max(-(scene_center[2] - scene_size),
		 scene_size / DOF);
  neardist = max(-(scene_center[2] + scene_size),
		 scene_size / MAXDOF);
  // surface_depth = min(surface_depth, fardist);
  // surface_depth = max(surface_depth, neardist);
  // surface_depth = max(surface_depth, fardist / MAXDOF);
  // camera.SetSurfaceDepth(surface_depth);
  // neardist = max(neardist, surface_depth / DOF);
  
  // fprintf(stdout,"surface depth: %f\n",surface_depth);
  fprintf(stdout,"near/far: (%f,%f)\n\n",neardist,fardist);
  fflush(stdout);
  
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  
  float left = -(prin_x+0.5f)/focal_x*neardist;
  float bottom = -(prin_y+0.5f)/focal_y*neardist;
  float right = ((float)(imgWidth-1)-prin_x+0.5f)/focal_x*neardist;
  float top = ((float)(imgHeight-1)-prin_y+0.5f)/focal_y*neardist;
  
  float mm[16];
  mm[0] = neardist*focal_x; mm[1] = 0; mm[2] = 0; mm[3] = 0;
  mm[4] = neardist*skew; mm[5] = neardist*focal_x; mm[6] = 0; mm[7] = 0;
  mm[8] = 0; mm[9] = 0; mm[10] = focal_x*(neardist+fardist); mm[11] = -focal_x;
  mm[12] = 0; mm[13] = 0; mm[14] = focal_x*neardist*fardist; mm[15] = 0;
  
  glOrtho(left,right,bottom,top,neardist,fardist);	  
  glMultMatrixf(mm);
  
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glPushMatrix();
  glMultMatrixd(global_xf);
  cls();
  for (int i = 0; i < meshes.size(); i++) {
    if (!visible[i])
      continue;
    setup_lighting(i);
    draw_mesh(i);
  }
  
  glPopMatrix();
  
  if(interactive_tool) {
    // For some reason, this line causes problems on Mac Lion
    // when rendering single frame:
    glutSwapBuffers();
  }
}


int Find(int p,int *parents) {
  if(parents[p]==p) return p;
  parents[p] = Find(parents[p],parents);
  return parents[p];
}

void Union(int p,int q,int *parents,int *ranks) {
  int pRoot = Find(p,parents);
  int qRoot = Find(q,parents);
  if(ranks[pRoot] > ranks[qRoot]) parents[qRoot] = pRoot;
  else if(pRoot != qRoot) {
    parents[pRoot] = qRoot;
    if(ranks[pRoot] == ranks[qRoot]) ranks[qRoot]++;
  }
}

void ConnectedComponents(bool *isvisible) {
  float threshFrac = 0.01;

  int Nvertices = themesh->vertices.size();
  int Nfaces = themesh->faces.size();
  int Nmin = Nfaces/1000;

  // Allocate memory:
  int *ranks = (int*)malloc(Nvertices*sizeof(int));
  int *parents = (int*)malloc(Nvertices*sizeof(int));
  int *ranksFull = (int*)malloc(Nvertices*sizeof(int));
  int *parentsFull = (int*)malloc(Nvertices*sizeof(int));

  // Initialize memory:
  for(int i = 0; i < Nvertices; i++) parents[i] = i;
  for(int i = 0; i < Nvertices; i++) ranks[i] = 0;
  for(int i = 0; i < Nvertices; i++) parentsFull[i] = i;
  for(int i = 0; i < Nvertices; i++) ranksFull[i] = 0;
  
  // Merge connected components:
  for(int i = 0; i < Nfaces; i++) {
    int *f = themesh->faces[i];
    
    Union(f[0],f[1],parentsFull,ranksFull);
    Union(f[1],f[2],parentsFull,ranksFull);
    Union(f[2],f[0],parentsFull,ranksFull);

    if(isvisible[i]) {
      Union(f[0],f[1],parents,ranks);
      Union(f[1],f[2],parents,ranks);
      Union(f[2],f[0],parents,ranks);
    }
  }

  // Get final indices for connected components:
  for(int i = 0; i < Nvertices; i++) ranksFull[i] = 0;
  for(int i = 0; i < Nvertices; i++) ranksFull[Find(i,parentsFull)]++;
  for(int i = 0; i < Nvertices; i++) ranks[i] = 0;
  for(int i = 0; i < Nvertices; i++) ranks[Find(i,parents)]++;

  for(int i = 0; i < Nfaces; i++) {
    int f = themesh->faces[i][0];
    if(isvisible[i] && (((float)ranks[parents[f]]/ranksFull[parentsFull[f]])<threshFrac)) isvisible[i] = 0;
//     if(isvisible[i] && (ranks[Find(themesh->faces[i][0],parents)]<Nmin)) isvisible[i] = 0;
  }

  // Free memory:
  free(ranks);
  free(parents);
  free(ranksFull);
  free(parentsFull);
}


// Assume mat is array corresponding to 3x4 matrix:
bool* CollisionHandling(float *mat) {
  // Get camera center:
  float C[3];
  C[0] = -(mat[0]*mat[3]+mat[4]*mat[7]+mat[8]*mat[11]);
  C[1] = -(mat[1]*mat[3]+mat[5]*mat[7]+mat[9]*mat[11]);
  C[2] = -(mat[2]*mat[3]+mat[6]*mat[7]+mat[10]*mat[11]);

//   fprintf(stdout,"\n\nCamera center: (%f,%f,%f)\n\n",C[0],C[1],C[2]);
//   fflush(stdout);

  // Allocate visiblity vector:
  bool *isvisible = (bool*)malloc(themesh->faces.size()*sizeof(bool));
  int *f;

  // Initialize visibility vector:
  for(int i = 0; i < themesh->faces.size(); i++) isvisible[i] = 1;

  // Get points in front of the camera:
  // -r3'*C=pi4
  float PI[4];
  PI[0] = mat[8]; PI[1] = mat[9]; PI[2] = mat[10]; PI[3] = -PI[0]*C[0]-PI[1]*C[1]-PI[2]*C[2];
  for(int i = 0; i < themesh->faces.size(); i++) {
    f = themesh->faces[i];
    int c = 0;
    for(int j = 0; j < 3; j++) {
      float tot = PI[3];
      for(int k = 0; k < 3; k++) tot += themesh->vertices[f[j]][k]*PI[k];
      if(tot>=0) c++;
    }
    if(c==3) isvisible[i] = 0;
  }

  // Compute face visibility using normal and direction to camera center:
  float n[3];
  float a[3];
  float b[3];
  float camdir[3];
  for(int i = 0; i < themesh->faces.size(); i++) {
    // Get two vectors for face:
    f = themesh->faces[i];
    a[0] = themesh->vertices[f[1]][0]-themesh->vertices[f[0]][0];
    a[1] = themesh->vertices[f[1]][1]-themesh->vertices[f[0]][1];
    a[2] = themesh->vertices[f[1]][2]-themesh->vertices[f[0]][2];
    b[0] = themesh->vertices[f[2]][0]-themesh->vertices[f[0]][0];
    b[1] = themesh->vertices[f[2]][1]-themesh->vertices[f[0]][1];
    b[2] = themesh->vertices[f[2]][2]-themesh->vertices[f[0]][2];

    // Get camera direction:
    camdir[0] = C[0]-themesh->vertices[f[0]][0];
    camdir[1] = C[1]-themesh->vertices[f[0]][1];
    camdir[2] = C[2]-themesh->vertices[f[0]][2];

    // Compute cross product to get normal direction:
    n[0] = a[1]*b[2]-a[2]*b[1];
    n[1] = a[2]*b[0]-a[0]*b[2];
    n[2] = a[0]*b[1]-a[1]*b[0];

    // Compute dot product:
    if(n[0]*camdir[0]+n[1]*camdir[1]+n[2]*camdir[2] <= 0) isvisible[i] = 0;
  }

  // Remove small connected components:
  ConnectedComponents(isvisible);

  return isvisible;
}

void RemoveNonVisibleFaces(bool *isvisible) {
  // Remove faces that are not visible in mesh:
  int tot = 0;
  for(int i = 0; i < themesh->faces.size(); i++) {
    if(isvisible[i]) {
      for(int j = 0; j < 3; j++) {
	themesh->faces[tot][j] = themesh->faces[i][j];
      }
      tot++;
    }
  }
  themesh->faces.resize(tot);

  return;
}


#endif
