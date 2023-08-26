function [key,m,eo] = kptDetection(im,s,o, npt, is_scale,level,base)

ba = [0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8];

[m,~,~,~,~,eo,~] = phasecong3(im,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);
a=max(m(:));  b=min(m(:));  m=(m-b)/(a-b);  

% kpts = detectFASTFeatures(m,'MinContrast',0.000001,'MinQuality',0.000001);
kpts = detectFASTFeatures(m,'MinContrast',0.0001,'MinQuality',0.0001);
kpts=kpts.selectStrongest(npt);

kpts = double(kpts.Location');

n=size(kpts,2);
if is_scale==1
    key = zeros(3,n*(2*level+1));
%     x=-level:level;
    scale = ba((length(ba)+1)/2-level:(length(ba)+1)/2+level);
    for i=1:2*level+1
        kpts_scale = [kpts; ones(1,n)*scale(i)];
        key(:,n*(i-1)+1:n*i) = kpts_scale;
    end
else
    key = [kpts; ones(1,n)];
end



