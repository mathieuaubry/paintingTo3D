// mexWritePly.cpp
// Write to PLY file.

// To compile:
// mex mexWritePly.cpp -I./trimesh2/include -L./trimesh2/lib.Darwin -ltrimesh -lgomp
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
// vertices
// faces
// colors
// normals
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
//   if(nrhs != 3) {
//     mexErrMsgTxt("Error: 3 args. needed.");
//     return;
//   }


  char filename[1000];
  mxGetString(prhs[0],filename,1000);
  float *vertices = (float*)mxGetData(prhs[1]);
  int *faces = (int*)mxGetData(prhs[2]);
  float *colors = 0;
  float *normals = 0;
  if(nrhs>3) colors = (float*)mxGetData(prhs[3]);
  if(nrhs>4) normals = (float*)mxGetData(prhs[4]);

  int Nvertices = mxGetN(prhs[1]);
  int Nfaces = mxGetN(prhs[2]);

  if(filename[0] == '~') {
    char *home = getenv("HOME");
    char tmp[1000]; tmp[0] = '\0';
    strcat(tmp,home);
    strcat(tmp,filename+1);
    strcpy(filename,tmp);
  }

  // Set mesh:
  TriMesh *themesh = new TriMesh();
  themesh->vertices.resize(Nvertices);
  int p = 0;
  for(int i = 0; i < Nvertices; i++) {
    themesh->vertices[i][0] = vertices[p++];
    themesh->vertices[i][1] = vertices[p++];
    themesh->vertices[i][2] = vertices[p++];
  }

  themesh->faces.resize(Nfaces);
  p = 0;
  for(int i = 0; i < Nfaces; i++) {
    themesh->faces[i][0] = faces[p++]-1;
    themesh->faces[i][1] = faces[p++]-1;
    themesh->faces[i][2] = faces[p++]-1;
  }

  if(colors) {
    themesh->colors.resize(Nvertices);
    p = 0;
    for(int i = 0; i < Nvertices; i++) {
      themesh->colors[i][0] = colors[p++];
      themesh->colors[i][1] = colors[p++];
      themesh->colors[i][2] = colors[p++];
    }
  }

  if(normals) {
    themesh->normals.resize(Nvertices);
    p = 0;
    for(int i = 0; i < Nvertices; i++) {
      themesh->normals[i][0] = normals[p++];
      themesh->normals[i][1] = normals[p++];
      themesh->normals[i][2] = normals[p++];
    }

    // Concatenate filename with "norm:":
    char filename2[1000];
    strcpy(filename2,filename);
    strcpy(filename,"norm:");
    strcat(filename,filename2);
  }

  // Write mesh:
  themesh->write(filename);

  // Free memory:
  delete themesh;
}
