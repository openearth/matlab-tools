function [c1,c2,c3]=getColorLims(cmin,cmax)

cc3=[0.1  0.2  0.5  1   2   5 10 20 30 50 100 200 500 1000 2000 5000];
cc2=[0.01 0.02 0.05 0.1 0.2 0.5 1 2 2 5 10 20 50 100 200 500];

% Lower value
if cmin>=0
    i1=0;
else
    for i=length(cc2)
        if cmin>=-cc3(i)
            i1=-i;
            break;
        end
    end
end

% Upper value
for i=1:length(cc2)
    if cmax<=cc3(i)
        i2=i;
        break;
    end
end

if i1<0
    c1=-cc3(-i1);
else
    c1=0;
end

c3=cc3(i2);
c2=cc2(i2);

