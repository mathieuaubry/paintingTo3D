[Painting-to-3D Model Alignment](http://www.di.ens.fr/willow/research/painting_to_3d/) source code
============
Here you will find a Matlab implementation of the algorithm described
in the following paper:

Mathieu Aubry, Bryan C. Russell and Josef Sivic
Painting-to-3D Model Alignment Via Discriminative Visual Elements
ACM Transactions on Graphics, 2014 (presented at SIGGRAPH 2014)
[PDF]() | [bibtex]() | [project webpage](http://www.di.ens.fr/willow/research/painting_to_3d/)

### DOWNLOADING THE DATA

If you want to use one of our models, you have to download the rendered views and corresponding data for the 3D model you want to use:
- [CAD model of San Marco Basilica](http://www.di.ens.fr/willow/research/painting_to_3d/data/cache_san_marco_basilica.tar). The original 3D model is available [here](http://sketchup.google.com/3dwarehouse/details?mid=433bfb7d61901dc65822c6ca7b1d5d61&prevstart=0).
- [CAD model of Notre Dame](). The original 3D model is available [here](https://3dwarehouse.sketchup.com/model.html?redirect=1&mid=69d9e3c4f1e6359cc45a0a86a468dd45&prevstart=72).
- [CAD model of Trevi fountain](). The original 3D model is available [here](https://3dwarehouse.sketchup.com/model.html?redirect=1&mid=db52a9472001b79b43babf42c8cb195).
- [PMVS model of san marco square](). The original 3D model is available [here]().


Alternatively, you can use the code available [here](http://github.com/brussell123/3drr2011) to generate the needed data for your own 3D model.

Additionnaly, you can download our pre-computed discriminative elements for:
- [CAD model of San Marco Basilica](http://www.di.ens.fr/willow/research/painting_to_3d/data/all_DEs_san_marco_basilica.mat).
- [CAD model of Notre Dame]().
- [CAD model of Trevi fountain]().
- [PMVS model of san marco square]().


The paintings we used to test our method are available [here](http://www.di.ens.fr/willow/research/painting_to_3d/data/Paintings.zip) (40MB)
### RUNNING THE CODE:

1. Start by compiling the code.  At the Matlab command prompt run:

   ``` sh
   >> compile;
   ```

2. (Optional) [demoSelectDEs.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoSelectDEs.m) is a script that computes the discriminative elements from a set of rendered views of a 3D model and their associated Cameras and 3D points. It must be run before doing detection. 
Alternatively, you can download our pre-computed discriminative elements (see DOWNLOAD THE DATAsection).

3. [demoAlignPainting.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoAlignPaintings.m) is a script that uses the discriminative elements to recover the camera parameters corresponding to the viewpoint of the painting.
