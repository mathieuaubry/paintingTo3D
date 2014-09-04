function [D]=readMap24(name)
I=255.*im2double(imread(name));
D=(256*256).*I(:,:,1)+(256).*I(:,:,2)+I(:,:,3);

end