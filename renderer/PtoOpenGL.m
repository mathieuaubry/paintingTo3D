function PtoOpenGL(filename,imageSize,P,options)
% Inputs:
% filename
% imageSize
% K
% R
% C

if ~exist('options','var')
    options = struct;
end
if ~isfield(options,'bg_color')
    options.bg_color = [1 1 1];
end

doDisplay=false;

% $$$ doThis = 1;
% $$$ if doThis
% $$$   % Decompose camera matrix:
% $$$   [K,R,C] = decomposeP(P);
% $$$ 
% $$$   % Transform to OpenGL coordinates:
% $$$   T = [1 0 imageSize(2); 0 1 -1; 0 0 1];
% $$$   K = T*K;
% $$$   R = [1 0 0; 0 -1 0; 0 0 -1]*R;
% $$$   
% $$$   % Get intrinsic parameters:
% $$$   px = K(7);
% $$$   py = K(8);
% $$$   nrows = imageSize(1);
% $$$   ncols = imageSize(2);
% $$$   focal = mean(K([1 5])); % Need to handle non-square, skew pixels...
% $$$   
% $$$   % Get extrinsic camera matrix:
% $$$   P = [R -R*C]';
% $$$ else

% Transform to OpenGL coordinates:
% $$$ T = [-1 0 imageSize(2)/2; 0 1 -1+imageSize(1)/2; 0 0 1];
T = [1 0 -1; 0 -1 imageSize(1); 0 0 1];
% $$$ T = [-1 0 imageSize(2); 0 1 -1; 0 0 1];
% $$$ P = T*P;

% Decompose camera matrix:
[K,R,C] = decomposeP(P);

K = T*K;
% $$$ K(1) = -K(1);
K(5) = -K(5);
R = [1 0 0; 0 -1 0; 0 0 -1]*R;

% Get intrinsic parameters:
skew = -K(4);
px = K(7);
py = K(8);
nrows = imageSize(1);
ncols = imageSize(2);
% $$$ focal = mean(K([1 5])); % Need to handle non-square, skew pixels...

% Get extrinsic camera matrix:
P = [R -R*C]';
% $$$ end

if doDisplay
    display(sprintf('Intrinsics (focal_x,focal_y,px,py,skew): (%f,%f,%f,%f,%f)',K(1),K(5),px,py,skew));
end
% Write camera matrix:
fp = fopen(filename,'w');
fprintf(fp,'%f ',P);
fprintf(fp,'%d %d %f %f %f %f %f %f %f %f',nrows,ncols,K(1),K(5),px,py,skew,options.bg_color(1),options.bg_color(2),options.bg_color(3));
if doDisplay
    display(sprintf('%d %d %f %f %f %f %f %f %f %f',nrows,ncols,K(1),K(5),px,py,skew,options.bg_color(1),options.bg_color(2),options.bg_color(3)));
end
fclose(fp);

return;


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
