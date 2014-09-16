function [X P]=getPositionFromFaces(F,camera,imageSize,vertices,faces)

P=getViewpoint(camera);
isValidMap=F~=0;
%% new X
% Get grid of 2D points:
[x,y] = meshgrid(1:imageSize(2),1:imageSize(1));
x = [x(:) y(:) ones(numel(x),1)]';
x = single(x);

D = P(:,1:3)\x;
n = find(isValidMap);
% Get ray directions:
if(~isempty(n))
    % Intersect 3D rays with triangles:
    [Xt] = IntersectTriangle(vertices,faces(:,F(n)),D(:,n),camera.C);
else
    Xt=[];
end
X = zeros(size(F,1),size(F,2),3);
Xo = zeros(size(F,1),size(F,2)); Yo = Xo; Zo = Xo;
if(~isempty(Xt))
    Xo(isValidMap) = Xt(1,:); Yo(isValidMap) = Xt(2,:); Zo(isValidMap) = Xt(3,:);
end
X(:,:,1) = Xo; X(:,:,2) = Yo; X(:,:,3) = Zo;