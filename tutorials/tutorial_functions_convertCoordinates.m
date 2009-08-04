%% convert coordinates to RD (Amersfoort)

[MKL.xRD,MKL.yRD] = xRSP2xyRD(MKL.x,7,3800);


%% convert coordinates to WGS 84
% Google Earth, and GPS, use the WGS 84 coordinate system. TO convert
% coordinates to this system, we use the functionConvertCoordinatesNew
% Beware of the order of the output arguments, lon-lat!

% We need to tell convert coordintaes what the input coordinate system is,
% and what the output coordinate system is (CS1 and CS2). We can do so by
% entereing the exact name. As we don't know  the exact name (including
% spaces etc), we type in a name that will surely not give an exact match,
% but looks a lot like what we want

[MKL.lon,MKL.lat] = ConvertCoordinatesNew(MKL.xRD,MKL.yRD,'CS1.name','amersfo')

% Not surprisingly, we get an error message. It has returened several
% coordinate systems that contain the string 'amersfo'. The one we want is
% 'Amersfoort / RD New'. We also need to define our output coordinate
% system, 