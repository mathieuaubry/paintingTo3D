% Make sure to read the README for instructions on how to compile.  Once
% everything is compiled, run the following to render a scene.

addpath ./renderer;
addpath ./code;

load test_camera;
meshFileName = 'out_model_venice';

img = meshGenerateColored(P,meshFileName,size(I));

figure;
imshow(img);
