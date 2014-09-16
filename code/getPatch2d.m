function [patch2d]=getPatch2d(P,bbox_3d,imageSize)
% patch3d is a structure with fields X1 X2 X3 and X4, each a 3D point in homogene coordinate and a direction U
% patch2d is a structure with fields x1 x2 x3 and x4,  a field P and a field isValid


bbox_3d=cat(2,bbox_3d,ones(4,1));
[K R t]=decomposeP(P);

% get 3d patch center
X=sum(bbox_3d,1)./4;%(patch3d.X1+patch3d.X2+patch3d.X3+patch3d.X4)./4;

% get 2d image
x=(bbox_3d)*P';
x(:,1)=x(:,1)./x(:,3);
x(:,2)=x(:,2)./x(:,3);
x=x(:,2:-1:1);

patch2d.x1=x(1,:);
patch2d.x2=x(2,:);
patch2d.x3=x(3,:);
patch2d.x4=x(4,:);
%patch2d.P=P;

% get center
%patch2d.center=sum(x,1)./4;

% %get surface
% d1=patch2d.x1-patch2d.center';
% d2=patch2d.x2-patch2d.center';
% d3=patch2d.x3-patch2d.center';
% d4=patch2d.x4-patch2d.center';
% s1=abs(d1(1)*d2(2)-d1(2)*d2(1));
% s2=abs(d2(1)*d4(2)-d2(2)*d4(1));
% s3=abs(d4(1)*d3(2)-d4(2)*d3(1));
% s4=abs(d3(1)*d1(2)-d3(2)*d1(1));
% patch2d.S=(s1+s2+s3+s4)/2;

% check if the direction is good
%patch2d.isValid=det((X(1:3)-t(1:3)))>0;

% check if the patch is fully visible in the image
    w=imageSize(1);
    h=imageSize(2);
  %  patch2d.imageSize=imageSize;
    patch2d.isValid=patch2d.x1(1)<w+0.5 && patch2d.x1(1)>0.5 && ...
        patch2d.x2(1)<w+0.5 && patch2d.x2(1)>0.5 && ...
        patch2d.x3(1)<w+0.5 && patch2d.x3(1)>0.5 && ...
        patch2d.x4(1)<w+0.5 && patch2d.x4(1)>0.5 && ...
        patch2d.x1(2)<h+0.5 && patch2d.x1(2)>0.5 && ...
        patch2d.x2(2)<h+0.5 && patch2d.x2(2)>0.5 && ...
        patch2d.x3(2)<h+0.5 && patch2d.x3(2)>0.5 && ...
        patch2d.x4(2)<h+0.5 && patch2d.x4(2)>0.5;
    patch2d.isVisible=(patch2d.x1(1)<w+0.5 && patch2d.x1(1)>0.5 )|| ...
        (patch2d.x2(1)<w+0.5 && patch2d.x2(1)>0.5) || ...
        (patch2d.x3(1)<w+0.5 && patch2d.x3(1)>0.5) || ...
        (patch2d.x4(1)<w+0.5 && patch2d.x4(1)>0.5) || ...
        (patch2d.x1(2)<h+0.5 && patch2d.x1(2)>0.5) || ...
        (patch2d.x2(2)<h+0.5 && patch2d.x2(2)>0.5) || ...
        (patch2d.x3(2)<h+0.5 && patch2d.x3(2)>0.5) || ...
        (patch2d.x4(2)<h+0.5 && patch2d.x4(2)>0.5);

end
