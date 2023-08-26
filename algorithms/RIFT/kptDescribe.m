function des = kptDescribe(im,eo,kpts,patch_size,no,nbin,is_ori)

n = size(kpts,2);
[ys,xs,~] = size(im);
if is_ori == 1
    N = no;
    mim_id = repmat(1:6,1,n/no);
else
    N = 1;
    mim_id = ones(1,n);
end

MIM = cell(N,1);
for i=1:N
    mim = zeros(ys, xs, no);
    for j=1:no
        if i+j-1<=no
            mim(:,:,j) = abs(eo{3,j+i-1})+abs(eo{1,j+i-1})+abs(eo{2,j+i-1});
        else
            mim(:,:,j) = abs(eo{3,j+i-1-no})+abs(eo{1,j+i-1-no})+abs(eo{2,j+i-1-no});
        end
    end
    [~, maxp] = max(mim,[],3);
    img = rgb2gray(im);
    maxp(img==0)=0;
    MIM{i,1} = maxp;
    %     figure;imshow(maxp,[])
end

des = zeros(no*no*nbin,n); %descriptor (size: 6¡Á6¡Áo)

parfor k = 1: n
    x = kpts(1, k);
    y = kpts(2, k);
    s = kpts(3, k);
    r = round(s*patch_size);
    ang = kpts(4,k);
    
    x1 = x-floor(r/2);
    y1 = y-floor(r/2);
    x2 = x+floor(r/2);
    y2 = y+floor(r/2);
    
    patch = extract_patches(MIM{mim_id(k),1}, x, y, r/2, ang);
    
    [ys,xs] = size(patch);
    histo = zeros(no,no,nbin);  %descriptor vector
    for j = 1:no
        for i = 1:no
            clip = patch(round((j-1)*ys/no+1):round(j*ys/no),round((i-1)*xs/no+1):round(i*xs/no));
            histo(j,i,:) = permute(hist(clip(:), 1:no), [1 3 2]);
        end
    end
    histo=histo(:);
    
    if norm(histo) ~= 0
        histo = histo /norm(histo);
    end
    des(:,k) = histo;
end


