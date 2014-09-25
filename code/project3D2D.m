function x = project3D2D(P,X,imageSize)

if size(X,1) < 4
  X = [X; ones(1,size(X,2))];
end

if ~isempty(X) && ~isempty(P)
  x = P*X;
  x = [x(1,:)./x(3,:); x(2,:)./x(3,:)];
else
  x = [];
end

return;


if size(X,1) < 4
  X = [X; ones(1,size(X,2))];
end

if ~isempty(X) && ~isempty(P)
  % Convert principal point to OpenGL coordinates:
  [K,R,C] = decomposeP(P);
  pp = image2openglcoordinates([K(7) K(8)]',imageSize);
  K(7) = pp(1);
  K(8) = pp(2);
  P = K*R*[eye(3) -C];
  
  x = P*X;
  x = [x(1,:)./x(3,:); x(2,:)./x(3,:)];

  % Convert from OpenGL coordinates to Matlab image coordinates:
  x(1,:) = imageSize(2)-x(1,:);
  x(2,:) = x(2,:)+1;

  x(1,:) = x(1,:)+1;
% $$$   x(2,:) = x(2,:)-1;
else
  x = [];
end
