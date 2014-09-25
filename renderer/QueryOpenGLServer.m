function [imgRender,X,isValidMap,faceMap,W] = QueryOpenGLServer(P,imageSize,pipeName,vertices,faces,options)
% Inputs:
% P - 3x4 camera matrix
% imageSize - Image size [M N]
% pipeName - Name of OpenGL server pipe.
% vertices
% faces
%
% Outputs:
% imgRender - Rendered image.
% X - MxNx3 matrix of 3D points.
% isValidMap - MxN binary map of pixels with valid 3D points.
% faceMap - MxN indices corresponding to triangle faces for valid 3D points.
%
% Example 1: Render an image:
% img = QueryOpenGLServer(P,imageSize,pipeName);
%
% Example 2: Get 

% CAM_FILE (P)
% OUT_PNG_FILE_NAME
% OUT_PNG_RENDER

if ~exist('options','var')
    options = struct;
end
if ~isfield(options,'bg_color')
    options.bg_color = [1 1 1];
end

% Get temporary file names:
tname = tempname;
tcam_fname = [tname '.txt']; % Camera matrix
tout_fname = [tname '.ppm']; % 3D info output
tren_fname = [tname '.png']; % Render output

% Make sure camera matrix is correct type:
P = single(P);

% Write camera matrix:
PtoOpenGL(tcam_fname,imageSize,P,options);

% Write arguments to OpenGL server:
fp = fopen(pipeName,'w');
fprintf(fp,'%s %s %s END',tcam_fname,tout_fname,tren_fname);
fclose(fp);

loop_wait = 1;
while loop_wait
  fp = fopen(pipeName,'r');
  if fp~=-1
    tline = fgets(fp);
    fclose(fp);
    
    if ~isempty(strfind(tline,'SERVER_DONE'))
      loop_wait = 0;
      
      % Get output map:
      imgDepth = int32(imread(tout_fname));
%      imgDepth(1,:,:) = 0; imgDepth(:,1,:) = 0; % Hack!
      imgRender = imread(tren_fname);
      
      % Clean up temporary files:
      delete(pipeName);
      delete(tcam_fname);
      delete(tout_fname);
      delete(tren_fname);

      % Get depth information:
      [X,isValidMap,faceMap,W] = ParseDepths(P,imgDepth,vertices,faces);
      
      % Get back-facing pixels:
      isBackFacing = GetBackFacing(isValidMap,faceMap,P,vertices,faces);

      % Make back-facing pixels match background color:
      [nrows,ncols,ncc] = size(imgRender);
      imgRender(logical(cat(3,isBackFacing,zeros(nrows,ncols,2)))) = uint8(255*options.bg_color(1));
      imgRender(logical(cat(3,zeros(nrows,ncols,1),isBackFacing,zeros(nrows,ncols,1)))) = uint8(255*options.bg_color(2));
      imgRender(logical(cat(3,zeros(nrows,ncols,2),isBackFacing))) = uint8(255*options.bg_color(3));

      % Mask out back-facing pixels:
      isValidMap(isBackFacing) = false;
      faceMap(isBackFacing) = 0;
      X(repmat(isBackFacing,[1 1 3])) = 0;
    
    elseif ~isempty(strfind(tline,'ERROR'))
      error(tline);
    end
  end
end

return;


function isBackFacingMap = GetBackFacing(isValidMap,faceMap,P,vertices,faces)

% Get two vectors for face:
f = faces(:,faceMap(isValidMap));
v1 = vertices(:,f(1,:));
v2 = vertices(:,f(2,:));
v3 = vertices(:,f(3,:));
norm = cross(v2-v1,v3-v1);

[K,R,C] = decomposeP(P);
camdir = repmat(C,1,size(v1,2))-v1;

isBackFacing = (sum(norm.*camdir,1)<=0);

% Create binary map:
n = find(isValidMap);
isBackFacingMap = logical(zeros(size(isValidMap)));
isBackFacingMap(n(isBackFacing)) = 1;

return;


function [X,isValidMap,faceMap,W] = ParseDepths(P,img,vertices,faces)
  
imageSize = size(img);
%figure;
%imshow(img);
[K,R,C] = decomposeP(P);

% Get grid of 2D points:
[x,y] = meshgrid(1:imageSize(2),1:imageSize(1));
x = [x(:) y(:) ones(prod(size(x)),1)]';
x = single(x);

% Decode colors:
faceMap = img(:,:,1)+256*img(:,:,2)+256^2*img(:,:,3);

% Get valid pixels and indices:
isValidMap = (faceMap~=0);
n = find(isValidMap);
% $$$ figure;
% $$$ imshow(isValidMap);

% Get ray directions:
D = P(:,1:3)\x;


if(~isempty(n))
% Intersect 3D rays with triangles:
[Xt,isValid,lambda,w] = IntersectTriangle(vertices,faces(:,faceMap(n)),D(:,n),C);
else
    Xt=[];
    isValid=[];
   % lambda=[];
    w=[];
end
% Display invalid point stats:
printDetails=false;
if printDetails
    display(sprintf('Fraction invalid: %d/%d',sum(~isValid),length(isValid)));
end

% Display reprojection error:
xv = project3D2D(P,Xt);
if printDetails && ~isempty(n)
    display(sprintf('Max error: %f; mean error: %f',max(sum((x(1:2,n)-xv).^2,1).^0.5),mean(sum((x(1:2,n)-xv).^2,1).^0.5)));
end

% Form output 3D points:
X = zeros(size(faceMap,1),size(faceMap,2),3,'single');
Xo = zeros(size(faceMap,1),size(faceMap,2),'single'); Yo = Xo; Zo = Xo;
if(~isempty(Xt))
Xo(isValidMap) = Xt(1,:); Yo(isValidMap) = Xt(2,:); Zo(isValidMap) = Xt(3,:);
end
X(:,:,1) = Xo; X(:,:,2) = Yo; X(:,:,3) = Zo;

% Form output barycentric coordinates:
W = zeros(size(faceMap,1),size(faceMap,2),3,'single');
Xo = zeros(size(faceMap,1),size(faceMap,2),'single'); Yo = Xo; Zo = Xo;
if(~isempty(w))
Xo(isValidMap) = w(1,:); Yo(isValidMap) = w(2,:); Zo(isValidMap) = w(3,:);
end
W(:,:,1) = Xo; W(:,:,2) = Yo; W(:,:,3) = Zo;

doDisplay = 0;
if doDisplay
  keyboard;

  nBad = find(~isValid);
  
  figure;
  for ii = 1:25
% $$$   ndxFace = ii;
    ndxFace = nBad(ii);
    jj = mod(ii-1,25)+1;
    
    % Get a ray and face:
    d = D(:,n(ndxFace));
    f = faces(:,faceMap(n(ndxFace)));
    v = vertices(:,f);
    
    subplot(5,5,jj);
    imshow(isValidMap);
    hold on;
    xp = x(1,n(ndxFace));
    yp = x(2,n(ndxFace));
    plot(xp,yp,'gx');
    plot(xv(1,ndxFace),xv(2,ndxFace),'bs');
    xx = project3D2D(P,v);
    plot([xx(1,:) xx(1,1)],[xx(2,:) xx(2,1)],'r');
    plot(xx(1,:),xx(2,:),'r+');
% $$$     axis([xp-0.5 xp+0.5 yp-0.5 yp+0.5]);
% $$$     axis([xp-2 xp+2 yp-2 yp+2]);
    
    drawnow;
  end
end

% Get rendered viewpoint:
% $$$ img = meshGenerateColored(P,MESH_NAME,imageSize,BIN_PATH);
% $$$ img = imread('nacho.png');
