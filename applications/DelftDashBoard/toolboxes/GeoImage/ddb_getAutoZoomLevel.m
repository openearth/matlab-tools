function zoomLevel=ddb_getAutoZoomLevel(handles,xl,yl,npix)

if ~strcmpi(handles.screenParameters.coordinateSystem.name,'wgs 84')
    cs0=handles.screenParameters.coordinateSystem;
    cs1.name='WGS 84';
    cs1.type='geo';
    [xl(1),yl(1)]=ddb_coordConvert(xl(1),yl(1),cs0,cs1);
    [xl(2),yl(2)]=ddb_coordConvert(xl(2),yl(2),cs0,cs1);
end

% Determine zoom level
zmlev=round(log2(npix*180/256/(xl(2)-xl(1))));
zmlev=max(zmlev,4);
zoomLevel=min(zmlev,19);
