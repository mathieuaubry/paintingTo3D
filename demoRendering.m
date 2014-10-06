% Make sure to read the README for instructions on how to compile.  Once
% everything is compiled, run the following to render a scene.

addpath ./renderer;
addpath ./code;

load camera_10000_ratio_2;
meshFileName = 'out_model_venice';

img = meshGenerateColored(P,meshFileName,size(I));

figure;
imshow(img);
