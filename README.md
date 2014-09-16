[Painting-to-3D Model Alignment](http://www.di.ens.fr/willow/research/painting_to_3d/) source code
============
Here you will find a Matlab implementation of the algorithm described
in the following paper:

Painting-to-3D Model Alignment Via Discriminative Visual Elements; M. Aubry, B. Russell and J. Sivic; ACM Transactions on Graphics, 2014 (presented at SIGGRAPH 2014)
[project webpage](http://www.di.ens.fr/willow/research/painting_to_3d/)

### DOWNLOADING THE DATA

If you want to compute the discriminative elements, you have to download the rendered views and corresponding data [here]().
Alternatively, you can download our pre-computed [discriminative elements](http://www.di.ens.fr/willow/research/paintingTo3D/data/DEs_basilica.tar) and the [3D model]().

### RUNNING THE CODE:

1. Start by compiling the code.  At the Matlab command prompt run:

   ``` sh
   >> compile;
   ```

2. (Optional) [demoSelectDEs.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoSelectDEs.m) is a script that computes the discriminative elements from a set of rendered views of a 3D model and their associated Cameras and 3D points. It must be run before doing detection. 
Alternatively, you can download our pre-computed [discriminative elements](http://www.di.ens.fr/willow/research/paintingTo3D/data/DEs_basilica.tar).

3. [demoAlignPainting.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoAlignPaintings.m) is a script that uses the discriminative elements to recover the camera parameters corresponding to the viewpoint of the painting.
