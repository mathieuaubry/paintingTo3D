function getDiscriminativElements(view_id,DEparams,view_params)

%% if there are already enough elements, stop

%% get image
imname=sprintf('%s/%08i.png',VIEWS_DIR,view_id-1);
facesname=sprintf('%s/%08i.png',FACES_DIR,view_id-1);
I = im2double(imread(imname));
if size(I,3)==1
    I=repmat(I,[1 1 3]);
end
imageSize=size(I);
F= readMap24(facesname);
isValidMap=F~=0;
P=getViewpoint(CameraStruct,view_id);
X=getPositionFromFaces(F,CameraStruct,view_id,imageSize,vertices,faces);

%% get nearby viewpoints
fprintf(' evaluate viewpoint for view %i\n',view_id);
[ProbInlier,isInlier] = evaluateViewpoints(X,P,CameraStruct,VIEWS_DIR,view_params);

%% if there are not enough nearby viewpoints, return
if(sum(isInlier)<view_params.N_views)
    fprintf('only %i inliers for view %i, the veiw is too specific to be considered \n',sum(isInlier),view_id);
    return;
end

% save nearby cameras indices
%% debug
if(debug_mode)
    for i=1:length(cv_cameras_id)
        imname=sprintf('%s/%08i.jpg',VIEW_DIR,cv_cameras_id(i)-1);
        II = imread(imname);
        imname=sprintf('%s/match_%i_to_%08i.jpg',ELEMENTS_DIR,i,view_id-1);
        imwrite(II,imname);
    end
end



%% get best patch for recognition from whitening point of view
fprintf(' find candidates for view %i\n',view_id);
DEs=DEs_from_image(I,DEparams); % generate proposals of distionctive elements

DEs=get3dDEs(P,DEs,X,isValidMap);
%[bboxes confidence fidx]=filter_center(bboxes,confidence,isValidMap); % only keep those for which the model projects at the center

%confidence_sav=confidence;

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
if elements_params.CVthreshold>0.0
    fprintf(' cross validate for %i candidate DEs and %i neighbor views \n', length(DEs),length(cv_cameras_id));
    DEs=crossValidateElements(DEs,I,P,X,CameraStruct,cv_cameras_id,VIEWS_DIR,FACES_DIR,vertices,faces,whitening_params,hog_params,view_params,elements_params);
    fprintf('%i valid patches on %i candidates with %i valid views corresponding to view %i\n',length(validid),length(resid),length(cv_cameras_id),view_id);
end


%% save data for each good elemement
general_patch_id=0;
for DE_id=1:length(DEs) 
        %% save in the good file (detection of previously written files for cluster use)        
        general_patch_id=general_patch_id+1;
        DE=DEs{i};
        WH_PATCH_FILE=sprintf('%s/DE_%i.mat',ELEMENTS_DETAILS_DIR,general_patch_id);
        while exist(WH_PATCH_FILE,'file')
            general_patch_id=general_patch_id+1;
            WH_PATCH_FILE=sprintf('%s/DE_%i.mat',ELEMENTS_DETAILS_DIR,general_patch_id);
        end
        save(WH_PATCH_FILE,'DE');    
end






