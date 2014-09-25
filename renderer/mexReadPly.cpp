// mexReadPly.cpp
// Read PLY file.

// To compile:
// mex mexReadPly.cpp -I./trimesh2/include -L./trimesh2/lib.Darwin -ltrimesh -lgomp
// mex mexReadPly.cpp -I./trimesh2/include -L./trimesh2/lib.Linux64 -ltrimesh -lgomp
//
// Make sure that
// COPTS += -m32
// is set in "Makedefs.SYSTEM" file.

#include <cstring>
#include <cstdlib>

#include "TriMesh.h"
#include "mex.h"

using namespace trimesh;

// Inputs:
// filename
//
// Outputs:
// vertices
// faces
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
  if(nrhs != 1) {
    mexErrMsgTxt("Error: 1 args. needed.");
    return;
  }

  char filename[1000];
  mxGetString(prhs[0],filename,1000);

  if(filename[0] == '~') {
    char *home = getenv("HOME");
    char tmp[1000]; tmp[0] = '\0';
    strcat(tmp,home);
    strcat(tmp,filename+1);
    strcpy(filename,tmp);
  }

  // Read mesh:
  TriMesh *themesh = TriMesh::read(filename);

  // Check mesh:
  if (!themesh) {
    mexErrMsgTxt("Could not read PLY file");
    return;
  }

  // Get mesh size:
  int Nvertices = themesh->vertices.size();
  int Nfaces = themesh->faces.size();

  // Allocate outputs:
  plhs[0] = mxCreateNumericMatrix(3,Nvertices,mxSINGLE_CLASS,mxREAL);
  float *vertices = (float*)mxGetData(plhs[0]);
  plhs[1] = mxCreateNumericMatrix(3,Nfaces,mxINT32_CLASS,mxREAL);
  int *faces = (int*)mxGetData(plhs[1]);
  float *colors;
  float *normals;
  if(nlhs>=3) {
    plhs[2] = mxCreateNumericMatrix(3,Nvertices,mxSINGLE_CLASS,mxREAL);
    colors = (float*)mxGetData(plhs[2]);
  }
  if(nlhs>=4) {
    plhs[3] = mxCreateNumericMatrix(3,Nvertices,mxSINGLE_CLASS,mxREAL);
    normals = (float*)mxGetData(plhs[3]);
  }

  int p = 0;
  for(int i = 0; i < Nvertices; i++) {
    vertices[p++] = themesh->vertices[i][0];
    vertices[p++] = themesh->vertices[i][1];
    vertices[p++] = themesh->vertices[i][2];
  }

  p = 0;
  for(int i = 0; i < Nfaces; i++) {
    faces[p++] = themesh->faces[i][0]+1;
    faces[p++] = themesh->faces[i][1]+1;
    faces[p++] = themesh->faces[i][2]+1;
  }

  if(nlhs>=3) {
    p = 0;
    for(int i = 0; i < Nvertices; i++) {
      colors[p++] = themesh->colors[i][0];
      colors[p++] = themesh->colors[i][1];
      colors[p++] = themesh->colors[i][2];
    }
  }

  if(nlhs>=4) {
    p = 0;
    for(int i = 0; i < Nvertices; i++) {
      normals[p++] = themesh->normals[i][0];
      normals[p++] = themesh->normals[i][1];
      normals[p++] = themesh->normals[i][2];
    }
  }

  // Free memory:
  delete themesh;
}
