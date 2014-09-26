%{

% Instructions for running rendering code.

% Step 1: Download trimesh2:
% http://gfx.cs.princeton.edu/proj/trimesh2/src/trimesh2-2.12.tar.gz
%
% Step 2: Unzip trimesh2 tarball and put inside ./renderer/LIBS/
% 
% Step 3 (Mac): Compile mex from within Matlab:
%
% cd ./renderer/
% mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin64 -ltrimesh -lgomp
%
% If you get errors saying that the compiler cannot find libgomp, then
% you may be using a CLANG compiler (recent versions of Mac use this),
% which does not contain openmp.  If this is the case, then try the following:
%
% 3a. Install MacPorts and run the following in the bash shell:
%
% sudo port install gcc49
%
% 3b. Change the "CXX" variable assignment in Matlab's "mexopts" (/Applications/MATLAB_R2014a.app/bin/maci64/mexopts/clang++_maci64.xml:
%
%   CXX="$XCRUN_DIR/xcrun /opt/local/bin/g++-mp-4.9"
%
% 3c. Run original Step 3 (Mac) above.
%
% Step 3 (Linux): Compile mex from within Matlab:
%
% cd ./renderer/
% mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Linux64 -ltrimesh -lgomp
%
% If you get an error saying to recompile with -fPIC, then you need to
% recompile trimesh2:
%
% 3a. Run inside bash shell:
%
% cd ./renderer/LIBS/trimesh2/
% make ARCHOPTS=-fPIC
%
% 3b. Run original Step 3 (Linux) above.
%
% Step 4: Compile "get_3d_info_textures" by running on Bash shell:
%
% cd ./renderer/
% make
%
% Step 5: Run the code below.  It should display a rendered view.  
%
% If you're running on Linux and the code hangs, first make sure you can
% display X windows (i.e. if you're running over SSH make sure you have X
% forwarding enabled; you can test this by running "xterm" in the bash
% shell).  If you can display X windows but the code hangs, then 
% run the following in the Bash shell:
%
% export LIBGL_ALWAYS_INDIRECT=1
%
% Then try to run the code below again.

%}


% Once everything is compiled, run the following to render a scene.

addpath ./renderer;
addpath ./code;

BIN_PATH = './renderer/get_3d_info_textures';
load camera_10000_ratio_2;
meshFileName = 'out_model_venice';

img = meshGenerateColored(P,meshFileName,size(I),BIN_PATH);

figure;
imshow(img);
