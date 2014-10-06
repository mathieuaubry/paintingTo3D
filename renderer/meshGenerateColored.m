function img = meshGenerateColored(P,meshFileName,imageSize,options)
% Inputs:
% P - Camera matrices (3x4xK).
% meshFileName - Path to mesh PLY file.
% imageSize - Desired image size [M N].
%
% Outputs:
% img - Rendered images (MxNx3xK).

if ~exist('options','var')
    options = struct;
end
if ~isfield(options,'bg_color')
    options.bg_color = [1 1 1];
end

% Read mesh:
if isdir(meshFileName)
  [vertices,faces] = mexReadPly(fullfile(meshFileName,'full_model.ply'));
else
  [vertices,faces] = mexReadPly(meshFileName);
end

pipeName = StartOpenGLServer(meshFileName,imageSize);
for i = 1:size(P,3)
    img(:,:,:,i) = QueryOpenGLServer(squeeze(P(:,:,i)),imageSize,pipeName,vertices,faces,options);
end
StopOpenGLServer(pipeName);

return;
