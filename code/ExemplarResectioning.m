function [P,nInliers] = ExemplarResectioning(K,X,x,inlierThresh,Niter)

% Parameters:
if nargin < 5
  Niter = 1000;
end
allP=[];
N = size(x,2);

if size(X,1) < 4
  X = [X; ones(1,N)];
end
if size(x,1) < 3
  x = [x; ones(1,N)];
end

P = [];
nInliers = [];
for i = 1:Niter
    if mod(i, 10000)==0
        fprintf('   %i iterations on %i \n',i,Niter);
    end
  % Get random set of points:
  rp = randperm(N);
  n = rp(1:3);

  % Make sure image and world points are unique:
  if size(unique(x(:,n)','rows'),1) ~= length(n)
    continue;
  end
  if size(unique(X(:,n)','rows'),1) ~= length(n)
    continue;
  end
%try
  allP = fast_estimate_RC_v2(K,x(:,n),X(:,n));
 % catch err
%end
  if ~isempty(allP)
    for j = 1:size(allP,3)
      Pi = squeeze(allP(:,:,j));

      n = find(sum((project3D2D(Pi,X)-x(1:2,:)).^2,1) <= inlierThresh.^2);
      if length(n) > length(nInliers)
        nInliers = n;
        P = Pi;
      end
      
    end
  end
  
end
