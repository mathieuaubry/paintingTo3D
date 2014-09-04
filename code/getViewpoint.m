function P = getMathieuViewpoint(CameraStruct,i,imageSize)
% Inputs:
% CameraStruct - Set of sampled viewpoints
% i - Index of sampled viewpoint
% imageSize - Painting size
%
% Outputs:
% P - Camera matrix
if nargin<3
    imageSize(1)=CameraStruct(i).nrows;
    imageSize(2)=CameraStruct(i).ncols;
end

            P = [-1 0 imageSize(2); 0 1 1; 0 0 1]*CameraStruct(i).K*CameraStruct(i).R*[eye(3) -CameraStruct(i).C];
