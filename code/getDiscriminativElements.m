function getDiscriminativElements(view_id,MODEL_DIR,ELTS_DIR,CameraStruct,DEparams,view_params)

%% if there are already enough elements, stop
VIEWS_DIR=[MODEL_DIR '/Views'];
FACES_DIR=[MODEL_DIR '/Positions'];
load([MODEL_DIR '/model.mat']);
%% get image
imname=sprintf('%s/%08i.jpg',VIEWS_DIR,view_id);
facesname=sprintf('%s/%08i.png',FACES_DIR,view_id);
I = im2double(imread(imname));
if size(I,3)==1
    I=repmat(I,[1 1 3]);
end
imageSize=size(I);
F= readMap24(facesname);
isValidMap=F~=0;
%P=getViewpoint(CameraStruct{view_id});
[X P]=getPositionFromFaces(F,CameraStruct{view_id},imageSize,vertices,faces);

%% get nearby viewpoints
fprintf(' evaluate viewpoint for view %i\n',view_id);
tic
[~,isInlier] = evaluateViewpoints(X,P,CameraStruct,view_params); 
%cv_cameras_ids=find(isInlier);
toc

%% if there are not enough nearby viewpoints, return
if(sum(isInlier)<view_params.N_views)
    fprintf('only %i inliers for view %i, the view is too specific to be considered \n',sum(isInlier),view_id);
    return;
end


%% get best patch for recognition from whitening point of view
fprintf(' find DE candidates for view %i\n',view_id);
tic
DEs=DEs_from_image(I,DEparams); % generate proposals of distionctive elements
DEs.bs=zeros(1,length(DEs.scale_ids));%DEs.ws*DEparams.mu(:);
DEs=get3dDEs(P,DEs,X,isValidMap);
toc

%% non-max-suppression + threshold on discriminativity
%indsel=find(confidence>whitening_params.discriminability_threshold);
%[nmsbbox,nmsconf,resid]=prunebboxes(bboxes(indsel,:),confidence(indsel),0.2);

%nmsbbox=nmsbbox(1:min(elements_params.number_cv_candidates,end),:);
%nmsconf=nmsconf(1:min(elements_params.number_cv_candidates,end),:);
%resid=resid(1:min(elements_params.number_cv_candidates,end),:);

%look_index=find(nmsconf>elements_params.norm_thresh);
%nmsbbox=nmsbbox(look_index,:);
%nmsconf=nmsconf(look_index,:);
%resid=resid(look_index,:);



%%Cross-validation
if view_params.CVthreshold>0.0
    fprintf(' cross validate for %i candidate DEs and %i neighbor views \n', length(DEs.scale_ids),sum(isInlier));
    tic
    DEs=crossValidateElements(DEs,I,CameraStruct(isInlier),find(isInlier),VIEWS_DIR,view_params,DEparams);
    toc
    fprintf('%i valid DEs \n',length(DEs.scale_ids));
end


%% save data for each good elemement
        WH_PATCH_FILE=sprintf('%s/DEs_%i.mat',ELTS_DIR,view_id);
        save(WH_PATCH_FILE,'DEs');    
end






