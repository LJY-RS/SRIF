function [ GR_key_array_1 ] = pointrefine(image_1,GR_key_array_1,N,sigma)
%POINTREFINE 
m=size(GR_key_array_1,1);
flag=zeros(1,m);
s1=GR_key_array_1(:,4)';
L1=length(find(s1==1));
[R,C]=size(image_1);
Top=max(image_1(:));

%% filter isolated bright pixel
% for i=1:m
%     x=GR_key_array_1(i,2);
%     y=GR_key_array_1(i,1);
%     if(image_1(x,y)>0.8*Top)
%         if(image_1(x,y)/mean2(image_1(x-1:x+1,y-1:y+1))>5)
%             GR_key_array_1(i,:)=[];
%         end
%     end
% end
%%
for i=1:m
    if flag(i)==0
        x=GR_key_array_1(i,1);
        y=GR_key_array_1(i,2);
%         if x==184&&y==130
%             
%         end
        s=GR_key_array_1(i,4);
        t=GR_key_array_1(i,5);
        x1=x;y1=y;indx=i;
        for j=1:m
            if GR_key_array_1(j,4)~=s
                xt=GR_key_array_1(j,1);
                yt=GR_key_array_1(j,2);
                tt=GR_key_array_1(j,5);
                if abs(tt-t)<10   % 角度小于5度
                    if sqrt((x-xt)^2+(y-yt)^2)<=N*sigma
                        x1=[x1,xt];y1=[y1,yt];indx=[indx,j];flag(j)=1;
                    end
                end
            end
        end
        if length(x1)<4
            continue;
        else
            [error,a,b]=BuildLine(x1,y1,length(x1));
            for k=1:length(x1)
                if error(k)>0.5
                    if length(find(x1==x1(k)))>1
                        if a~=0
                            x1(k)=(y1(k)-b)/a;
                        end
                    else
                        y1(k)=a*x1(k)+b;
                    end
                    GR_key_array_1(indx(k),1)=round(x1(k));
                    GR_key_array_1(indx(k),2)=round(y1(k));
                end
            end
        end
    end
end

end

