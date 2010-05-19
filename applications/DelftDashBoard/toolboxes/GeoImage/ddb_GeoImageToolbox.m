function ddb_geoImageToolbox

handles=getHandles;

ddb_plotGeoImage(handles,'activate');

uipanel('Title','Geo Image','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.EditX1     = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.XLim(1)),'Position',[ 80 130 80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditX2     = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.XLim(2)),'Position',[ 80 105 80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditY1     = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.YLim(1)),'Position',[ 80  80 80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditY2     = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.YLim(2)),'Position',[ 80  55 80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditNPix   = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).Input.NPix),   'Position',[260 105 80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextXMin     = uicontrol(gcf,'Style','text','String','X Min',     'Position',[ 35 127 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextXMax     = uicontrol(gcf,'Style','text','String','X Max',     'Position',[ 35 102 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextYMin     = uicontrol(gcf,'Style','text','String','Y Min',     'Position',[ 35  77 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextYMax     = uicontrol(gcf,'Style','text','String','Y Max',     'Position',[ 35  52 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextZLevel   = uicontrol(gcf,'Style','text','String','Zoom Level','Position',[170 127 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextNPix     = uicontrol(gcf,'Style','text','String','Nr Horiz. Pixels', 'Position',[170 102 80 20],'HorizontalAlignment','right','Tag','UIControl');

str{1}='auto';
for i=1:16
    str{i+1}=num2str(i+3);
end
handles.GUIHandles.SelectZoomLevel = uicontrol(gcf,'Style','popupmenu','String',str,   'Position',[260 130 80 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.SourceSelection                 = uicontrol(gcf,'Style','popupmenu','String',{'Microsoft Virtual Earth','Google Earth'},'Position',[360 130 150 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.Pushddb_drawImageOutline            = uicontrol(gcf,'Style','pushbutton','String','Draw Image Outline',           'Position',[360 105 150 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateImage               = uicontrol(gcf,'Style','pushbutton','String','Generate Image',               'Position',[360  80 150 20],'Tag','UIControl');

set(handles.GUIHandles.Pushddb_drawImageOutline, 'CallBack',{@ddb_drawImageOutline});
set(handles.GUIHandles.PushGenerateImage,    'CallBack',{@PushGenerateImage});
set(handles.GUIHandles.EditX1,               'CallBack',{@EditX1_CallBack});
set(handles.GUIHandles.EditX2,               'CallBack',{@EditX2_CallBack});
set(handles.GUIHandles.EditY1,               'CallBack',{@EditY1_CallBack});
set(handles.GUIHandles.EditY2,               'CallBack',{@EditY2_CallBack});

SetUIBackgroundColors;

ddb_refreshZoomLevels(handles);

setHandles(handles);

%%
function EditX1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Input.XLim(1)=str2double(get(hObject,'String'));
setHandles(handles);
ddb_deleteImageOutline;
ddb_plotImageOutline('g');
ddb_refreshZoomLevels(handles);

%%
function EditX2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Input.XLim(2)=str2double(get(hObject,'String'));
setHandles(handles);
ddb_deleteImageOutline;
ddb_plotImageOutline('g');
ddb_refreshZoomLevels(handles);

%%
function EditY1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Input.YLim(1)=str2double(get(hObject,'String'));
setHandles(handles);
ddb_deleteImageOutline;
ddb_plotImageOutline('g');
ddb_refreshZoomLevels(handles);

%%
function EditY2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).Input.YLim(2)=str2double(get(hObject,'String'));
setHandles(handles);
ddb_deleteImageOutline;
ddb_plotImageOutline('g');
ddb_refreshZoomLevels(handles);

%%
function PushGenerateImage(src,eventdata)

handles=getHandles;

xl(1)=handles.Toolbox(tb).Input.XLim(1);
xl(2)=handles.Toolbox(tb).Input.XLim(2);
yl(1)=handles.Toolbox(tb).Input.YLim(1);
yl(2)=handles.Toolbox(tb).Input.YLim(2);

cs=handles.ScreenParameters.CoordinateSystem;

i=get(handles.GUIHandles.SelectZoomLevel,'Value');
str=get(handles.GUIHandles.SelectZoomLevel,'String');
if i>1
    zlev=str2double(str{i});
else
    zlev=0;
end
source=get(handles.GUIHandles.SourceSelection,'Value');

npix=str2double(get(handles.GUIHandles.EditNPix,'String'));

if strcmpi(cs.Name,'wgs 84')
    cs=[];
end

if source==1 % visual earth
    [xgl,ygl,c2]=ddb_makeGeoImage(xl,yl,'coordinatesystem',cs,'zoomlevel',zlev,'nrpix',npix);
elseif source==2 % google earth
    [xgl,ygl,c2]=ddb_makeGeoImageGE(xl,yl,'coordinatesystem',cs,'zoomlevel',zlev,'nrpix',npix);
end

if ~isempty(c2)

    figure(99)
    image(xgl,ygl,c2);
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
    GiveWarning('Warning','Reduce Zoom Level or resolution');
end

