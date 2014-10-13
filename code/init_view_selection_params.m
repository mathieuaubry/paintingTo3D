view_params= struct;
view_params.threshInlier = 0.4; % Inlier threshold for a point (in image percentage)
view_params.sigmaDepth=0.3;% Inlier threshold for a point (in image percentage)
view_params.sigmaDirection=1000;%0.5;% Inlier threshold for a point (in image percentage)
view_params.sigmaInlier=0.2;% Inlier threshold for a point (in image percentage)
view_params.max_evaluation_points=10000;% maximal number of point to do the statistic over the image (reduce for speed_up)
view_params.N_views=4; % limit number of view to consider a view too specific
view_params.CVthreshold=0.8;
view_params.min_visible_views=4;
view_params.voc_threshold=0.5;
view_params.conf_ratio_threshold=1.04;
view_params.max_views=50;

view_params.nms_param_det=0.2;
view_params.norm_thresh_det=DE_params.norm_thresh*2;
