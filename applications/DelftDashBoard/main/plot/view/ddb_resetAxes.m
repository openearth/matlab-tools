function ddb_resetAxes

handles=getHandles;

if ~strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'Geographic')
    if ~isempty(handles.Model(md).Input(ad).GrdFile)
        xmin=min(min(handles.Model(md).Input(ad).GridX));
        xmax=max(max(handles.Model(md).Input(ad).GridX));
        ymin=min(min(handles.Model(md).Input(ad).GridY));
        ymax=max(max(handles.Model(md).Input(ad).GridY));
        point1(1,1)=xmin;
        point1(1,2)=ymin;
        point2(1,1)=xmax;
        point2(1,2)=ymax;
        p1 = min(point1,point2);
        offset = abs(point1-point2);
        if offset(2)/offset(1)>0.5
            p1(1)=p1(1)+0.5*offset(1)-offset(2);
            offset(1)=2*offset(2);
        else
            p1(2)=(p1(2)+0.5*offset(2))-0.25*offset(1);
            offset(2)=0.5*offset(1);
        end
        handles.ScreenParameters.XLim=[p1(1) p1(1)+offset(1)];
        handles.ScreenParameters.YLim=[p1(2) p1(2)+offset(2)];
    else
        handles.ScreenParameters.XLim=[0 1000000];
        handles.ScreenParameters.YLim=[0 6000000];
    end
%     h=findall(gcf,'Tag','WorldCoastLine');
%     if ~isempty(h)
%         set(h,'Visible','off');
%     end        
%     h=findall(gcf,'Tag','BackgroundBathymetry');
%     if ~isempty(h)
% %        set(h,'Visible','off');
%     end        
else
    handles.ScreenParameters.XLim=[-180 180];
    handles.ScreenParameters.YLim=[-90 90];
%     h=findall(gcf,'Tag','WorldCoastLine');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
%     h=findall(gcf,'Tag','BackgroundBathymetry');
%     if ~isempty(h)
%         set(h,'Visible','on');
%     end        
end

setHandles(handles);
