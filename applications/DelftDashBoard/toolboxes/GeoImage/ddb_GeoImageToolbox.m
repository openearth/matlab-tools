function ddb_GeoImageToolbox(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotGeoImage('activate');
    handles=getHandles;
    clearInstructions;
    setUIElements(handles.Toolbox(tb).GUI.elements);
else
    %Options selected
    handles=getHandles;
    opt=lower(varargin{1});    
    switch opt
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to draw image outline on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeGeoImageOnMap,'onstart',@deleteImageOutline);
        case{'generateimage'}
            generateImage;
        case{'editoutline'}
            editOutline;
    end    
end

%%
function changeGeoImageOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.Toolbox(tb).Input.imageOutlineHandle=h;
handles.Toolbox(tb).Input.xLim(1)=x0;
handles.Toolbox(tb).Input.yLim(1)=y0;
handles.Toolbox(tb).Input.xLim(2)=x0+dx;
handles.Toolbox(tb).Input.yLim(2)=y0+dy;

cs=handles.screenParameters.coordinateSystem;
dataCoord.name='WGS 84';
dataCoord.type='geographic';

% Find bounding box for data
if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
    ddx=dx/10;
    ddy=dy/10;
    [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
    dx=max(max(xtmp2))-min(min(xtmp2));
end

npix=handles.Toolbox(tb).Input.nPix;
zmlev=round(log2(npix*3/(dx)));
zmlev=max(zmlev,4);
zmlev=min(zmlev,23);

handles.Toolbox(tb).Input.zoomLevelStrings{1}=['auto (' num2str(zmlev) ')'];

setHandles(handles);
setUIElement('editxmin');
setUIElement('editxmax');
setUIElement('editymin');
setUIElement('editymax');
setUIElement('selectzoomlevel');

%%
function editOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.imageOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.imageOutlineHandle);
    end
end
x0=handles.Toolbox(tb).Input.xLim(1);
y0=handles.Toolbox(tb).Input.yLim(1);
dx=handles.Toolbox(tb).Input.xLim(2)-x0;
dy=handles.Toolbox(tb).Input.yLim(2)-y0;

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeGeoImageOnMap, ...
    'onstart',@deleteImageOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.Toolbox(tb).Input.imageOutlineHandle=h;
setHandles(handles);

%%
function deleteImageOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.imageOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.imageOutlineHandle);
    end
end

%%
function generateImage

handles=getHandles;

wb = waitbox('Generating image ...');pause(0.1);

xl(1)=handles.Toolbox(tb).Input.xLim(1);
xl(2)=handles.Toolbox(tb).Input.xLim(2);
yl(1)=handles.Toolbox(tb).Input.yLim(1);
yl(2)=handles.Toolbox(tb).Input.yLim(2);

npix=handles.Toolbox(tb).Input.nPix;

cs=handles.screenParameters.coordinateSystem;

dataCoord.name='WGS 84';
dataCoord.type='geographic';

% Find bounding box for data
if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
    dx=(xl(2)-xl(1))/10;
    dy=(yl(2)-yl(1))/10;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=[xl(1) xl(2)];
    yl0=[yl(1) yl(2)];
end

try
    [xx,yy,c2]=ddb_getMSVEimage(xl0(1),xl0(2),yl0(1),yl0(2),'zoomlevel',handles.Toolbox(tb).Input.zoomLevel,'npix',handles.Toolbox(tb).Input.nPix,'whatKind',handles.Toolbox(tb).Input.whatKind,'cache',handles.satelliteDir);
    % Now crop the image
    ii1=find(xx>=xl0(1),1,'first');
    ii2=find(xx<xl0(2),1,'last');
    jj1=find(yy>=yl0(1),1,'first');
    jj2=find(yy<yl0(2),1,'last');
    xx=xx(ii1:ii2);
    yy=yy(jj1:jj2);
    c2=c2(jj1:jj2,ii1:ii2,:);
catch
    close(wb);
    GiveWarning('Warning','Something went wrong while generating image. Try reducing zoom level or resolution.');
    return
end


% Now convert to current coordinate system
if ~strcmpi(cs.name,dataCoord.name) || ~strcmpi(cs.type,dataCoord.type)
    % Interpolate on rectangular grid
    res=(xl(2)-xl(1))/npix;
    [x11,y11]=meshgrid(xl(1):res:xl(2),yl(1):res:yl(2));
    [x2,y2]=ddb_coordConvert(x11,y11,cs,dataCoord);
    c2=double(c2);
    r1=interp2(xx,yy,c2(:,:,1),x2,y2);
    g1=interp2(xx,yy,c2(:,:,2),x2,y2);
    b1=interp2(xx,yy,c2(:,:,3),x2,y2);
    c2=[];
    c2(:,:,1)=r1;
    c2(:,:,2)=g1;
    c2(:,:,3)=b1;
    c2=uint8(c2);
    xx=xl(1):res:xl(2);
    yy=yl(1):res:yl(2);
end

xl(1)=xx(1);
xl(2)=xx(end);
yl(1)=yy(1);
yl(2)=yy(end);

close(wb);

if ~isempty(c2) && max(max(max(c2)))~=200

    figure(99)
    image(xx,yy,c2);
    set(gca,'YDir','normal');
    grid;
    set(99,'menubar','none');
    set(99,'toolbar','none');
    set(99,'Name','Geo Image','NumberTitle','off');
    pause(2);

    [filename, pathname, filterindex] = uiputfile('*.jpg', 'Select Image File','');
    if pathname~=0
        curdir=[lower(cd) '\'];
        jpgname=filename;
        if ~strcmpi(curdir,pathname)
            jpgname=[pathname filename];
        end
        rg=c2(:,:,1);
        gg=c2(:,:,2);
        bg=c2(:,:,3);
        rg=double(rg);
        gg=double(gg);
        bg=double(bg);
        rg=rot90(rg');
        gg=rot90(gg');
        bg=rot90(bg');
        cjpg(:,:,1)=rg;
        cjpg(:,:,2)=gg;
        cjpg(:,:,3)=bg;
        cjpg=uint8(cjpg);
        imwrite(cjpg,[jpgname],'jpeg');

        fname=jpgname(1:end-4);
        [filename, pathname, filterindex] = uiputfile('*.jgw', 'Select Image File',[fname '.jgw']);
        if pathname~=0
            curdir=[lower(cd) '\'];
            jgwname=filename;
            if ~strcmpi(curdir,pathname)
                jgwname=[pathname filename];
            end
            nxg=size(rg,2);
            nyg=size(rg,1);
            dx=(xl(2)-xl(1))/(nxg-1);
            dy=(yl(2)-yl(1))/(nyg-1);
            fid=fopen([jgwname],'wt');
            fprintf(fid,'%s\n',num2str(dx));
            fprintf(fid,'%s\n',num2str(0.0));
            fprintf(fid,'%s\n',num2str(0.0));
            fprintf(fid,'%s\n',num2str(-dy));
            fprintf(fid,'%s\n',num2str(xl(1)));
            fprintf(fid,'%s\n',num2str(yl(2)));
            fclose(fid);
        end
    end

else
    GiveWarning('Warning','Reduce zoom level or resolution');
end

