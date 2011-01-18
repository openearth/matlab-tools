function demo_ge_contourf_old()
 error('%s has been deprecated',mfilename)



[X,Y] = meshgrid(0:19,0:19);

if strcmp(devenv,'matlab')
    [C,h] = contourf(X,Y,peaks(20),30);
    colormap jet
elseif strcmp(devenv,'octave')
    %no contourf in octave
end


kmlStr = ge_contourf_old(X,Y,peaks(20),'cMap','jet','polyAlpha','ff',...
                        'numLevels', 30);
                    
ge_output('demo_ge_contourf.kml',kmlStr);