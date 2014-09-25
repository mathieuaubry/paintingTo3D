addpath ./renderer;
addpath ./code;

BIN_PATH = './renderer/get_3d_info_textures';
load camera_10000_ratio_2;
meshFileName = 'out_model_venice';

img = meshGenerateColored(P,meshFileName,size(I),BIN_PATH);


%{

% Recent versions of Mac use clang for compilation, which does not
% contain openmp (libgomp).
%
% Steps to compile using openmp:
%
% 1. sudo port install gcc49
% 2. Change the following in Matlab's "mexopts" (/Applications/MATLAB_R2014a.app/bin/maci64/mexopts/clang++_maci64.xml:
%   CXX="$XCRUN_DIR/xcrun /opt/local/bin/g++-mp-4.9"

% To compile mex file from within Matlab:
mex mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin64 -ltrimesh -lgomp

% To compile mex file from command line:
/Applications/MATLAB_R2014a.app/bin/mex -v mexReadPly.cpp -I./LIBS/trimesh2/include -L./LIBS/trimesh2/lib.Darwin64 -ltrimesh -lgomp




./code/get_3d_info_textures out_model_venice /private/tmp/tpefb43a89_0f2c_4c89_9fb2_813f8bece6ec_pipe.txt 599 467 /tmp/foo_out.txt --texture 72



%}
