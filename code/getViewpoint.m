function P = getViewpoint(camera,imageSize)
% Inputs:
% camera
% imageSize - Painting size
%
% Outputs:
% P - Camera matrix
if nargin<3
    imageSize(1)=camera.nrows;
    imageSize(2)=camera.ncols;
end

            P = [-1 0 imageSize(2); 0 1 1; 0 0 1]*camera.K*camera.R*[eye(3) -camera.C];
