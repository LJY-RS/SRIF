clc;clear;close all; warning('off')
addpath dataset\Optical-Optical\
addpath algorithms\common\
RES=[];

for i = 1:200
    i
    str1=['pair' num2str(i) '_1.jpg'];
    str2=['pair' num2str(i) '_2.jpg'];
    gtstr =['gt_' num2str(i) '.txt'];
    
    if exist(str1,'file')==0
        continue;
    end
    gt=load(gtstr);

    im1 = im2uint8(imread(str1));
    im2 = im2uint8(imread(str2));
    H=[gt;0 0 1];
    image_fusion(im2,im1,double(H))

    waitforbuttonpress;
end

