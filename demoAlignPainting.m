
addpath('./code');
init_DE_params;
init_view_selection_params;
MODEL_DIR='./cache_san_marco_basilica';
load([MODEL_DIR '/cameras.mat'],'CameraStruct');
N_images=length('cameras.mat');
ELTS_DIR='./cache_san_marco_basilica/DEs';
painting_name='san_marco1.jpg';
output_name='./output_camera.mat';

alignPainting(MODEL_DIR,painting_name,DE_params,view_params,output_name);

%% The renderer needs to be compiled for this last part to work
addpath ./renderer;
meshFileName = 'out_model_venice';
load(output_name);
img = meshGenerateColored(P,meshFileName,size(I));
imshow(img);
