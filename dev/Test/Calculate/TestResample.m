
function TestResamplePolyline
x = [0 200 200 0];
y = [0 0   200 0];
dxRes = 50;

[xRes,yRes,sRes] = Resample.resamplePolyline(x,y,dxRes);
 xResExp = [0 50 100 150 200 200 200 200 200 200-50/sqrt(2) 200-100/sqrt(2) 200-150/sqrt(2) 200-200/sqrt(2) 200-250/sqrt(2) ];
 yResExp = [0 0    0   0   0 50  100 150 200 200-50/sqrt(2) 200-100/sqrt(2) 200-150/sqrt(2) 200-200/sqrt(2) 200-250/sqrt(2) ];
 
 disp(xRes);
 disp(xResExp);
 
 disp(yRes);
 disp(yResExp);
 
 plot(xResExp,yResExp)