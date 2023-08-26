clc;clear; warning('off')
addpath dataset\Optical-Optical\
addpath algorithms\MS_HLMO\;
addpath algorithms\common\

RES=[];
G_resize = 2;  % Gaussian pyramid downsampling unit, default:2
G_sigma = 1.6; % Gaussian pyramid blurring unit, default:1.6
nOctaves_1 = 3; nOctaves_2 = 3; % Gaussian pyramid octave number
nLayers = 4;   % Gaussian pyramid layer number
sigma = 1;   % Harris: Upper standard deviation of Gaussian kernel
thresh = 0.001; % Harris: Cornerness discriminant threshold
radius = 2;  % Harris: LNSM patch radius, default: 5, 2, or 1
N = 5000;    % Feature points number threshold
patch_size = 96; % HLMO: patch size (scale)
NA = 12;         % HLMO: Subregion division number
NO = 12;         % HLMO: Orientation quantification number
rotate = 1; % Is there obvious rotation between the images, Yes:1, No:0

for i=1:200
    i
    close all
    str1=['pair' num2str(i) '_1.jpg'];
    str2=['pair' num2str(i) '_2.jpg'];
    gtstr =['gt_' num2str(i) '.txt'];
    
    if exist(str1,'file')==0
        continue;
    end
    gt=load(gtstr);
    im1 = uint8(imread(str1));
    im2 = uint8(imread(str2));
    
    resample1 = 1; resample2 = 1;
    
    t1=clock();
    [I1_o,I1] = Preproscessing(im1,resample1); % I1: Reference image
    [I2_o,I2] = Preproscessing(im2,resample2); % I2: Image to be registered

    [keypoints_1,keypoints_2] = Keypoints_Detection(I1,I2,...
        sigma,thresh,radius,N,nOctaves_1,nOctaves_2,G_resize);
    
    [descriptors_1,descriptors_2] = Keypoints_Description(...
        I1,keypoints_1,I2,keypoints_2,patch_size,NA,NO,rotate,...
        nOctaves_1,nOctaves_2,nLayers,G_resize,G_sigma);
    
    [cor1,cor2] = Multiscale_Matching(descriptors_1,descriptors_2,...
        nOctaves_1,nOctaves_2,nLayers);
    t2=clock();
    time=etime(t2,t1);
    matchedPoints1 = cor1(:,1:2)/resample1; matchedPoints2 = cor2(:,1:2)/resample2;
    
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
    timeres = double([time rmse size(cleanedPoints,1)]);
    RES = [RES;timeres];

end

save RES_HMHLMO.mat RES
