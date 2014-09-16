function  DEs=crossValidateElements(DEs,Igt,CameraStruct,camera_ids,VIEW_DIR,view_params,DE_params)
% given an image Igt, its camera Pgt, the corresponding 3d points Xgt,
% validate the bboxes for detection in similar images given by cameras_id

N_DEs=length(DEs.scale_ids);
imageSize=size(Igt);
valid_ids=[];
av_score=zeros(1,N_DEs);
count_valid=zeros(1,N_DEs);

cameras_select_ids=randperm(length(camera_ids));
cameras_select_ids=cameras_select_ids(1:min(end,view_params.max_views));
%% loop on different candidates
for c_id=cameras_select_ids
    toc
    P= getViewpoint(CameraStruct{(c_id)},imageSize);
    imname=sprintf('%s/%08i.jpg',VIEW_DIR,camera_ids(c_id));
    I=imread(imname);
   % facesname=sprintf('%s/%08i.png',POS_DIR,camera_ids(c_id));
   % F= readMap24(facesname);
    
    [hogs_boxes hogs_bboxes image_bboxes]=getHogVector(I,DE_params);
    
    confidence_all=DEs.ws*hogs_boxes';
    
    for DE_id=1:N_DEs
        % get 3d patch
        bbox_3d=squeeze(DEs.bbox_3d(DE_id,:,:));
        %% get the GT projection of patch3d and be sure that the center correspond
        patch2d=getPatch2d(P,bbox_3d,imageSize);
        
        
        if patch2d.isValid
            
            x_minGT=(patch2d.x1(1)+patch2d.x3(1))/2;
            x_maxGT=(patch2d.x2(1)+patch2d.x4(1))/2;
            y_minGT=(patch2d.x1(2)+patch2d.x2(2))/2;
            y_maxGT=(patch2d.x3(2)+patch2d.x4(2))/2;
            if (x_maxGT-x_minGT)<80 || (y_maxGT-y_minGT)<80
                patch2d.isValid=0;
            end
            
        end
        if patch2d.isValid
            
            confidence=confidence_all(DE_id,:)+DEs.bs(DE_id);
            %% non-max-suppression
            elements_params.confidence_threshold=1;
            [nmsbbox,nmsconf]=prunebboxes(image_bboxes,confidence,0.2,elements_params.confidence_threshold,2);
            conf_ratio=nmsconf(1)./nmsconf(2);
            bboxdet=nmsbbox(1,:);
            patchSizeDetection=[bboxdet(3)-bboxdet(1) bboxdet(4)-bboxdet(2)];
            positionDetection=[bboxdet(1) bboxdet(2)];
            score=getVocScore(patch2d,positionDetection,patchSizeDetection);
            av_score(DE_id)=av_score(DE_id)+(score>view_params.voc_threshold).*(conf_ratio>view_params.conf_ratio_threshold);
            count_valid(DE_id)=count_valid(DE_id)+1;
            
            
        end
        
        
    end
    
end



    for DE_id=1:N_DEs
        if count_valid(DE_id)>0
            av_score(DE_id)=av_score(DE_id)./count_valid(DE_id);
        end
        fprintf('   av score: %02d   valid views: %i \n',av_score(DE_id),count_valid(DE_id));
        if av_score(DE_id)>view_params.CVthreshold && count_valid(DE_id)>=view_params.min_visible_views
            valid_ids=[valid_ids DE_id];
        end
    end
    
    DEs.bbox_3d=DEs.bbox_3d(valid_ids,:,:);
    DEs.hog_bboxes=DEs.hog_bboxes(valid_ids,:);
    DEs.bboxes=DEs.bboxes(valid_ids,:);
    DEs.scale_ids=DEs.scale_ids(valid_ids);
    DEs.ws=DEs.ws(valid_ids,:);
    
    
    
    