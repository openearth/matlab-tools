function demo_ge_overlay()
 error('%s has been deprecated',mfilename)

    filename = 'data/test';
    frames = 20;
    xSize = 0.35;
    ySize = 0.3;
    xSizeUnits = 'fraction';
    ySizeUnits = 'fraction';
    
    tIndex = datenum(now);
    tVec   = datevec(tIndex);
    tStart = datestr( tVec, 'yyyy-mm-ddTHH:MM:SSZ');
    tStop = tStart;
    kml = '';
    
    %first draw a background
    x = 0;
    y = 0;
    
    figure
    plot(x,y)
    stampFileName = [filename int2str(1) '.png'];
    write_image(stampFileName, false);

    kml = [kml ge_overlay( stampFileName,'xSize',xSize,'xSizeUnits',xSizeUnits,'ySize',ySize,'ySizeUnits',ySizeUnits,'drawOrder',1)];

        
        
    for i = 2:frames

        x = -pi:.1:pi;
        y = sin(x+i*.1);

        plot(x,y)
        %hold on;
        stampFileName = [filename int2str(i) '.png'];
        write_image(stampFileName, true);

        tStart = datestr( tVec, 'yyyy-mm-ddTHH:MM:SSZ');
        tVec(5) = tVec(5)+1;
        tStop  = datestr( tVec, 'yyyy-mm-ddTHH:MM:SSZ');

        kml = [kml ge_plot(x,y,'timeSpanStart',tStart,'timeSpanStop',tStop)];
        
        %kml = [kml temp_ge_overlay( xSize,ySize,stampFileName, i,tStart, tStop )];
        kml = [kml ge_overlay( stampFileName,'xSize',xSize,'xSizeUnits',xSizeUnits,'ySize',ySize,'ySizeUnits',ySizeUnits,'drawOrder',i,'timeSpanStart',tStart,'timeSpanStop',tStop)];

    end
    
    kml = ge_folder('graph tests', kml);
    ge_output('demo_ge_overlay.kml', kml);

end

function write_image( filename, useAlpha )
        F = getframe;
        [X,Map] = frame2im(F);
        if useAlpha
            xAlpha = double(X~=255);
            imwrite(X,filename,'png','Alpha',xAlpha);
        else
            imwrite(X,filename,'png');
        end
end
