function [patch3d patch2d]=getpatch3d(P,x,patchSize,X,isValidMap)
% X is the image of 3dPoints corresponding to the points in the image
% isValidMap tells if X is valid
% patch3d is a structure with fields X1 X2 X3 and X4, each a 3D point in
% homogene coordinate, a field isValid and a direction U (and an optional origin camera)
% x is the 2d position of the patch in the image and PachSize its size

[w h]=size(X);

d1=round((patchSize(1)-1)/2);
d2=round((patchSize(2)-1)/2);

x=round(x);
if (~isValidMap(x(1),x(2)) || x(1)-d1<1 || x(1)+d1>w-1|| x(2)-d2<1 || x(2)+d2>h-1 )
 patch3d.isValid=false;
 patch2d.isValid=false;
 
 return;
end

 patch3d.isValid=true;
 patch2d.isValid=true;

X0=squeeze(X(x(1),x(2),:));
[K R t]=decomposeP(P);
D=R(3,:)*(X0-t);

dXx=R'*[1 0 0]'.*D./K(1,1);
dXy=R'*[0 1 0]'.*D./K(2,2);

patch3d.X1=X0-d1.*dXx-d2.*dXy;
patch3d.X2=X0-d1.*dXx+d2.*dXy;
patch3d.X3=X0+d1.*dXx-d2.*dXy;
patch3d.X4=X0+d1.*dXx+d2.*dXy;

 patch3d.isValid=D>5;
 patch2d.isValid=D>5;

 patch3d.U=(X0-t)./sqrt(sum((X0-t).*(X0-t)));
patch3d.z=R(3,:);
patch3d.D=D;
patch3d.origin=t;
patch3d.center=X0;
patch3d.P=P;

patch2d.x1=x+[-d1 -d2];
patch2d.x2=x+[-d1 d2];
patch2d.x3=x+[d1 -d2];
patch2d.x4=x+[d1 d2];
patch2d.center=(patch2d.x1+patch2d.x2+patch2d.x3+patch2d.x4)./4;
patch2d.P=P;
end