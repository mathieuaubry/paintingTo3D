[Painting-to-3D Model Alignment](http://www.di.ens.fr/willow/research/painting_to_3d/) source code
============
Here you will find a Matlab implementation of the algorithm described
in the following paper:

Mathieu Aubry, Bryan C. Russell and Josef Sivic
Painting-to-3D Model Alignment Via Discriminative Visual Elements
ACM Transactions on Graphics, 2014 (presented at SIGGRAPH 2014)
[PDF](http://www.di.ens.fr/willow/research/painting_to_3d/texts/Aubry13.pdf) | [bibtex](http://www.di.ens.fr/willow/research/painting_to_3d/texts/2013-painting-to-3D-alignment_bibtex.html) | [project webpage](http://www.di.ens.fr/willow/research/painting_to_3d/)


### DOWNLOADING THE CODE:

You can download a [zip file of the source code](https://github.com/mathieuaubry/paintingTo3D/archive/master.zip) directly.  

Alternatively, you can clone it from GitHub as follows:

``` sh
$ git clone https://github.com/mathieuaubry/paintingTo3D.git
```

### DOWNLOADING THE DATA

If you want to use one of our models, you have to download the rendered views and corresponding data for the 3D model you want to use:
- [CAD model of San Marco Basilica](http://www.di.ens.fr/willow/research/painting_to_3d/data/cache_san_marco_basilica.tar) (614MB). The original 3D model is available [here](http://sketchup.google.com/3dwarehouse/details?mid=433bfb7d61901dc65822c6ca7b1d5d61&prevstart=0).
- [CAD model of Notre Dame](http://www.di.ens.fr/willow/research/painting_to_3d/data/cache_notre_dame.tar) (2GB). The original 3D model is available [here](https://3dwarehouse.sketchup.com/model.html?redirect=1&mid=69d9e3c4f1e6359cc45a0a86a468dd45&prevstart=72).
- [CAD model of Trevi fountain](http://www.di.ens.fr/willow/research/painting_to_3d/data/cache_trevi.tar) (792MB). The original 3D model is available [here](https://3dwarehouse.sketchup.com/model.html?redirect=1&mid=db52a9472001b79b43babf42c8cb195).




Additionaly, you can download our pre-computed discriminative elements for:
- [CAD model of San Marco Basilica](http://www.di.ens.fr/willow/research/painting_to_3d/data/all_DEs_san_marco_basilica.mat) (104MB).
- [CAD model of Notre Dame](http://www.di.ens.fr/willow/research/painting_to_3d/data/all_DEs_notre_dame.mat) (107MB).
- [CAD model of Trevi fountain](http://www.di.ens.fr/willow/research/painting_to_3d/data/all_DEs_trevi.mat) (131MB).



The paintings we used to test our method are available [here](http://www.di.ens.fr/willow/research/painting_to_3d/data/Paintings.zip) (40MB)

To test the renderer, you can also download a  [test camera](http://www.di.ens.fr/willow/research/painting_to_3d/data/test_camera.mat) recovered by our algorithm with the associated painting.


### RUNNING THE CODE:

1. Start by compiling the code.  At the Matlab command prompt run:

   ``` sh
   >> compile;
   ```

2. Download or generate the rendered views of the model you want to work with.
 
3. (Optional) [demoSelectDEs.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoSelectDEs.m) is a script that computes the discriminative elements from a set of rendered views of a 3D model and their associated Cameras and 3D points. It must be run before doing detection. 
Alternatively, you can download our pre-computed discriminative elements (see DOWNLOAD THE DATA section).

4. [demoAlignPainting.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoAlignPainting.m) is a script that uses the discriminative elements to recover the camera parameters corresponding to the viewpoint of the painting.


### COMPILING THE RENDERER:

To view the final results you will need to render from the 3D model.
The following are instructions for compiling the renderer.

1. Download [trimesh2](http://gfx.cs.princeton.edu/proj/trimesh2/src/trimesh2-2.12.tar.gz) and uncompress the tarball.

2. Define the following variables:

   - $PAINTING_CODE - location of "paintingTo3D" code
   - $TRIMESH2 - location of trimesh2 folder
   - $MEX - command-line location of mex compiler; get the location by running in Matlab:
 
      ``` sh
      >> fullfile(matlabroot,'bin','mex')
      ```

   - $ARCH - set this to one of {Linux | Linux64 | Darwin | Darwin64} depending on which architecture you are compiling (e.g. "Darwin64" is 64-bit Mac)

3. Run the following in a Bash shell:

   ``` sh
   $ cd $PAINTING_CODE/renderer
   $ make TRIMESHDIR=$TRIMESH2
   $ $MEX mexReadPly.cpp -I$TRIMESH2/include -L$TRIMESH2/lib.$ARCH -ltrimesh -lgomp
   $ $MEX mexWritePly.cpp -I$TRIMESH2/include -L$TRIMESH2/lib.$ARCH -ltrimesh -lgomp
   ```

4. To test the renderer, download this  [test camera](http://www.di.ens.fr/willow/research/painting_to_3d/data/test_camera.mat) and run the script inside [demoRendering.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoRendering.m).

Common problems:

- If you are compiling on Mac and get a "library not found for -lgomp"
error, then you are using a CLANG compiler (recent versions of Mac use
this), which does not contain openmp.  To resolve this you can install
an older gcc compiler via homebrew.  Replace "Step 3" above with the
following:

   ``` sh
   $ brew install homebrew/versions/gcc49
   $ cd $PAINTING_CODE/renderer
   $ make TRIMESHDIR=$TRIMESH2 CC=gcc-4.9 CXX=g++-4.9
   $ $MEX mexReadPly.cpp -I$TRIMESH2/include -L$TRIMESH2/lib.$ARCH -ltrimesh -lgomp CXX=g++-4.9 CXXFLAGS="-fno-common -arch x86_64 -fexceptions"
   $ $MEX mexWritePly.cpp -I$TRIMESH2/include -L$TRIMESH2/lib.$ARCH -ltrimesh -lgomp CXX=g++-4.9 CXXFLAGS="-fno-common -arch x86_64 -fexceptions"
   ```

- If you are compiling on Linux and get an error saying to recompile
with -fPIC, then you need to recompile trimesh2.  Run inside a Bash shell:

   ``` sh
   $ cd $TRIMESH2
   $ make clean
   $ make ARCHOPTS=-fPIC
   ```

   Then re-run "Step 3" above.

+ If you're running on Linux and the code hangs, first make sure you can
display X windows (i.e. if you're running over SSH make sure you have X
forwarding enabled; you can test this by running "xterm" in the bash
shell).  If you can display X windows but the code hangs, then 
run the following in the Bash shell:

   ``` sh
   $ export LIBGL_ALWAYS_INDIRECT=1
   ```

   Then try to run [demoRendering.m](https://github.com/mathieuaubry/paintingTo3D/blob/master/demoRendering.m) again.


### ACKNOWLEDGMENTS:

The functions features.cc and bboverlap.m have been adapted from Ross Girshick's and Pedro Felzenswalb's implementation available at https://github.com/rbgirshick/voc-dpm
