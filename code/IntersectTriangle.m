function [X,isValid,lambda,w] = IntersectTriangle(vertices,faces,D,C)
% Inputs:
% vertices - 3xM
% faces - 3xN
% D - 3xN
% C - 3x1
%
% Outputs:
% X - 3xN
% isValid - 1xN
% lambda - 1xN

N = size(faces,2);
v1 = vertices(:,faces(1,:)); % 3*N
v2 = vertices(:,faces(2,:));
v3 = vertices(:,faces(3,:));

% Compute triangle face directions:
aa = v1-v3;
bb = v2-v3;

% Get triangle origin:
cc = v3;

% Compute normal vectors for each triangle (b CROSS a):
normals = [aa(3,:).*bb(2,:)-aa(2,:).*bb(3,:); ...
           aa(1,:).*bb(3,:)-aa(3,:).*bb(1,:); ...
           aa(2,:).*bb(1,:)-aa(1,:).*bb(2,:)];
% $$$ normals = cross(bb,aa);

% Pre-compute numerator for lambda (for speed):
lambda_num = normals(1,:).*(cc(1,:)-C(1)) + normals(2,:).*(cc(2,:)-C(2)) + normals(3,:).*(cc(3,:)-C(3));

% Get dominant axis for each triangle face:
[v,Waxis] = max(abs(normals),[],1);

% Get minor axes for each triangle face:
Uaxis = mod(Waxis,3)+1;
Vaxis = mod(Uaxis,3)+1;

% Get camera center coordinates along minor axes:
Cu = C(Uaxis)';
Cv = C(Vaxis)';

% Get Barycentric variables:
uu = Uaxis+3*[0:N-1];
vv = Vaxis+3*[0:N-1];
ww = Waxis+3*[0:N-1];
norm = aa(uu).*bb(vv)-aa(vv).*bb(uu);
bnu = aa(uu)./norm;
bnv = -aa(vv)./norm;
cnu = bb(vv)./norm;
cnv = -bb(uu)./norm;

% Normalize normal vectors along dominant axis:
normals(uu) = normals(uu)./normals(ww);
normals(vv) = normals(vv)./normals(ww);

% Normalize numerator along dominant axis:
lambda_num = lambda_num./normals(ww);

nu = normals(uu);
nv = normals(vv);
vvu = cc(uu);
vvv = cc(vv);

% Get direction along different axes:
Du = D(uu);
Dv = D(vv);
Dw = D(ww);

% Get distance to triangles:
lambda = lambda_num./(Dw+nu.*Du+nv.*Dv);

% Get 3D intersection of ray and plane passing through each face:
Pu = Cu + lambda.*Du - vvu;
Pv = Cv + lambda.*Dv - vvv;

% Get barycentric coordinates:
w2 = bnu.*Pv+bnv.*Pu;
w1 = cnu.*Pu+cnv.*Pv;
w3 = 1-w1-w2;

isValid = (w1>=0)&(w1<=1)&(w2>=0)&(w2<=1)&(w3>=0)&(w3<=1);


% Adjust barycentric coordinates to be in range:
% $$$ keyboard; % n=10652
n = find(w1<0);
if(~isempty(n))
    uu = w2(n)+w1(n).*sum((v1(:,n)-v3(:,n)).*(v2(:,n)-v3(:,n)))./sum((v2(:,n)-v3(:,n)).^2);
    nn = find((0<=uu)&(uu<=1));
    if(~isempty(nn))
        w2(n(nn)) = uu(nn); w3(n(nn)) = 1-uu(nn); w1(n(nn)) = 0;
    end
end

n = find(w2<0);
if(~isempty(n))
    uu = w3(n)+w2(n).*sum((v2(:,n)-v1(:,n)).*(v3(:,n)-v1(:,n)))./sum((v3(:,n)-v1(:,n)).^2);
    nn = find((0<=uu)&(uu<=1));
    if(~isempty(nn))
        w3(n(nn)) = uu(nn); w1(n(nn)) = 1-uu(nn); w2(n(nn)) = 0;
    end
end

n = find(w3<0);
if(~isempty(n))
    uu = w1(n)+w3(n).*sum((v3(:,n)-v2(:,n)).*(v1(:,n)-v2(:,n)))./sum((v1(:,n)-v2(:,n)).^2);
    nn = find((0<=uu)&(uu<=1));
    if(~isempty(nn))
        w1(n(nn)) = uu(nn); w2(n(nn)) = 1-uu(nn); w3(n(nn)) = 0;
    end
end

n = find((w1<0)|(w2<0)|(w3<0));
if(~isempty(n))
    [vv,nn] = max([w1(n); w2(n); w3(n)],[],1);
    w1(n) = 0; w2(n) = 0; w3(n) = 0;
    if(~isempty(nn))
        w1(n(nn==1)) = 1; w2(n(nn==2)) = 1; w3(n(nn==3)) = 1;
    end
end

w = [w1; w2; w3];

% $$$ n = find((w1>0)&(w2<0)&(w3<0));
% $$$ w1(n) = 1; w2(n) = 0; w3(n) = 0;
% $$$ n = find((w1<0)&(w2>0)&(w3<0));
% $$$ w1(n) = 0; w2(n) = 1; w3(n) = 0;
% $$$ n = find((w1<0)&(w2<0)&(w3>0));
% $$$ w1(n) = 0; w2(n) = 0; w3(n) = 1;

% Get 3D coordinates:
X = zeros(3,N,class(lambda));
X(1,:) = w1.*v1(1,:)+w2.*v2(1,:)+w3.*v3(1,:);
X(2,:) = w1.*v1(2,:)+w2.*v2(2,:)+w3.*v3(2,:);
X(3,:) = w1.*v1(3,:)+w2.*v2(3,:)+w3.*v3(3,:);

% $$$ X = zeros(3,N,class(lambda));
% $$$ X(1,:) = C(1)+lambda.*D(1,:);
% $$$ X(2,:) = C(2)+lambda.*D(2,:);
% $$$ X(3,:) = C(3)+lambda.*D(3,:);


% $$$ keyboard;

doDisplay = 0;
if doDisplay
  display([w1 w2 w3]);

  v = vertices;
  d = D;
  sc = -100;
  figure;
  plot3(v(1,:),v(2,:),v(3,:),'r+');
  hold on;
  plot3([v(1,:) v(1,1)],[v(2,:) v(2,1)],[v(3,:) v(3,1)],'r');
  plot3([C(1) C(1)+sc*d(1)],[C(2) C(2)+sc*d(2)],[C(3) C(3)+sc*d(3)],'b');
  plot3(C(1),C(2),C(3),'go');
  axis([min(v(1,:)) max(v(1,:)) min(v(2,:)) max(v(2,:)) min(v(3,:)) max(v(3,:))]);
  plot3(X(1),X(2),X(3),'go');
end
