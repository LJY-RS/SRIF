function [sar_harris_function,G_gradient,angle]=build_scale_opt(image,sigma,Mmax,ratio,d)

[M,N]=size(image);
sar_harris_function=zeros(M,N,Mmax);
G_gradient=zeros(M,N,Mmax);
angle=zeros(M,N,Mmax);

for i=1:1:Mmax
    %%
    scale=sigma*(ratio)^(i-1);
    radius=round(scale);
    j=-radius:1:radius;
    k=-radius:1:radius;
    [xarry,yarry]=meshgrid(j,k);
%     W=exp(-(abs(xarry)+abs(yarry))/scale);
    W=exp(-((xarry.*xarry)+(yarry.*yarry))/(2*scale));
%     WH=abs(xarry)-radius;
%     WV=abs(yarry)-radius;
    W2=zeros(2*radius+1,2*radius+1);
    W1=zeros(2*radius+1,2*radius+1);
    W2(radius+2:2*radius+1,:)=W(radius+2:2*radius+1,:);
    W2(1:radius,:)=-W(1:radius,:);
    W1(:,radius+2:2*radius+1)=W(:,radius+2:2*radius+1);
    W1(:,1:radius)=-W(:,1:radius);
    
    Gx=imfilter(image,W1,'replicate');
    Gy=imfilter(image,W2,'replicate');
    
    Gx(find(imag(Gx)))=abs(Gx(find(imag(Gx))));
    Gy(find(imag(Gy)))=abs(Gy(find(imag(Gy))));
    Gx(~isfinite(Gx))=0;
    Gy(~isfinite(Gy))=0;
    
    temp_gradient=sqrt(Gx.^2+Gy.^2);  
    temp_gradient=temp_gradient/max(temp_gradient(:));
    G_gradient(:,:,i)= temp_gradient;
    temp_angle=atan(Gy./Gx);
%     temp_angle=atan2(Gy,Gx);
    temp_angle=temp_angle/pi*180;
    temp_angle(temp_angle<0)=temp_angle(temp_angle<0)+180;
    temp_angle(isnan(temp_angle))=180;
    angle(:,:,i)=temp_angle;
    
    Csh_11=scale^2*Gx.^2;
    Csh_12=scale^2*Gx.*Gy;
    Csh_22=scale^2*Gy.^2;
    
    gaussian_sigma=sqrt(2)*scale;
    width=round(3*gaussian_sigma);
    width_windows=2*width+1;
    W_gaussian=fspecial('gaussian',[width_windows width_windows],gaussian_sigma);
    [a,b]=meshgrid(1:width_windows,1:width_windows);
    index=find(((a-width-1)^2+(b-width-1)^2)>width^2);
    W_gaussian(index)=0;
    
    Csh_11=imfilter(Csh_11,W_gaussian,'replicate');
    Csh_12=imfilter(Csh_12,W_gaussian,'replicate');
    Csh_21=Csh_12;
    Csh_22=imfilter(Csh_22,W_gaussian,'replicate');
    
%     temp_angle=atan(abs(Gy)./abs(Gx));
%     temp_angle=temp_angle/pi*180;
%     temp_angle=min(temp_angle./45,45./temp_angle);
    sar_harris_function(:,:,i)=(Csh_11.*Csh_22-Csh_21.*Csh_12-d*(Csh_11+Csh_22).^2);
end