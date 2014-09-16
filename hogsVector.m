function [all_hogs bboxes]=hogsVector(I,params)

if size(I,3)==1
    I = repmat(I,[1 1 3]);
end
bboxes=[];
all_hogs=[];

hog_size=size(params.mu);
[hogs_pyramid scales_pyramid]=hog_pyramid(I,params);

for scale_index=params.DE_min_scale:length(hogs_pyramid)
    hogs=hogs_pyramid{scale_index};
    hogs_size=size(hogs);
    [x,y]=meshgrid(2:hogs_size(1)-hog_size(1)+1-1,2:hogs_size(2)-hog_size(2)+1-1);
    bbox=[x(:) y(:) x(:)+hog_size(1)-1 y(:)+hog_size(2)-1];
    n=size(bbox,1);
    hogs_box=zeros(hog_size(1),hog_size(2),hogs_size(3),n);
    for i=1:size(bbox,1)
        hogs_box(:,:,:,i)=reshape(hogs(bbox(i,1):bbox(i,3),bbox(i,2):bbox(i,4),:),hog_size(1),hog_size(2),hogs_size(3),1);
    end
    hogs_box=reshape(hogs_box,hog_size(1)*hog_size(2)*hog_size(3),n)';
    
    
    positionDetection=([bbox(:,1) bbox(:,2)]-1).*params.sbin./scales_pyramid(scale_index)+1;
    patchSizeDetection=[hog_size(1)*params.sbin./scales_pyramid(scale_index) hog_size(2)*params.sbin./scales_pyramid(scale_index)];
    
    bboxes=cat(1,bboxes ,[positionDetection(:,1) positionDetection(:,2) positionDetection(:,1)+patchSizeDetection(1)-1 positionDetection(:,2)+patchSizeDetection(2)-1]);
    all_hogs=cat(1,all_hogs,hogs_box);
end