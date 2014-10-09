function BuildTexturedModel(fname,OUTDIR)
% Inputs:
% fname - Input PLY file with texture coordinates.
% OUTDIR - Output directory to dump textured model.
%
% This function builds a textured model that will work with the rendering
% code.  Here are the steps to building the textured model.
%
% Step 1: Download Google Sketchup Pro.  ***You will have 8 hours free
% trial, so make sure to shut down the application after each use to
% conserve the time!***
%
% Step 2: Download a Sketchup model (model.skp).  You may want to adjust
% the file name to not have any special characters or spaces.
%
% Step 3: Open up the Sketchup model with Google Sketchup Pro.
%
% Step 4: File->Export->3D model.
%
% Step 5: A dialog box will appear.  Select "OBJ File (*.obj)" in the
% drop-down menu.  Then, click on the "Options" button.
%
% Step 6: Select the following buttons: "Triangulate all faces", "Export
% two-sided faces", "Export texture maps".  Leave the remaining buttons
% unselected.  Then click "OK".
%
% Step 7: Click the "Export" button to export the model to OBJ format.
%
% Step 8: Quit Google Sketchup Pro (conserve your time!).
%
% Step 9: Open "model.obj" with MeshLab.  You will see the textured
% model.
%
% Step 10: File->Export Mesh As.  
%
% Step 11: Save the file as a PLY file (model.ply).  A dialog window will
% appear showing save options.  Unselect everything *except*
% "Wedge+TexCoord".  Make sure that "Binary encoding" is *not* selected.
% Click "OK".
%
% Step 12:  Run Matlab and at the prompt, run the following:
%
% BuildTexturedModel('model.ply','out_model');
%
% Voila!  You should have a textured model.

fp = fopen(fname);

% Read in PLY header:
Nvertices = [];
Nfaces = [];
TextureFiles = [];
while 1
  tline = fgetl(fp);
  if ~isempty(regexp(tline,'^element vertex'))
    Nvertices = str2num(regexprep(tline,'^element vertex',''));
  elseif ~isempty(regexp(tline,'^element face'))
    Nfaces = str2num(regexprep(tline,'^element face',''));
  elseif ~isempty(regexp(tline,'^comment TextureFile '))
    TextureFiles{end+1} = regexprep(tline,'^comment TextureFile ','');
  elseif strcmp(tline,'end_header')
    break;
  end
end

% Read in vertices and face information:
vertices = single(fscanf(fp,'%f %f %f',[3 Nvertices]));
FaceInfo = fscanf(fp,'%d %d %d %d %d %f %f %f %f %f %f %d',[12 Nfaces]);

fclose(fp);

% Get face indices:
faces = int32(FaceInfo(2:4,:))+1;

% Get face texture coordinates:
textureCoordsX = single(FaceInfo(6:2:11,:));
textureCoordsY = single(FaceInfo(7:2:11,:));
textureCoords = single(FaceInfo(6:11,:));

% Get face texture file indices:
textureIndices = int32(FaceInfo(12,:))+1;

% Remove non-textured faces:
n = find(textureIndices==0);
faces(:,n) = [];
textureCoordsX(:,n) = [];
textureCoordsY(:,n) = [];
textureIndices(n) = [];
textureCoords(:,n) = [];


mkdir(OUTDIR);
out.vertices = []; out.faces = [];
for i = 1:length(TextureFiles)
  nf = find(textureIndices==i); % Indices of faces assigned to current texture
  nv = unique(faces(:,nf)); % Indices of vertices that touch current texture

  vv = vertices(:,nv);

  [aa,ff] = ismember(faces(:,nf),nv);
  ff = int32(ff);

  tx = zeros(1,length(nv),'single');
  ty = zeros(1,length(nv),'single');
  
  xx = textureCoordsX(:,nf);
  yy = textureCoordsY(:,nf);
  for j = 1:length(nv)
    n = find(ff==j);
    [xu,aa,bb] = unique([xx(n) yy(n)],'rows');

    tx(j) = xu(1,1); ty(j) = xu(1,2);
    for k = 2:size(xu,1)
      vv(:,end+1) = vv(:,j);
      ff(n(bb==k)) = size(vv,2);
      tx(end+1) = xu(k,1);
      ty(end+1) = xu(k,2);
    end
  end
  
  mexWritePly(fullfile(OUTDIR,sprintf('model_%04d.ply',i-1)),vv,ff);

  out.faces = [out.faces ff+size(out.vertices,2)];
  out.vertices = [out.vertices vv];

  fp = fopen(fullfile(OUTDIR,sprintf('./texture_coords_%04d.bin',i-1)),'wb');
  fwrite(fp,int32(size(vv,2)),'int32');
  fwrite(fp,[tx; ty],'single');
  fclose(fp);
  if ~exist(fullfile(OUTDIR,'textures'),'dir')
    mkdir(fullfile(OUTDIR,'textures'));
  end

  imgTmp = imread(TextureFiles{i});
  imgTmp = imresize(imgTmp,2.^floor(log([size(imgTmp,1) size(imgTmp,2)])/log(2)),'bicubic');
  imwrite(imgTmp,fullfile(OUTDIR,sprintf('textures/img_%04d.jpg',i-1)));
end

out.colors = 0.5*ones(3,size(out.vertices,2),'single');
mexWritePly(fullfile(OUTDIR,'full_model.ply'),out.vertices,out.faces,out.colors);

