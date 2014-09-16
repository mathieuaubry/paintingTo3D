function []=alignPainting(MODEL_DIR,painting_name,meshFileName,DE_params,view_params,BIN_PATH)

I=im2double(imread(painting_name));
[all_hogs unused bboxes]=getHogVector(I,DE_params);

load([MODEL_DIR '/all_DEs.mat'],'all_DEs');
x=[];
X=[];
conf=[];
fprintf('advancement : 00%%');
all_responses=all_hogs*all_DEs.ws';
thres=view_params.norm_thresh_det;
for i_DE=1:size(all_DEs.ws,1)
    fprintf('\b\b\b%02i%%',round(100*i_DE/size(all_DEs.ws,1)));
   if mod(i_DE,100)==0 && size(x,1)>125
       c=sort(conf,'descend');
       thres=c(125);
   end
    responses=all_responses(:,i_DE);%+all_DEs.bs(i_DE);
    [nmsbbox,nmsconf,resid]=prunebboxes(bboxes,responses,view_params.nms_param_det,thres,10);
    bbox3d=squeeze(all_DEs.bbox_3d(i_DE,:,:));
    N_det=size(nmsbbox,1);
    confidences=zeros(5*N_det,1);
    xx=zeros(5*N_det,2);
    XX=zeros(5*N_det,3);
    for det_id=1:N_det
        xx(5*(det_id-1)+1,1)=(nmsbbox(det_id,2)+nmsbbox(det_id,4))/2;
        xx(5*(det_id-1)+1,2)=(nmsbbox(det_id,1)+nmsbbox(det_id,3))/2;
        xx(5*(det_id-1)+2,1)=nmsbbox(det_id,2);
        xx(5*(det_id-1)+2,2)=nmsbbox(det_id,1);
        xx(5*(det_id-1)+3,1)=nmsbbox(det_id,4);
        xx(5*(det_id-1)+3,2)=nmsbbox(det_id,1);
        xx(5*(det_id-1)+4,1)=nmsbbox(det_id,2);
        xx(5*(det_id-1)+4,2)=nmsbbox(det_id,3);
        xx(5*(det_id-1)+5,1)=nmsbbox(det_id,4);
        xx(5*(det_id-1)+5,2)=nmsbbox(det_id,3);
        
        XX(5*(det_id-1)+1,:)=sum(bbox3d,1)/4;
        XX(5*(det_id-1)+2,:)=bbox3d(1,:);
        XX(5*(det_id-1)+3,:)=bbox3d(2,:);
        XX(5*(det_id-1)+4,:)=bbox3d(3,:);
        XX(5*(det_id-1)+5,:)=bbox3d(4,:);
        
        confidences(5*(det_id-1)+1:5*(det_id-1)+5)=nmsconf(det_id);
    end
    x=cat(1,x,xx);
    X=cat(1,X,XX);
    conf=cat(1,conf,confidences);
end
save(sprintf('%s/correspondences2D3D.mat',MODEL_DIR),'x','X','conf');

[conf order]=sort(conf,'descend');
%conf=conf(1:125);
x=x(order(1:125),:)';
X=X(order(1:125),:)';

focal=sqrt(size(I,1)^2+size(I,2)^2);
inlierThresh=0.015*focal;
K=[focal 0 size(I,1)/2; 0 focal size(I,2)/2; 0 0 1];
[P,nInliers] = ExemplarResectioning(K,X,x,inlierThresh,10000);

save('test_transfer.mat', 'P');
%R= meshGenerateColored(P,meshFileName,size(I),BIN_PATH);
%imwrite(R,sprintf('%s/alignment.jpg',MODEL_DIR));




