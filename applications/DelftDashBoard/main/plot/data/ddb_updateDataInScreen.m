function ddb_updateDataInScreen(varargin)

handles=getHandles;

pnt='arrow';
ptr=getptr(gcf);
for i=1:length(ptr)
    if ischar(ptr{i})
        if strcmpi(ptr{i},'pointer')
            pnt=ptr{i+1};
        end
    end
end

motfcn=get(gcf,'windowbuttonmotionfcn');

set(gcf,'windowbuttonmotionfcn',[]);

set(gcf,'Pointer','watch');
pause(0.01);

handles=ddb_updateBathymetry(handles);

if strcmp(get(handles.GUIHandles.Menu.View.LandBoundaries,'Checked'),'on')
    ddb_updateShoreline(handles);
end

setHandles(handles);

setptr(gcf,pnt);

set(gcf,'windowbuttonmotionfcn',motfcn);

