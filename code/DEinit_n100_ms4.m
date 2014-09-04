


%% get whitening params
DEparams=load('whitening_params.mat'); % basic parameters for whitening

%% get HoG params
DEparams.levels_per_octave=3;
DEparams.min_scale=0.1;
DEparams.sbin = 5;
DEparams.max_scale=1.0;
DEparams.max_scale_selection=1.0;
DEparams.max_scale_detection=1.0;
DEparams.features = @features;

%% get paramteters for DE selection
DEparams.nms_param=0.25; % parameter for non max suppression
DEparams.norm_thresh=sqrt(DEparams.mu(:)'*DEparams.sigmaInv*DEparams.mu(:))*2; % whitened norm threshold to consider patch a possible DE
DEparams.N_max_DEs= 10; % maximum number of candidate DE per image before cross validation
DEparams.DE_min_scale=4;%7; % integer corresponding to the minimum level of the pyramid where we will consider candidate DEs 
DEparams.jit=1; % jittering allowed in matching

