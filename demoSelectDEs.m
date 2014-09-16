%% TODO
% nead to have a way to read vertices and faces


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
mkdir(ELTS_DIR);


indices_to_visit=randperm( (length(CameraStruct)));
%getDiscriminativElements(1,MODEL_DIR,ELTS_DIR,CameraStruct,DE_params,view_params);
%APT_run('getDiscriminativElements',indices_to_visit',{MODEL_DIR},{ELTS_DIR},{CameraStruct},{DE_params},{view_params},'UseCluster', 1, 'ClusterID',1,'NJobs', 50 );

summarizeDEs(ELTS_DIR,MODEL_DIR,indices_to_visit)