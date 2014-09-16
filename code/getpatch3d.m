function bbox_3d=getpatch3d(P,d,X0)
% X is the image of 3dPoints corresponding to the points in the image



[K R t]=decomposeP(P);
D=R(3,:)*(X0-t);

dXx=R'*[1 0 0]'.*D./K(1,1);
dXy=R'*[0 1 0]'.*D./K(2,2);

bbox_3d=zeros(4,3);
bbox_3d(1,:)=X0-d.*dXx-d.*dXy;
bbox_3d(2,:)=X0-d.*dXx+d.*dXy;
bbox_3d(3,:)=X0+d.*dXx-d.*dXy;
bbox_3d(4,:)=X0+d.*dXx+d.*dXy;

% patch3d.isValid=D>5;
% patch2d.isValid=D>5;

end