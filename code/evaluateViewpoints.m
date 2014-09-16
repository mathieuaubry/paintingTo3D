function [ProbInlier,isInlier,cameras] = evaluateViewpoints(Xgt,Pgt,CameraStruct,view_params)
% Inputs:
% Pgt - Ground truth camera matrix
% P - Target camera matrices
% meshFileName - name of the mesh
% imageSize
% point

% Outputs:
% ProbInlier - sum(exp(-error^2/(2sigmaInliner^2)))


%% get all cameras
imageSize=size(Xgt);
[Kgt Rgt Tgt]=decomposeP(Pgt);
P = zeros(3,4,length(CameraStruct));
for i = 1:length(CameraStruct)
    P(:,:,i)=getViewpoint(CameraStruct{i},imageSize);
end

%% get points for test
[row ,col]=find(sum(abs(Xgt),3)>0);
while size(row,1)>view_params.max_evaluation_points;
    row=row(1:2:end);
    col=col(1:2:end);
end
NValidGTPixels=size(row,1);
if(NValidGTPixels==0)
    warning('The Mesh is not visible in the GT camera');
    ProbInlier = zeros(1,size(P,3));
    isInlier = false(1,size(P,3));
    cameras={};
    return;
end

Xgt = cat(3,Xgt, ones(size(Xgt,1),size(Xgt,2),1));
indices=sub2ind([size(Xgt,1) size(Xgt,2)],row,col);
Xgt=reshape(Xgt,[],4);
Xinside=squeeze(Xgt(indices,:))';

%% test all cameras
ProbInlier = zeros(1,size(P,3));
isInlier = false(1,size(P,3));
for i = 1:size(P,3)
    Pi = squeeze(P(:,:,i));
    [Ki Ri Ti]=decomposeP(Pi);
    
    % Project valid ground truth points using target camera:
    x3 = Pi(3,:)*Xinside;
    
    %%%%% note: check if this test is well done
    dd = det(Pi(:,1:3))*x3;
    n = find(dd>0);
    
    
    x1 = Pi(1,:)*Xinside;
    x2 = Pi(2,:)*Xinside;
    x1 = x1(n)./x3(n);
    x2 = x2(n)./x3(n);
    x1=x1.*(x1>0.5);
    x1=x1.*(x1<0.5+imageSize(2));
    
    x2=x2.*(x2>0.5);
    x2=x2.*(x2<0.5+imageSize(1));
    ind=find(x1.*x2);
    x1=x1(ind);
    x2=x2(ind);
    n=n(ind);
    
    
    if(~isempty(n))
        valid_X=Xinside(1:3,n)./repmat(Xinside(4,n),[3 1]);
        
        % penalize difference in projection position
        penalization_position=((x2.*imageSize(1)./imageSize(1)-row(n)')./(view_params.sigmaInlier*imageSize(1))).^2 + ((x1.*imageSize(2)./imageSize(2)-col(n)')./(view_params.sigmaInlier*imageSize(2))).^2;
        
        % penalize the difference of camera directions to the point
        GT_directions=valid_X-repmat(Tgt,[1 size(valid_X,2)]);
        GT_directions=GT_directions./repmat(sqrt(sum(GT_directions.*GT_directions,1)),[3 1]);
        camera_directions=valid_X-repmat(Ti,[1 size(valid_X,2)]);
        camera_directions=camera_directions./repmat(sqrt(sum(camera_directions.*camera_directions,1)),[3 1]);
        dir_diff=GT_directions-camera_directions;
        dir_diff2=dir_diff.*dir_diff;% (2-2*cos(GT_directions,camera_directions))
        penalization_direction=  sum(dir_diff2,1)./(2.*view_params.sigmaDirection.*view_params.sigmaDirection);
        
        % penalize depth difference
        deltaGT=sum((valid_X-repmat(Tgt,[1 size(valid_X,2)])).^2,1);
        deltaI=sum((valid_X-repmat(Ti,[1 size(valid_X,2)])).^2,1);
        deltaNorm2=(2.*(deltaGT-deltaI)./(deltaGT+deltaI)).^2;
        penalization_depth =deltaNorm2./(view_params.sigmaDepth.*view_params.sigmaDepth);
        
        % compute inlier score
        penalization=penalization_depth + penalization_direction+ penalization_position;
        ProbInlier(i) = sum(exp(-penalization./(2)))/NValidGTPixels;
        isInlier(i) = ProbInlier(i)>view_params.threshInlier;
    else
        ProbInlier(i)=0;
        isInlier(i) = false;
    end
end
[temp camerasIndices]=sort(ProbInlier,'descend');
cameras.approx = zeros(3,4,length(camerasIndices));
cameras.ideal=Pgt;
for i = 1:length(camerasIndices)
    cameras.approx(:,:,i) = P(:,:,camerasIndices(i));
end









