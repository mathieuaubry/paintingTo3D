
function []=summarizeDEs(ELTS_DIR,MODEL_DIR,indices_to_visit)
all_DEs={};
all_DEs.bbox_3d=zeros(0,4,3);
all_DEs.bboxes=zeros(0,4);
all_DEs.ws=zeros(0,900);
all_DEs.bs=zeros(0,1);
for view_id=indices_to_visit
    if exist(sprintf('%s/DEs_%i.mat',ELTS_DIR,view_id))
        load(sprintf('%s/DEs_%i.mat',ELTS_DIR,view_id));
         all_DEs.bbox_3d=cat(1,all_DEs.bbox_3d,DEs.bbox_3d);
         %all_DEs.hog_bboxes=cat(1,all_DEs.hog_bboxes,DEs.hog_bboxes);
         all_DEs.bboxes=cat(1,all_DEs.bboxes,DEs.bboxes);
         %all_DEs.scale_ids=cat(2,all_DEs.scale_ids,DEs.scale_ids);
         all_DEs.ws=cat(1,all_DEs.ws,DEs.ws);
         all_DEs.bs=cat(1,all_DEs.bs,DEs.bs);
    end
end
all_DEs.ws=single(all_DEs.ws);
all_DEs.ws=single(all_DEs.bs);
save([MODEL_DIR '/all_DEs.mat'],'all_DEs');