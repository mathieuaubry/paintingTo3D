function x = image2openglcoordinates(x,imageSize)
% Inputs:
% x - 2xN matrix
% imageSize
%
% Outputs:
% x

x(1,:) = imageSize(2)-x(1,:);
x(2,:) = x(2,:)-1;
