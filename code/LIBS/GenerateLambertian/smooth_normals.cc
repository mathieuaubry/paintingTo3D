#include "TriMesh.h"
#include "TriMesh_algo.h"

void usage(const char *myname) {
  fprintf(stderr, "Usage: %s infile outfile [sigma]\n", myname);
  exit(1);
}

int main(int argc, char *argv[]) {
  if(argc<3) usage(argv[0]);

  // Get arguments:
  const char *inFilename = argv[1];
  const char *outFilename = argv[2];
  float sigma = 1.0f;
  if(argc>=4) sigma = atof(argv[3]);

  // Read mesh:
  TriMesh *themesh = TriMesh::read(inFilename);
  if (!themesh) usage(argv[0]);

  themesh->need_tstrips();
  themesh->need_bsphere();
  themesh->need_normals();
  float currsmooth = 0.5f * themesh->feature_size();

  // Adjust smoothing parameter:
  currsmooth *= sigma;

  // Smooth normals:  
  diffuse_normals(themesh, currsmooth);

  
  // Replace vertices with smoothed normals:
  for(int i = 0; i < themesh->vertices.size(); i++) {
    themesh->vertices[i][0] = themesh->normals[i][0];
    themesh->vertices[i][1] = themesh->normals[i][1];
    themesh->vertices[i][2] = themesh->normals[i][2];
  }

  // Write mesh:
  themesh->faces.clear();
  themesh->write(outFilename);

  // Free memory:
  delete themesh;

  fprintf(stdout,"\n");
  fflush(stdout);

  return 0;
}
