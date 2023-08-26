function [ error,a,b] = BuildLine( x,y,n )

x2=sum(x.^2);
x1=sum(x);
x1y1=sum(x.*y);
y1=sum(y);

a=(n*x1y1-x1*y1)/(n*x2-x1*x1);
b=(y1-a*x1)/n;

for i=1:n
    error(i)=abs(y(i)-a*x(i)-b);
end

end

