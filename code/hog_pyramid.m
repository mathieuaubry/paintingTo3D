function [feat, scale] = hog_pyramid(I, hog_params)
% [feat, scale] = hog_pyramid(im, params);
% Compute a pyramid worth of features by calling resize/features in
% over a set of scales defined inside params

if ~isfield(hog_params,'sbin') || ~isfield(hog_params,'features') || ~isfield(hog_params,'min_scale') || ~isfield(hog_params,'min_scale') || ~isfield(hog_params,'levels_per_octave')
    error('missing hog parameter: sbin, features, min_scale, max_scale, levels_per_octave');
end

%Make sure image is in double format
I = double(I);

%Hardcoded maximum number of levels in the pyramid
MAXLEVELS = 200;

%Hardcoded minimum dimension of smallest (coarsest) pyramid level
MINDIMENSION = 5;


sc = 2 ^(1/hog_params.levels_per_octave);

% Start at detect_max_scale, and keep going down by the increment sc, until
% we reach MAXLEVELS or detect_min_scale
scale = zeros(1,MAXLEVELS);
feat = {};
for i = 1:MAXLEVELS
    scaler = hog_params.max_scale / sc^(i-1);
    
    if scaler < hog_params.min_scale
        return
    end
    
    scale(i) = scaler;
    scaled = imresize(I,scale(i));
    
    %if minimum dimensions is less than or equal to 5, exit
    if min([size(scaled,1) size(scaled,2)])<=MINDIMENSION
        scale = scale(scale>0);
        return;
    end
    if size(scaled,3)==2
        scaled=repmat(scaled,[1 1 3]);
    end
    feat{i} = hog_params.features(scaled,hog_params.sbin);
    
    %if we get zero size feature, backtrack one, and dont produce any
    %more levels
    if (size(feat{i},1)*size(feat{i},2)) == 0
        feat = feat(1:end-1);
        scale = scale(1:end-1);
        return;
    end
    
    %recover lost bin!!!
    feat{i} = padarray(feat{i}, [1 1 0], 0);
    
    %if the max dimensions is less than or equal to 5, dont produce
    %any more levels
    if max([size(feat{i},1) size(feat{i},2)])<=MINDIMENSION
        scale = scale(scale>0);
        return;
    end
end
