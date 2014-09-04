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
DEinit_n100_ms4;
MODEL_DIR='/meleze/data1/maaubry/paintings_release/cache_san_marco_sample_30_up_10_angles_2_add_100';
load([MODEL_DIR '/cameras.mat']);
N_images=length('cameras.mat');
ELTS_DIR='/meleze/data1/maaubry/paintings_release/cache_san_marco_sample_30_up_10_angles_2_add_100/DEs';
mkdir(ELTS_DIR);


indices_to_visit=randperm( 1:(length(CameraStruct)));
APT_run('getDiscriminativElements',indices_to_visit,{params},'UseCluster', 1, 'ClusterID',1,'NJobs', 50 );

