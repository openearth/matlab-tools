function griddata_plus_test()
% %%
% % x = (rand(100)-.5).*8;
% % y = (rand(100)-.5).*8;
% 
% 
% 
% x = repmat(linspace(-4,4,161)  ,17,1);
% y = repmat(linspace(-10,10,17)',1,161);
% 
% 
% % z = peaks(x,y)+randn(size(x));
% 
% xx = [-16 -4 0 1 2 4 16];
% yy = [0   -2 0 4 2 3  0];
% x = x(:);y = y(:);
% z = spline(xx,yy,x+sin(y/2)*2)+randn(size(x));
% 
% 
% 
% % z(x>-1&x<2&y>-2&y<1) = nan;
% % x(isnan(z))=[];
% % y(isnan(z))=[];
% % z(isnan(z))=[];
% nn = 321;
% [XI,YI] = meshgrid(linspace(min(x),max(x),nn),linspace(min(y),max(y),nn));
% 
% h(1) = subplot(2,1,1);
% ZI = griddata_plus(x,y,z,XI,YI);
% surf(XI,YI,ZI);
% 
% hold on
% plot3(x,y,z+1,'.')
% hold off
% title 'griddata plus'
% colorbar
% view(2);
% h(2) = subplot(2,1,2);
% ZI = griddata(x,y,z,XI,YI);
% 
% surf(XI,YI,ZI)
% 
% hold on
% plot3(x,y,z+1,'.')
% hold off
% title griddata
% hold off
% colorbar
% view(2);
% linkprop(h,{'DataAspectRatio','clim','view'});





zFcn = @(x,y) peaks((x+2)./4,y)+sin(x.^2)+sin(y.^2);
[x,y] = meshgrid(-2:.05:2,-2:0.1:2);
z = zFcn(x,y);

c1 = contours(x,y,z,-8:1:8);
ii = 0;
kk = 1;
c2 = [];
while kk<size(c1,2)
ii = ii+1;
nn = c1(2,kk);
c2 = [c2 [c1(:,kk+1:kk+nn); repmat(c1(1,kk),1,nn)]];
kk = kk+nn+1;
end
x = c2(1,:);
y = c2(2,:);
z = c2(3,:);


nn = 51
[XI,YI] = meshgrid(linspace(min(x),max(x),nn),linspace(min(y),max(y),nn));
h(1) = subplot(2,1,1);
ZI = griddata_plus(x,y,z,XI,YI,'max_length','auto',...
    'max_length_fcn',@(edgeLength) 1.0 * percentile(edgeLength,99));


surf(XI,YI,ZI,ZI - zFcn(XI,YI));
hold on; plot3(x,y,z,'.'); hold off; title 'griddata plus'
shading interp; 

h(2) = subplot(2,1,2);
ZI = griddata(x,y,z,XI,YI);
surf(XI,YI,ZI,ZI - zFcn(XI,YI))
hold on; plot3(x,y,z,'.'); hold off; title 'griddata'; hold off
linkprop(h,{'clim','view'});
shading interp; 


