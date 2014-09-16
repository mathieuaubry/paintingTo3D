function [hogs_boxes hogs_bboxes bboxes]=getHogVector(I,DEparams)
[Ihogs_pyramid scales]=hog_pyramid(I,DEparams);

%% compute a vector of HOGs
bboxes=zeros(0,4);
hogs_bboxes=zeros(0,4);
hog_size=DEparams.hog_size;
hogs_boxes=zeros(0,hog_size(2)*hog_size(3)*hog_size(1));
for scale_index=1:length(Ihogs_pyramid)
    hogs=Ihogs_pyramid{scale_index};
    hogs_size=size(hogs);
    [x,y]=meshgrid(2:hogs_size(1)-hog_size(1)+1-1,2:hogs_size(2)-hog_size(2)+1-1);
    bbox=[x(:) y(:) x(:)+hog_size(1)-1 y(:)+hog_size(2)-1];
    hogs_bboxes=cat(1,hogs_bboxes,bbox);
    bboxes=cat(1,bboxes,DEparams.sbin.*bbox./scales(scale_index));
    bboxes(end-size(bbox,1)+1:end,1:2)=bboxes(end-size(bbox,1)+1:end,1:2)-DEparams.sbin./scales(scale_index)+1;
    n=size(bbox,1);
    hogs_box=zeros(hog_size(1),hog_size(2),hogs_size(3),n);
    for i=1:size(bbox,1)
        hogs_box(:,:,:,i)=(hogs(bbox(i,1):bbox(i,1)+hog_size(1)-1,bbox(i,2):bbox(i,2)+hog_size(2)-1,:));
    end
    hogs_boxes=cat(1,hogs_boxes,reshape(hogs_box,hog_size(1)*hog_size(2)*hog_size(3),n)');
end

