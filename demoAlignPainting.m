
addpath('/meleze/data0/libs/APT');
global APT_PARAMS;
if isempty(APT_PARAMS)
    APT_params();
end

root = fileparts(mfilename('fullpath'));
[~, f] = fileparts(root);
APT_PARAMS.exec_name = f;
%APT_compile();


addpath('./code');
init_DE_params;
init_view_selection_params;
MODEL_DIR='/meleze/data1/maaubry/paintings_release/cache_san_marco_sample_30_up_10_angles_2_add_100';
load([MODEL_DIR '/cameras.mat'],'CameraStruct');
N_images=length('cameras.mat');
ELTS_DIR='/meleze/data1/maaubry/paintings_release/cache_san_marco_sample_30_up_10_angles_2_add_100/DEs';
painting_name='san_marco1.jpg';
%RESULT_DIR='/meleze/data1/maaubry/paintings_release/cache_san_marco_sample_30_up_10_angles_2_add_100/correspondences';
%mkdir(RESULTS_DIR);
BIN_PATH='./code/LIBS/GenerateLambertian/generate_colored';
MESH='/meleze/data0/maaubry/DATA/meshes/san_marco';

alignPainting(MODEL_DIR,painting_name,MESH,DE_params,view_params,BIN_PATH)
