


%% get whitening params
DE_params=load('whitening_params.mat'); % basic parameters for whitening

%% get HoG params
DE_params.levels_per_octave=3;
DE_params.min_scale=0.1;
DE_params.sbin = 8;
DE_params.max_scale=1.0;
DE_params.max_scale_selection=1.0;
DE_params.max_scale_detection=1.0;
DE_params.features = @features;

%% get paramteters for DE selection
DE_params.nms_param=0.25; % parameter for non max suppression
DE_params.norm_thresh=sqrt(DE_params.mu(:)'*DE_params.sigmaInv*DE_params.mu(:))*2; % whitened norm threshold to consider patch a possible DE
DE_params.N_max_DEs= 10; % maximum number of candidate DE per image before cross validation
DE_params.DE_min_scale=1;%7; % integer corresponding to the minimum level of the pyramid where we will consider candidate DEs 
%DE_params.jit=1; % jittering allowed in matching

