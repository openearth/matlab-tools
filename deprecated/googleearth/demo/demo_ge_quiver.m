function demo_ge_quiver()
 error('%s has been deprecated',mfilename)
% Demo ge_quiver

res = 0.3;

[X,Y] = meshgrid(-2:res:2);
Z = X.*exp(-X.^2 - Y.^2);
[DX,DY] = gradient(Z,res,res);


figure
surf(X,Y,Z)
xlabel('x')
ylabel('y')
zlabel('z')

kmlStr = ge_quiver(X,Y,DX,DY,...
                 'lineColor','ffffff00', ...
                 'lineWidth',1.2, ...
                  'altitude',50000,...
              'altitudeMode','relativeToGround',...
               'msgToScreen',true);



ge_output('demo_ge_quiver.kml',kmlStr)