clc;clear;close all; warning('off')
addpath dataset\Optical-Optical\
addpath algorithms\RIFT\;
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
    
    if size(im1,3)==1
        temp=im1;
        im1(:,:,1)=temp;
        im1(:,:,2)=temp;
        im1(:,:,3)=temp;
    end
    
    if size(im2,3)==1
        temp=im2;
        im2(:,:,1)=temp;
        im2(:,:,2)=temp;
        im2(:,:,3)=temp;
    end
    
    t1 = clock();
    [key1,m1,eo1] = kptDetection(im1,4,6, 5000, 0,3,1.2);
    [key2,m2,eo2] = kptDetection(im2,4,6, 5000, 0,3,1.2);
    
    kpts1 = kptsOrientation0(key1,m1,1,96,6,0);
    kpts2 = kptsOrientation0(key2,m2,1,96,6,1);
    
    des1 = kptDescribe(im1,eo1,kpts1,96,6,6,0);
    des2 = kptDescribe(im2,eo2,kpts2,96,6,6,1);
    [indexPairs,matchmetric] = matchFeatures(des1',des2','MaxRatio',1,'MatchThreshold', 100);
    kpts1 = kpts1'; kpts2 = kpts2';
    matchedPoints1 = kpts1(indexPairs(:, 1), 1:2);
    matchedPoints2 = kpts2(indexPairs(:, 2), 1:2);
    t2 = clock();
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
    [cleanedPoints1,IB] = unique(cleanedPoints1,'rows');
    cleanedPoints2 = cleanedPoints2(IB,:);
    cleanedPoints=[cleanedPoints1 cleanedPoints2];
    
    cleanedPoints = double(cleanedPoints);
    Y_=H*[cleanedPoints(:,1:2)';ones(1,size(cleanedPoints,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-cleanedPoints(:,3:4)').^2));
    if length(E)<=10
        rmse = 20;
    else
        rmse = sqrt(sum(E.^2)/size(E,2));
    end
    length(E)
    
    timeres = double([time rmse size(cleanedPoints,1) size(indexPairs,2)]);
    RES = [RES;timeres];

%     plotid = randperm(size(cleanedPoints,1),min(size(cleanedPoints,1),200));
%     figure; showMatchedFeatures(im1, im2, cleanedPoints(plotid,1:2), cleanedPoints(plotid,3:4), 'montage');
end

save RES_rift.mat RES
