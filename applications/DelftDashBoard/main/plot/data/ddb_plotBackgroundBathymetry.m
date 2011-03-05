function ddb_plotBackgroundBathymetry(handles)

% tic

xx=handles.GUIData.x(1,:);
yy=handles.GUIData.y(:,1);

xmin=handles.screenParameters.xLim(1);
xmax=handles.screenParameters.xLim(2);
ymin=handles.screenParameters.yLim(1);
ymax=handles.screenParameters.yLim(2);
dx=(xmax-xmin)/20;
dy=(ymax-ymin)/20;
xmin=xmin-dx;
xmax=xmax+dx;
ymin=ymin-dy;
ymax=ymax+dy;

ilim=find(xx<xmax & xx>xmin);
jlim=find(yy<ymax & yy>ymin);

xx=xx(ilim);
yy=yy(jlim);

%h=findobj(handles.GUIHandles.MainWindow,'Tag','BackgroundBathymetry');
h=handles.mapHandles.bathymetry;

zz=handles.GUIData.z(jlim,ilim);
%zz=single(zz);

if handles.screenParameters.automaticColorLimits
    zmin=abs(min(min(zz)));
    mxz=zmin;
    mnz=-zmin;
else
    mxz=handles.screenParameters.cMax;
    mnz=handles.screenParameters.cMin;
end

zz0=zz;
zz=min(zz,mxz);
zz=max(zz,mnz);
zz(isnan(zz0))=NaN;

if strcmpi(handles.screenParameters.colorMap,'earth')
    earth=handles.mapData.colorMaps.earth;
else
    earth=jet;
end

if size(earth,2)==3
    earthx=mnz:(mxz-mnz)/(length(earth)-1):mxz;
    earthy=earth(:,1:3);
else
    earthx=earth(:,1)*(mxz-mnz)+mnz;
    earthy=earth(:,2:4);
end

if length(earthx)>1

    tic
    disp('Interpolating color map ...');
%    earthy=single(earthy);
    r=interp1(earthx,earthy(:,1),zz);
    g=interp1(earthx,earthy(:,2),zz);
    b=interp1(earthx,earthy(:,3),zz);
    toc
    r(isnan(zz))=1;
    g(isnan(zz))=1;
    b(isnan(zz))=1;
    
    cdata=[];
    cdata(:,:,1)=r;
    cdata(:,:,2)=g;
    cdata(:,:,3)=b;

    

    %  Get tile data
%     zmlev=3;
%     [xx,yy,cdata]=ddb_getimagetile(xmin,xmax,ymin,ymax,zmlev);

    cdata=min(cdata,0.999);
    cdata=max(cdata,0.001);
%    cdata=single(cdata);
    cdata=uint8(cdata*255);

    
    set(h,'XData',xx,'YData',yy,'CData',cdata);
    set(gca,'YDir','normal');
    
    if strcmp(get(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked'),'on')
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end

    caxis([mnz mxz]);
    ddb_colorBar('update',earth);

    set(gca,'CLim',[mnz mxz]);
    disp('Plotting Image ...')
%     toc
end
