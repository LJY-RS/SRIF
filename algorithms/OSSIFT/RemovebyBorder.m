function [ Kpt ] = RemovebyBorder( pt, r,c, d )
%REMOVEBYBORDER Summary of this function goes here
%   remove border and the same points
len=size(pt,1);
k=1;
for i=1:len
    x=pt(i,1);
    y=pt(i,2);
    for j=i+1:len
        x1=pt(j,1);
        y1=pt(j,2); 
        if x==x1&&y==y1&&j~=i
            pt(j,1)=0;
            pt(j,2)=0;
        end
    end
    if x>d&&y>d&&(x+d)<r&&(y+d)<c
        Kpt(k,:)=pt(i,:);
        k=k+1;
    end
end

