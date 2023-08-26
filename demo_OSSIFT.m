clc;clear;close all; warning('off')
addpath dataset\Optical-Optical\
addpath algorithms\OSSIFT\;
addpath algorithms\common\
RES=[];

for i=1:200
    i
    str1=['pair' num2str(i) '_1.jpg'];
    str2=['pair' num2str(i) '_2.jpg'];
    gtstr =['gt_' num2str(i) '.txt'];

    if exist(str1,'file')==0
        continue;
    end
    gt=load(gtstr);
    im1 = uint8(imread(str1));
    im2 = uint8(imread(str2));

    if size(im1,3)==3
        im1 = rgb2gray(im1);
    end
    if size(im2,3)==3
        im2 = rgb2gray(im2);
    end

    image_11=im2double(im1);
    image_22=im2double(im2);
    image_11=image_11+0.001;%prevent denominator to be zero
    image_22=image_22+0.001;

    sigma=2;%the parameter of first scale
    ratio=2^(1/3);%scale ratio
    Mmax=8;%layer number
    d=0.04;
    d_SH_1=0.001;%Harris function threshold, need to refine for different dataset
    d_SH_2=0.001;%Harris function threshold
    change_form='affine';%it can be 'similarity','afine','perspective'
    is_sift_or_log='GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT'
    is_keypoints_refine=false;% set to false if the number of keypoints is small
    is_multi_region=true; % set to false for efficiency

    [r1,c1]=size(image_11);
    [r2,c2]=size(image_22);

    t1 = clock();
    [sar_harris_function_1,gradient_1,angle_1]=build_scale_opt(image_11,sigma,Mmax,ratio,d);
    [sar_harris_function_2,gradient_2,angle_2]=build_scale_sar(image_22,sigma,Mmax,ratio,d);

    [GR_key_array_1]=find_scale_extreme(sar_harris_function_1,d_SH_1,sigma,ratio,gradient_1,angle_1);
    [GR_key_array_2]=find_scale_extreme(sar_harris_function_2,d_SH_2,sigma,ratio,gradient_2,angle_2);

    if is_keypoints_refine == true
        %     [ GR_key_array_1 ] = RemovebyBorder( GR_key_array_1, c1,r1, 11 );
        %     [ GR_key_array_2 ] = RemovebyBorder( GR_key_array_2, c2,r2, 11 );
        [ GR_key_array_1 ] = pointrefine(image_1,GR_key_array_1,Mmax,sigma);
        [ GR_key_array_2 ] = pointrefine(image_2,GR_key_array_2,Mmax,sigma);
    end

    [descriptors_1,locs_1]=calc_descriptors_parallel(gradient_1,angle_1,GR_key_array_1);
    [descriptors_2,locs_2]=calc_descriptors_parallel(gradient_2,angle_2,GR_key_array_2);

    indexPairs = matchFeatures(descriptors_1,descriptors_2,'MaxRatio',1,'MatchThreshold', 100);
    kpts1 = locs_1; kpts2 = locs_2;
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
    timeres = double([time rmse size(cleanedPoints,1) size(indexPairs,1)]);
    RES = [RES;timeres];
end

save RES_dataset_ossift.mat RES
