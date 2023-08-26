function [descriptors,locs]=calc_descriptors_parallel...
    (   gradient,...
    angle,...
    key_point_array...
    )
angle(isnan(angle))=180;
circle_bin=8;
LOG_DESC_HIST_BINS=8;

M=size(key_point_array,1);
d=circle_bin;
n=LOG_DESC_HIST_BINS;
descriptors=zeros(M,(2*d+1)*n);

locs=key_point_array;
c=key_point_array();
x_array=c(:,1);y_array=c(:,2);scale_array=c(:,3);layer_array=c(:,4);angle_array=c(:,5);
parfor i=1:M
    x=x_array(i);
    y=y_array(i);
    scale=scale_array(i);
    layer=layer_array(i);
    main_angle=angle_array(i);
    current_gradient=gradient(:,:,layer);
    current_gradient=current_gradient/max(current_gradient(:));
    current_angle=angle(:,:,layer);
    descriptors(i,:)=calc_log_polar_descriptor(current_gradient,current_angle,...
        x,y,scale,main_angle,d,n);
%     if is_multi_region == true
%         descriptors(i,(2*d+1)*n+1:(2*d+1)*n*2)=calc_log_polar_descriptor(current_gradient,current_angle,...
%             x,y,scale*4/3,main_angle,d,n);
%         descriptors(i,(2*d+1)*n*2+1:(2*d+1)*n*3)=calc_log_polar_descriptor(current_gradient,current_angle,...
%             x,y,scale*2/3,main_angle,d,n);
%     end
end


