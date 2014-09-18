function []=alignPainting(MODEL_DIR,painting_name,DE_params,view_params,output_name)

if exist(out_name)
    return;
end
I=im2double(imread(painting_name));
if size(I,3)==1
    I = repmat(I,[1 1 3]);
end

[all_hogs unused bboxes]=getHogVector(I,DE_params);

load([MODEL_DIR '/all_DEs.mat'],'all_DEs');
x=[];
X=[];
conf=[];
ratios=[];
%fprintf('advancement : 00%%');
all_responses=all_hogs*all_DEs.ws';
%thres=view_params.norm_thresh_det;
for i_DE=1:10000%size(all_DEs.ws,1)
    % fprintf('\b\b\b%02i%%',round(100*i_DE/size(all_DEs.ws,1)));
%     if mod(i_DE,100)==0 && size(x,1)>200
%         c=sort(ratios,'descend');
%         thres=c(125);
%     end
    responses=all_responses(:,i_DE);%+all_DEs.bs(i_DE);
    [nmsbbox,nmsconf,resid]=prunebboxes(bboxes,responses,view_params.nms_param_det,mean(responses),2);
    bbox3d=squeeze(all_DEs.bbox_3d(i_DE,:,:));
    N_det=size(nmsbbox,1);
    if N_det>1
        confidence=zeros(5,1);
        ratio=zeros(5,1);
        xx=zeros(5,2);
        XX=zeros(5,3);
        xx(1,1)=(nmsbbox(1,2)+nmsbbox(1,4))/2;
        xx(1,2)=(nmsbbox(1,1)+nmsbbox(1,3))/2;
        xx(2,1)=nmsbbox(1,2);
        xx(2,2)=nmsbbox(1,1);
        xx(3,1)=nmsbbox(1,4);
        xx(3,2)=nmsbbox(1,1);
        xx(4,1)=nmsbbox(1,2);
        xx(4,2)=nmsbbox(1,3);
        xx(5,1)=nmsbbox(1,4);
        xx(5,2)=nmsbbox(1,3);
        
        XX(1,:)=sum(bbox3d,1)/4;
        XX(2,:)=bbox3d(1,:);
        XX(3,:)=bbox3d(2,:);
        XX(4,:)=bbox3d(3,:);
        XX(5,:)=bbox3d(4,:);
        
        confidence(1:5)=nmsconf(1);
        ratio(1:5)=nmsconf(1)./nmsconf(2);
        x=cat(1,x,xx);
        X=cat(1,X,XX);
        conf=cat(1,conf,confidence);
        ratios=cat(1,ratios,ratio);
    end
end
save(sprintf('%s/correspondences2D3D.mat',MODEL_DIR),'x','X','conf','ratios');

[ratios order]=sort(ratios,'descend');
conf=conf(order(1:200));
x=x(order(1:200),:);
X=X(order(1:200),:);

[conf order]=sort(conf,'descend');
%rat=rat(order(1:125));
x=x(order(1:125),:)';
X=X(order(1:125),:)';


focal=sqrt(size(I,1)^2+size(I,2)^2);
inlierThresh=0.015*focal;
K=[focal 0 size(I,1)/2; 0 focal size(I,2)/2; 0 0 1];
[P,nInliers] = ExemplarResectioning(K,X,x,inlierThresh,10000);


save(out_name, 'P','nInliers','I');
%R= meshGenerateColored(P,meshFileName,size(I),BIN_PATH);
%imwrite(R,sprintf('%s/alignment.jpg',MODEL_DIR));




