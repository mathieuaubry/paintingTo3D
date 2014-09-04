clear all
OLD_DIR='/meleze/data1/maaubry/LargeScalePaintings/';%'/sequoia/data1/maaubry/LargeScalePaintings_siggraph/'
MODEL_DIRs={'cache_notre_dame_sample_100_up_10_angles_2_add_200/','cache_san_marco_sample_30_up_10_angles_2_add_100/','cache_trevi_sample_50_up_15_angles_2_add_200/','cache_venice_sample_100_up_10_angles_2_add_50/'};
for mid =1:length(MODEL_DIRs) %'cache_venice_sampling_100_angles_0_10/';
MODEL_DIR=MODEL_DIRs{mid};
old=load([OLD_DIR MODEL_DIR 'CameraStruct_visible_samples.mat'],'CameraStruct');
NEW_DIR='/meleze/data1/maaubry/paintings_release/';%'/sequoia/data1/maaubry/paintings_release/';
mkdir([NEW_DIR MODEL_DIR])
mkdir([NEW_DIR MODEL_DIR 'Views'])
mkdir([NEW_DIR MODEL_DIR 'Positions'])

CameraStruct=cell([1,length(old.CameraStruct)]);%struct('C',{});%
fprintf('\n00000')
for i=1:length(old.CameraStruct)
  fprintf('\b\b\b\b\b%05i',i);
%  CameraStruct{i}=struct;
  CameraStruct{i}.C=old.CameraStruct(i).C;
  CameraStruct{i}.R=old.CameraStruct(i).R;
  CameraStruct{i}.K=old.CameraStruct(i).K;
  CameraStruct{i}.nrows=old.CameraStruct(i).nrows;
  CameraStruct{i}.ncols=old.CameraStruct(i).ncols; 
  name=old.CameraStruct(i).imgName(end-11:end);
  copyfile(sprintf('%s%sViews/%s',OLD_DIR,MODEL_DIR,name),sprintf('%s%sViews/%08i.jpg',NEW_DIR,MODEL_DIR,i));  
  copyfile(sprintf('%s%sPosition/%spng',OLD_DIR,MODEL_DIR,name(1:end-3)),sprintf('%s%sPositions/%08i.png',NEW_DIR,MODEL_DIR,i));  
end
save([NEW_DIR MODEL_DIR 'cameras.mat'],'CameraStruct');
end