% Make sure to read the README for instructions on how to compile.  Once
% everything is compiled, run the following to render a scene.

addpath ./renderer;
addpath ./code;

BIN_PATH = './renderer/get_3d_info_textures';
load camera_10000_ratio_2;
meshFileName = 'out_model_venice';

img = meshGenerateColored(P,meshFileName,size(I),BIN_PATH);

figure;
imshow(img);
