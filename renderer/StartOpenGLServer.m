function [pipeName,logName] = StartOpenGLServer(meshName,BIN_OPENGL,imageSize)
% $$$ function pipeName = StartOpenGLServer(meshName,BIN_OPENGL,SH_SCRIPT)
% Inputs:
% meshName
% pipeName
% BIN_OPENGL
% SH_SCRIPT

nn = tempname;
pipeName = [nn '_pipe.txt'];
% $$$ logName = [nn '_log.txt'];
logName = '/tmp/foo_out.txt';

if ~exist(meshName,'file') && ~exist(meshName,'dir')
  error('Mesh does not exist.');
  pipeName = [];
  logName = [];
  return;
end

% Run OpenGL binary as background process:
if isdir(meshName)
  Ntextures = length(dir(fullfile(meshName,'model_*.ply')));
  system(sprintf('%s %s %s %d %d %s --texture %d &',BIN_OPENGL,meshName,pipeName,imageSize(1),imageSize(2),logName,Ntextures));
  display(sprintf('%s %s %s %d %d %s --texture %d &',BIN_OPENGL,meshName,pipeName,imageSize(1),imageSize(2),logName,Ntextures));
else
  system(sprintf('%s %s %s %d %d %s &',BIN_OPENGL,meshName,pipeName,imageSize(1),imageSize(2),logName));
end

% inside bash script
%   create pipe file
%   start opengl server as background process

% inside opgengl process
%   read mesh
%   loop and read named pipe
%   pipe message in: in 12345 other_info END
%   pipe message out: out 12345 other_info END
