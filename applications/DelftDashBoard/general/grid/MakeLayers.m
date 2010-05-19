function thick=MakeLayers(kmax,thtop,iopt)

thtop=1;
kmax=20;

pw1=1.5;

sumtot=10000;

while abs(sumtot-100)>0.001
    thick(1)=thtop;
    for k=2:kmax
        thick(k)=thick(k-1)*pw1;
    end
    sumtot=sum(thick);
    pw1 = pw1*(100/sumtot)^(1.0/kmax);
end
thick=0.01*round(100*thick);
sumtot=sum(thick);
dif=sumtot-100;
thick(end)=thick(end)-dif;
thick=thick';
if iopt==1
    thick=flipud(thick);
end
