function ddb_UnibestCL_pushEditMdaData(varargin)

handles=getHandles;

fig = gcf;
data = [];

% Delete old table
if  isfield(get(handles.Model(md).GUI.elements.tabs(2).elements.tabs.elements(end).handle),'Data')
    set(handles.Model(md).GUI.elements.tabs(2).elements.tabs.elements(end).handle,'Visible','off');
    handles.Model(md).GUI.elements.tabs(2).elements.tabs.elements = handles.Model(md).GUI.elements.tabs(2).elements.tabs.elements(1:end-1);
    setHandles(handles);
end

% Read MDA file
if  isfield(handles.Model(md).Input,'MDAfile')
    filename = handles.Model(md).Input.MDAfile;
    [MDAdata]=ddb_readMDA_new(filename);
    handles.Model(md).Input.MDAdata = MDAdata;
    data = MDAdata;
end

% Plot table
if ~isempty(data)
   Xw = data.X;
   Yw = data.Y;
   Y1 = data.Y1;
   Y2 = data.Y2;
   N = data.nrgridcells;
   Ray = data.nr;
   for ii = 1:length(Xw)
       dat(ii,:) = [Xw(ii),Yw(ii),Y1(ii),Y2(ii),N(ii),Ray(ii)];
   end
   columnformat = {'numeric', 'numeric','numeric','numeric','numeric','numeric'};
   columneditable = [true true true true true true];
   
   t = uitable(fig,'Data',dat,'Position',[300 10 510 120],'ColumnWidth','auto','parent',handles.Model(md).GUI.elements.tabs(2).elements.handle,...
       'ColumnName',{'Xw' 'Yw' 'Y1' 'Y2' 'N' 'Ray'},'ColumnFormat',columnformat,'ColumnEditable',columneditable,'CellEditCallback',@editMDAtable);
   handles.Model(md).GUI.elements.tabs(2).elements.tabs.elements(end+1).handle = t;
   setHandles(handles);
end

function editMDAtable(hObject,eventdata)
handles=getHandles;
dat = get(hObject,'Data');
if  isfield(handles.Model(md).Input,'MDAdata')
    data = handles.Model(md).Input.MDAdata;
end
data.X = dat(:,1);
data.Y = dat(:,2);
data.Y1 = dat(:,3);
data.Y2 = dat(:,4);
data.nrgridcells = dat(:,5);
data.nr = dat(:,6);
handles.Model(md).Input.MDAdata = data;
setHandles(handles);
ddb_plotMDA(handles,'plot',1);