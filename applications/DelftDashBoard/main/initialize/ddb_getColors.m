function rgb=ddb_getColors(ColorMap,n)
 
k=1;
 
if size(ColorMap,2)==3

    x=0:1/(size(ColorMap,1)-1):1;
    r=ColorMap(:,1);
    g=ColorMap(:,2);
    b=ColorMap(:,3);

else

    x=ColorMap(:,1);
    r=ColorMap(:,2);
    g=ColorMap(:,3);
    b=ColorMap(:,4);

end

x1=0:(1/(n-1)):1;
 
r1=interp1(x,r,x1);
g1=interp1(x,g,x1);
b1=interp1(x,b,x1);
 
rgb(:,1)=r1/255;
rgb(:,2)=g1/255;
rgb(:,3)=b1/255;
 
rgb=max(0,rgb);
rgb=min(1,rgb);
