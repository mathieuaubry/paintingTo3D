
function [DEs]=DEs_from_image(I,params)

DEs={};

%% compute whitened norm for all patches
confidences=[];
bboxes=[];
hog_bboxes=[];
all_whogs=[];
all_hogs=[];
scale_ids=[];

hog_size=size(params.mu);
[hogs_pyramid scales_pyramid]=hog_pyramid(I,params);

for scale_index=params.DE_min_scale:length(hogs_pyramid)
    hogs=hogs_pyramid{scale_index};
    hogs_size=size(hogs);
    [x,y]=meshgrid(2:hogs_size(1)-hog_size(1)+1-1,2:hogs_size(2)-hog_size(2)+1-1);
    bbox=[x(:) y(:) x(:)+hog_size(1)-1 y(:)+hog_size(2)-1];
    n=size(bbox,1);
    hogs_box=zeros(hog_size(1),hog_size(2),hogs_size(3),n);
    chogs_box=zeros(hog_size(1),hog_size(2),hogs_size(3),n);
    for i=1:size(bbox,1)
        hogs_box(:,:,:,i)=reshape(hogs(bbox(i,1):bbox(i,3),bbox(i,2):bbox(i,4),:),hog_size(1),hog_size(2),hogs_size(3),1);
        chogs_box(:,:,:,i)=reshape(hogs(bbox(i,1):bbox(i,3),bbox(i,2):bbox(i,4),:)-params.mu,hog_size(1),hog_size(2),hogs_size(3),1);
    end
    hogs_box=reshape(hogs_box,hog_size(1)*hog_size(2)*hog_size(3),n)';
    chogs_box=reshape(chogs_box,hog_size(1)*hog_size(2)*hog_size(3),n)';
    whogs_box=(params.sigmaInv*(chogs_box'))';
    values=sqrt(sum(whogs_box.*chogs_box,2));
    
    
    positionDetection=([bbox(:,1) bbox(:,2)]-1).*params.sbin./scales_pyramid(scale_index)+1;
    patchSizeDetection=[hog_size(1)*params.sbin./scales_pyramid(scale_index) hog_size(2)*params.sbin./scales_pyramid(scale_index)];
    
    hog_bboxes=cat(1, hog_bboxes,bbox);
    confidences=cat(1,confidences,values);
    scale_ids=cat(1,scale_ids,scale_index.*ones(size(values,1),1));
    bboxes=cat(1,bboxes ,[positionDetection(:,1) positionDetection(:,2) positionDetection(:,1)+patchSizeDetection(1)-1 positionDetection(:,2)+patchSizeDetection(2)-1]);
    all_whogs=cat(1,all_whogs,whogs_box);
    all_hogs=cat(1,all_hogs,hogs_box);
end


%% non max suppression
[nmsbbox,nmsconf,resid]=prunebboxes(bboxes,confidences,params.nms_param,params.norm_thresh);

resid=resid(1:min(params.N_max_DEs,end),:);


%% Build DEs

DEs.hog_bboxes=hog_bboxes(resid,:);
DEs.bboxes=bboxes(resid,:);
DEs.scale_ids=scale_ids(resid);
DEs.ws=all_whogs(resid,:);

for DE_index=1:length(resid)
    w=DEs.ws(DE_index,:);
    w=reshape(w,[hog_size(1) hog_size(2) hog_size(3)]);
    h = reshape(all_hogs(resid(DE_index),:),[hog_size(1) hog_size(2) hog_size(3)]);
    w=w.*repmat(sum(abs(h),3)>0.01,[1 1 hog_size(3)]);
    DEs.ws(DE_index,:)=w(:);
end

