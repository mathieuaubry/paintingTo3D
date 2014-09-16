function PtoOpenGL(filename,imageSize,K,R,C)
% Inputs:
% filename
% imageSize
% K
% R
% C

if nargin < 5
  [K,R,C] = decomposeP(K);
end

% Get principal point:
pp = image2openglcoordinates([K(7) K(8)]',imageSize);

nrows = imageSize(1);
ncols = imageSize(2);
focal = mean(K([1 5]));
P = [R -R*C]';

fp = fopen(filename,'w');
fprintf(fp,'%f ',P);
fprintf(fp,'%d %d %f %f %f',nrows,ncols,focal,pp(1),pp(2));
% $$$ fprintf(fp,'%d %d %f %f %f',nrows,ncols,focal,K(7),K(8));
% $$$ fprintf(fp,'%d %d %f %f %f',nrows,ncols,focal,ncols/2,nrows/2);
fclose(fp);