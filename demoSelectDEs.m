
addpath('./code');
init_DE_params;
init_view_selection_params;
MODEL_DIR='/meleze/data1/maaubry/paintings_release/cache_san_marco_sample_30_up_10_angles_2_add_100';
load([MODEL_DIR '/cameras.mat'],'CameraStruct');
N_images=length('cameras.mat');
ELTS_DIR='/meleze/data1/maaubry/paintings_release/cache_san_marco_sample_30_up_10_angles_2_add_100/DEs';
mkdir(ELTS_DIR);


indices_to_visit=randperm( (length(CameraStruct))); %this compute all DEs. In practice, you can take less by indices_to_visit=indices_to_visit(1:500)
getDiscriminativElements(1,MODEL_DIR,ELTS_DIR,CameraStruct,DE_params,view_params);

summarizeDEs(ELTS_DIR,MODEL_DIR,indices_to_visit)
