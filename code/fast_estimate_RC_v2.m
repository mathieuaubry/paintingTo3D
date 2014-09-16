function P = fast_estimate_RC_v2(K,x,X)
% This function recovers the camera rotation matrix R and camera center C
% given the calibration matrix K and 3 2D/3D correspondences x<->X.
%
% Solution is outlined in the following paper:
% http://www.haralick.org/journals/three_point_perspective.pdf
%
% Inputs: 
% K - Camera calibration matrix
% x - Image points (2x3, column vectors)
% X - World points (3x3, column vectors)
%
% Outputs:
% P - 3x4 camera matrix
% R - 3x3 camera rotation
% C - 3x1 camera center

% Parameters:
do_display = 0;

N = 3;
x = x(:,1:N);
X = X(:,1:N);

% Convert to homogeneous coordinates:
if size(x,1) < 3
  x = [x; ones(1,N)];
end
if size(X,1) < 4
  X = [X; ones(1,N)];
end

% Get points:
u1 = x(:,1);
u2 = x(:,2);
u3 = x(:,3);
X1 = X(1:3,1);
X2 = X(1:3,2);
X3 = X(1:3,3);

% Compute angles between points:
% cos(ang) = xi'*inv(K*K')*xj/sqrt(xi'*inv(K*K')*xi)/sqrt(xj'*inv(K*K')*xj)
C = inv(K*K');
alpha = acos(u2'*C*u3/sqrt((u2'*C*u2)*(u3'*C*u3)));
beta = acos(u1'*C*u3/sqrt((u1'*C*u1)*(u3'*C*u3)));
gamma = acos(u1'*C*u2/sqrt((u1'*C*u1)*(u2'*C*u2)));

% Compute distances between 3D points:
a = sqrt(sum((X2-X3).^2));
b = sqrt(sum((X1-X3).^2));
c = sqrt(sum((X1-X2).^2));

% Goal: compute distances from camera center to each of the 3D points.
% These distances are denoted by s1, s2, s3.
%
% By law of cosines:
% s2^2 + s3^2 - 2*s2*s3*cos(alpha) = a^2
% s1^2 + s3^2 - 2*s1*s3*cos(beta) = b^2
% s1^2 + s2^2 - 2*s1*s2*cos(gamma) = c^2
%
% Let s2 = u*s1 and s3 = v*s1.  Then can convert law of cosine
% constraints in terms of u and v:
%
% constraint 1: 
% u^2 + (b^2-a^2)*v^2/b^2 - 2*u*v*cos(alpha) + 2*a^2*v*cos(beta)/b^2 - a^2/b^2 = 0
% constraint 2:
% u^2 - c^2*v^2/b^2 + 2*v*c^2*cos(beta)/b^2 - 2*u*cos(gamma) + (b^2-c^2)/b^2 = 0
%
% Finsterwalder's solution (1903). Start by multiplying constraint 2
% by lambda and add to constraint 1 to get:
%
% A*u^2 + 2*B*u*v + C*v^2 + 2*D*u + 2*E*v + F = 0
%
% Note that the coefficients depend on lambda.  This constraint is
% quadratic in v (written in terms of u and lambda).  Solving for v yields:
%
% v_large = -sign(B*u+E)/C * (abs(B*u+E) + 
%            sqrt((B^2-A*C)*u^2 + 2*(B*E-C*D)*u +E^2-C*F))
% v_small = C/A/v_large
%
% Goal is to find lambda that makes the following be a perfect square:
% (B^2-A*C)*u^2 + 2*(B*E-C*D)*u +E^2-C*F  (Equation A)
% When this is a perfect square, then v is linear in u.  This can then be
% substitute into constraint 1 or 2 and is quadratic in u.
%
% To find the lambda that makes Equation A be a perfect square, this can
% be written as:
% det([A B D; B C E; D E F]) = 0
% 
% This is cubic equation in lambda:
% G*lambda^3 + H*lambda^2 + I*lambda + J = 0

% Find roots of cubic:
% G*lambda^3 + H*lambda^2 + I*lambda + J = 0
G = c^2*(c^2*sin(beta)^2-b^2*sin(gamma)^2);
H = b^2*(b^2-a^2)*sin(gamma)^2+c^2*(c^2+2*a^2)*sin(beta)^2+2*b^2*c^2*(-1+cos(alpha)*cos(beta)*cos(gamma));
I = b^2*(b^2-c^2)*sin(alpha)^2+a^2*(a^2+2*c^2)*sin(beta)^2+2*a^2*b^2*(-1+cos(alpha)*cos(beta)*cos(gamma));
J = a^2*(a^2*sin(beta)^2-b^2*sin(alpha)^2);
lambda = roots([G H I J]);

% Get real roots:
n = find(~imag(lambda));
if length(n)==0
  display('no real lambda');
  keyboard;
end
lambda = lambda(n);

A = 1+lambda;
B = -cos(alpha);
C = (b^2-a^2)/b^2-lambda*c^2/b^2;
D = -lambda*cos(gamma);
E = (a^2/b^2+lambda*c^2/b^2)*cos(beta);
F = -a^2/b^2+lambda*((b^2-c^2)/b^2);

val = B^2-A.*C;

if ~isreal(val)
  display('val is not real');
  keyboard;
end

[vv,nn] = max(val);
if vv < 0
  P = [];
  return;
end
A = A(nn); C = C(nn); D = D(nn); E = E(nn); F = F(nn);

if do_display
  C*D^2+B^2*F+A*E^2-2*B*D*E-A*C*F % Sanity check...should be zero
end

u = [];
v = [];

if (B^2-A*C)>=0
  % Option 1 (use +v):
  U = 1-c^2/b^2*(sqrt(B^2-A*C)-B)^2/C^2;
  V = -2*c^2/b^2*((B*E-C*D)/C/sqrt(B^2-A*C)-E/C)*(sqrt(B^2-A*C)-B)/C+2*(sqrt(B^2-A*C)-B)/C*c^2/b^2*cos(beta)-2*cos(gamma);
  W = (2*(B*E-C*D)/C/sqrt(B^2-A*C)-2*E/C)*c^2/b^2*cos(beta)-c^2/b^2*((B*E-C*D)/C/sqrt(B^2-A*C)-E/C)^2+(b^2-c^2)/b^2;

  if ~isreal(U) || ~isreal(V) || ~isreal(W)
    P = [];
    return;
% $$$     display('U,V,W not real');
% $$$     keyboard;
  end
  
  if (V^2-4*U*W)>=0
    u = real([(-V+sqrt(V^2-4*U*W))/2/U (-V-sqrt(V^2-4*U*W))/2/U]);
    v = real((sqrt(B^2-A*C)-B)/C*u+(B*E-C*D)/C/sqrt(B^2-A*C)-E/C);
  end

  % Option 2 (use -v):
  U = 1-c^2/b^2*(-sqrt(B^2-A*C)-B)^2/C^2;
  V = -2*c^2/b^2*(-(B*E-C*D)/C/sqrt(B^2-A*C)-E/C)*(-sqrt(B^2-A*C)-B)/C+2*(-sqrt(B^2-A*C)-B)/C*c^2/b^2*cos(beta)-2*cos(gamma);
  W = (-2*(B*E-C*D)/C/sqrt(B^2-A*C)-2*E/C)*c^2/b^2*cos(beta)-c^2/b^2*(-(B*E-C*D)/C/sqrt(B^2-A*C)-E/C)^2+(b^2-c^2)/b^2;
  
  if ~isreal(U) || ~isreal(V) || ~isreal(W)
    display('U,V,W not real');
    keyboard;
  end
  
  if (V^2-4*U*W)>=0
    uu = real([(-V+sqrt(V^2-4*U*W))/2/U (-V-sqrt(V^2-4*U*W))/2/U]);
    v = [v real((-sqrt(B^2-A*C)-B)/C*uu-(B*E-C*D)/C/sqrt(B^2-A*C)-E/C)];
    u = [u uu];
  end
end

if ~isreal(u) || ~isreal(v)
  display('After: u or v is not real');
  keyboard;
end

n = find((u>0)&(v>0));
if isempty(n)
  P = [];
  return;
end

u = u(n);
v = v(n);

% Compute s1,s2,s3 (distance from camera center to 3D points):
s1 = sqrt(a^2./(u.^2+v.^2-2*u.*v*cos(alpha)));
s2 = u.*s1;
s3 = v.*s1;

if do_display
  % Sanity check (should be close to zero)
  s2.^2+s3.^2-2*s2.*s3*cos(alpha)-a^2
  s1.^2+s3.^2-2*s1.*s3*cos(beta)-b^2
  s1.^2+s2.^2-2*s1.*s2*cos(gamma)-c^2
end

P = zeros(3,4,length(s1));
for i = 1:length(s1)
  % Get points:
  p1 = inv(K)*u1;
  p2 = inv(K)*u2;
  p3 = inv(K)*u3;
  p1 = s1(i)*p1/sqrt(p1'*p1);
  p2 = s2(i)*p2/sqrt(p2'*p2);
  p3 = s3(i)*p3/sqrt(p3'*p3);
% $$$   p1 = -s1(i)*p1/sqrt(p1'*p1);
% $$$   p2 = -s2(i)*p2/sqrt(p2'*p2);
% $$$   p3 = -s3(i)*p3/sqrt(p3'*p3);

  % Align p1,p2,p3 and X1,X2,X3 via 3D transformation
  x = [p1 p2 p3];
  X = [X1 X2 X3];

  % Center data:
  xmu = mean(x,2);
  Xmu = mean(X,2);
  x = x-repmat(xmu,1,N);
  X = X-repmat(Xmu,1,N);

  %%%%% NEW BEGIN
  if any(isinf(x(:))) || any(isnan(x(:))) || any(isinf(X(:))) || any(isnan(X(:)))
    continue;
  end
  
  % Compute SVD of data:
  [U1,S1,V1] = svd(x);
  [U2,S2,V2] = svd(X);
  
  % Get rotation to align principal directions:
  n1 = cross(x(:,2)-x(:,1),x(:,3)-x(:,1));
  n1 = n1/sqrt(n1'*n1);
  n2 = cross(X(:,2)-X(:,1),X(:,3)-X(:,1));
  n2 = n2/sqrt(n2'*n2);
% $$$   n1 = cross(U1(:,1),U1(:,2));
% $$$   n2 = cross(U2(:,1),U2(:,2));
  n = cross(n1,n2);
  n = n/sqrt(n'*n);
  b1 = n1;
  b2 = cross(n,b1);
  dt = -atan2(n2'*b2,n2'*b1);
  W = [0 -n(3) n(2); n(3) 0 -n(1); -n(2) n(1) 0];
  Rn = eye(3) + sin(dt)*W + (1-cos(dt))*W*W;

  % Align in plane perpendicular to principal axis:
  XX = Rn*X;
  xx = x;
  n = n1;
  bb = null(n');
  b1 = bb(:,1);
  b2 = cross(n,b1);
  b2 = b2/sqrt(b2'*b2);
% $$$   b2 = bb(:,2);
  if ~isreal(b1) || ~isreal(b2)
    display('b1 or b2 is not real');
    keyboard;
  end
  dt = atan2(b2'*xx,b1'*xx)-atan2(b2'*XX,b1'*XX);
% $$$   dt = atan2(b2'*XX,b1'*XX)-atan2(b2'*xx,b1'*xx);

  if do_display
    dt
    
    % Uncomment this to plot points:
% $$$     figure;
% $$$     plot(b1'*xx,b2'*xx,'bo');
% $$$     hold on;
% $$$     plot(b1'*XX,b2'*XX,'r+');
% $$$     plot([b1'*xx; b1'*XX],[b2'*xx; b2'*XX],'g');
  end
  
  dt = median(dt);
  W = [0 -n(3) n(2); n(3) 0 -n(1); -n(2) n(1) 0];
  Rn2 = eye(3) + sin(dt)*W + (1-cos(dt))*W*W;

  if do_display
    Rn2*XX
    x
  end
  %%%%% NEW END
  
% $$$   n = cross(X(:,1),x(:,1));
% $$$   n = n/sqrt(n'*n);
% $$$   b1 = x(:,1);
% $$$   b1 = b1/sqrt(b1'*b1);
% $$$   b2 = cross(n,b1);
% $$$   dt = -atan2(X(:,1)'*b2,X(:,1)'*b1);
% $$$   W = [0 -n(3) n(2); n(3) 0 -n(1); -n(2) n(1) 0];
% $$$   Rn = eye(3) + sin(dt)*W + (1-cos(dt))*W*W;
% $$$   Rn*X(:,1)
% $$$   x(:,1)
% $$$   
% $$$   XX2 = Rn*X(:,2);
% $$$   xx2 = x(:,2);
% $$$   n = x(:,1);
% $$$   n = n/sqrt(n'*n);
% $$$   bb = null(n');
% $$$   b1 = bb(:,1);
% $$$   b2 = bb(:,2);
% $$$   dt = atan2(xx2'*b2,xx2'*b1)-atan2(XX2'*b2,XX2'*b1);
% $$$   W = [0 -n(3) n(2); n(3) 0 -n(1); -n(2) n(1) 0];
% $$$   Rn2 = eye(3) + sin(dt)*W + (1-cos(dt))*W*W;
% $$$   Rn2*XX2
% $$$   xx2
  
  R = Rn2*Rn;
  t = xmu-R*Xmu;
  
  if do_display
    % Sanity check (should be equal):
    R*X
    x

    % Sanity checks (should be equal):
    [R t]*[[X1 X2 X3]; 1 1 1]
    [p1 p2 p3]
  end
  
  P(:,:,i) = K*[R t];
end


return;

addpath ~/work/Archaeology/BundlerToolbox_v03;
addpath ./sc_demo;
addpath ~/work/Archaeology/MeshCode/ToolboxCopy;
addpath ~/work/Archaeology/MeshCode;
addpath ~/work/MatlabLibraries/BerkeleyPB;
addpath ~/work/Archaeology/MeshCode/EstimateCamera;

% "New2" trimmed
meshFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed.ply';
normalsFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/normal_smooth_12_pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed.ply';
holesFileName = '/Users/brussell/work/Archaeology/Data/3Dmodel/New2/pompeii_large66_sample_0.1_poisson_depth_14_clean_trimmed_holes.txt';

[vertices,faces] = mexReadPly(meshFileName);

% Get camera:
load /Users/brussell/work/Archaeology/Data/SynthesizeViewpoints/CameraStructVisible_v3.mat;

% Painting 02:
PAINTING_FNAME = '~/work/Archaeology/Data/Pompeii_images/PaintingScene/painting02.jpg';
% $$$ NEARBY_FRAME = 'GenerateLambertian/OUT/0000.ppm';
OUT_FNAME = 'corresp_painting02.mat';
cNdx = 2770; % Camera index
% $$$ cNdx = 2808; % Better viewpoint (not top gist match)
PAINTING_LINES = 'paintingLines02.mat';

% Painting:
imgPainting = imread(PAINTING_FNAME);

load(OUT_FNAME);

% Get camera matrix:
P = CameraStruct(cNdx).K*CameraStruct(cNdx).R*[eye(3) -CameraStruct(cNdx).C];
imageSize = [CameraStruct(cNdx).nrows CameraStruct(cNdx).ncols];

% $$$ [imgLines,imgLines_rv,imgLines_occ] = meshLineDrawing(P,meshFileName,normalsFileName,holesFileName,imageSizePainting);

% Get 3D points:
[X,isValid] = getCorrespondences3d2d_v3(vertices,faces,P,x2,imageSize);

% Estimate camera parameters:
imageSizePainting = size(imgPainting);
Pest = estimateCamera3d2d(X,image2openglcoordinates(x1,imageSizePainting),0,0);

[K,R,C] = decomposeP(Pest);

% $$$ addpath EPnP;

% Estimate camera matrix:
ndx = [1 5 6];%1:3;
ndx = 1:3;
ndx = [11 10 1];
for i = 1:100
  rp = randperm(size(X,2));
  ndx = rp(1:3);
  tic; allP = fast_estimate_RC_v2(K,image2openglcoordinates(x1(:,ndx),imageSizePainting),X(:,ndx)); toc

  if size(allP,3)==0
    clf;
    title(imgPainting);
    title('no camera matrix recovered');
    ginput(1);
  else
    for j = 1:size(allP,3)
      Pest2 = squeeze(allP(:,:,j));
      
      % Project 3D points using estimated camera and display:
      xp = Pest2*[X; ones(1,size(X,2))];
      xp = [xp(1,:)./xp(3,:); xp(2,:)./xp(3,:)];
      xp(1,:) = imageSizePainting(2)-xp(1,:);
      xp(2,:) = xp(2,:)+1;
      clf;
      imshow(imgPainting);
      hold on;
      plot(xp(1,:),xp(2,:),'r+');
      plot(x1(1,:),x1(2,:),'bo');
      plot([xp(1,:); x1(1,:)],[xp(2,:); x1(2,:)],'g');
      plot(x1(1,ndx),x1(2,ndx),'ms');
      title(sprintf('%d out of %d',j,size(allP,3)));
      
      ginput(1);
    end
  end
end

[imgLines,imgLines_rv,imgLines_occ] = meshLineDrawing(Pest2,meshFileName,normalsFileName,holesFileName,imageSizePainting);


[a1,b1,c1] = decomposeP(Pest2);
PP = estimateCamera3d2d_K_geometric(a1,b1,c1,X,image2openglcoordinates(x1,imageSizePainting));
