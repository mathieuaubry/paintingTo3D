function imgLam = meshGenerateColored(P,meshFileName,imageSize,BIN_PATH)
% Inputs:
% P - Camera matrices.
% meshFileName - Path to mesh PLY file.
% imageSize - Desired image size.
%
% Outputs:
% imgLam - Lambertian images.

% $$$ if nargin < 5
% $$$   BIN_PATH = '~/work/Archaeology/MeshCode/GenerateLambertian/generate_colored';
% $$$ end

Ncameras = size(P,3);

OUTDIR = './tmp';
mkdir(OUTDIR);
OUTDIR_CAMERAS = [OUTDIR '_cameras'];
OUTDIR_IMAGES = [OUTDIR '_images'];
cameras_filename = [OUTDIR '_cameras.txt'];
images_filename = [OUTDIR '_images.txt'];
mkdir(OUTDIR_CAMERAS);
mkdir(OUTDIR_IMAGES);

% Get OpenGL camera files and output image names:
fp_cameras = fopen(cameras_filename,'w');
fp_images = fopen(images_filename,'w');
outCameras = cell(1,Ncameras);
outFilenames = cell(1,Ncameras);
for i = 1:Ncameras
  opengl_filename = fullfile(OUTDIR_CAMERAS,sprintf('%08d.txt',i));
  PtoOpenGL(opengl_filename,imageSize,squeeze(P(:,:,i)));
  fprintf(fp_cameras,'%s\n',opengl_filename);
  outCameras{i} = opengl_filename;
  outFilenames{i} = fullfile(OUTDIR_IMAGES,sprintf('%08d.ppm',i));
  fprintf(fp_images,'%s\n',outFilenames{i});
end
fclose(fp_cameras);
fclose(fp_images);

% Run line drawing algorithm:
system(sprintf('%s %s %s %s',BIN_PATH,meshFileName,cameras_filename,images_filename));

% Read output images:
imgLam = zeros(imageSize(1),imageSize(2),3,Ncameras,'uint8');
for i = 1:Ncameras
  imgLam(:,:,:,i) = imread(outFilenames{i});
  delete(outFilenames{i});
  delete(outCameras{i});
end

% Delete temporary files:
delete(cameras_filename);
delete(images_filename);
rmdir(OUTDIR_CAMERAS);
rmdir(OUTDIR_IMAGES);

return;