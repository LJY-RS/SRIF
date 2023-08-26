function [descriptors,locs]=calc_descriptors...
    (   gradient,...
    angle,...
    key_point_array,...
    is_multi_region...
    )

circle_bin=8;
LOG_DESC_HIST_BINS=8;

M=size(key_point_array,1);
d=circle_bin;
n=LOG_DESC_HIST_BINS;
if is_multi_region == false
    descriptors=zeros(M,(2*d+1)*n);
else
    descriptors=zeros(M,(2*d+1)*n*3);
end
locs=key_point_array;
for i=1:1:M
    x=key_point_array(i,1);
    y=key_point_array(i,2);
    scale=key_point_array(i,3);
    layer=key_point_array(i,4);
    main_angle=key_point_array(i,5);
    current_gradient=gradient(:,:,layer);
    current_gradient=current_gradient/max(current_gradient(:));
    current_angle=angle(:,:,layer);
    descriptors(i,1:(2*d+1)*n)=calc_log_polar_descriptor(current_gradient,current_angle,...
        x,y,scale,main_angle,d,n);
    if is_multi_region == true
        descriptors(i,(2*d+1)*n+1:(2*d+1)*n*2)=calc_log_polar_descriptor(current_gradient,current_angle,...
            x,y,scale*4/3,main_angle,d,n);
        descriptors(i,(2*d+1)*n*2+1:(2*d+1)*n*3)=calc_log_polar_descriptor(current_gradient,current_angle,...
            x,y,scale*2/3,main_angle,d,n);
    end
end


