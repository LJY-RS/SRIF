clc;clear;close all;
addpath dataset\Optical-Optical\
addpath algorithms\SIFT\;
addpath algorithms\common\
run('./algorithms/SIFT/vlfeat-0.9.18/toolbox/vl_setup.m');

RES=[];
for i = 1 :200
    i
    str1=['pair' num2str(i) '_1.jpg'];
    str2=['pair' num2str(i) '_2.jpg'];
    gtstr =['gt_' num2str(i) '.txt'];
    
    if exist(str1,'file')==0
        continue;
    end
    gt=load(gtstr);
    
    image_1 = uint8(imread(str1));
    image_2 = uint8(imread(str2));
    
    [~,~,num1]=size(image_1);
    [~,~,num2]=size(image_2);
    if(num1==3)
        image_11=rgb2gray(image_1);
    else
        image_11=image_1;
    end
    if(num2==3)
        image_22=rgb2gray(image_2);
    else
        image_22=image_2;
    end
    
    image_11=im2double(image_11);
    image_22=im2double(image_22);
    
    t1=clock();
    [matchedPoints1, matchedPoints2] = sift_match(image_11, image_22, 1);
    t2=clock();
    time=etime(t2,t1);
    
    H=[gt;0 0 1];
    Y_=H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));
    inliersIndex=E<3;
    cleanedPoints1 = matchedPoints1(inliersIndex, :);
    cleanedPoints2 = matchedPoints2(inliersIndex, :);
    [cleanedPoints2,IA] = unique(cleanedPoints2,'rows');
    cleanedPoints1 = cleanedPoints1(IA,:);
    cleanedPoints=[cleanedPoints1 cleanedPoints2];
    cleanedPoints = double(cleanedPoints);
    Y_=H*[cleanedPoints(:,1:2)';ones(1,size(cleanedPoints,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-cleanedPoints(:,3:4)').^2));
    if length(E)<10
        rmse = 20;
    else
        rmse = sqrt(sum(E.^2)/size(E,2));
    end
    length(E)
    timeres = double([time rmse size(cleanedPoints,1) size(matchedPoints1,1)]);
    RES = [RES;timeres];
end
save RES_sift.mat RES


