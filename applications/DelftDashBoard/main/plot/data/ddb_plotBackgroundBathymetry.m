function ddb_plotBackgroundBathymetry(handles)

% tic

xx=handles.GUIData.x(1,:);
yy=handles.GUIData.y(:,1);

xmin=handles.ScreenParameters.XLim(1);
xmax=handles.ScreenParameters.XLim(2);
ymin=handles.ScreenParameters.YLim(1);
ymax=handles.ScreenParameters.YLim(2);

ilim=find(xx<xmax & xx>xmin);
jlim=find(yy<ymax & yy>ymin);

xx=xx(ilim);
yy=yy(jlim);

h=findobj(handles.GUIHandles.MainWindow,'Tag','BackgroundBathymetry');

zz=handles.GUIData.z(jlim,ilim);

if handles.ScreenParameters.AutomaticColorLimits
    zmin=abs(min(min(zz)));
    mxz=zmin;
    mnz=-zmin;
else
    mxz=handles.ScreenParameters.CMax;
    mnz=handles.ScreenParameters.CMin;
end

zz0=zz;
zz=min(zz,mxz);
zz=max(zz,mnz);
zz(isnan(zz0))=NaN;

if strcmpi(handles.ScreenParameters.ColorMap,'earth')
    earth=handles.GUIData.ColorMaps.Earth;
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

    cdata=min(cdata,0.999);
    cdata=max(cdata,0.001);

    tic
    if ~isempty(h)
        set(h,'XData',xx,'YData',yy,'CData',cdata);
    else
        h=image(xx,yy,cdata);hold on;
        set(h,'Tag','BackgroundBathymetry');
    end
    set(gca,'YDir','normal');
    
    % if length(h)>0
    %     delete(h);
    % end
    % [img, lon, lat] = url2image('tile2img',[xmin xmax],[ymin ymax], 4,'lonlat', 'yes');
    %
    % sz=size(img);
    % dlon=(lon(2)-lon(1))/sz(1);
    % dlat=(lat(2)-lat(1))/sz(2);
    % x=lon(1):dlon:lon(2)-dlon;
    % y=lat(1):dlat:lat(2)-dlat;
    %
    % h=image(x,y,img);
    % set(h,'Tag','BackgroundBathymetry');
    % yd=get(h,'YData')

    if strcmp(get(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked'),'on')
        set(h,'Visible','on');
    else
        set(h,'Visible','off');
    end

    caxis([mnz mxz]);
    ddb_makeColorBar(earth);

    set(gca,'CLim',[mnz mxz]);
    disp('Plotting Image ...')
%     toc
end
