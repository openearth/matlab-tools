function ddb_UnibestCL_pushEnterRayLocations(varargin)

handles=getHandles;

fig = gcf;
data = [];

elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements;

% Find old table
for ii = 1:length(elements)
    A(ii) = strcmp(elements(ii).style,'table');
end
AA = find(A==1);

%Delete old table
if  ~isempty(AA) 
    index = setdiff(1:length(elements),AA);
    set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(AA).handle,'Visible','off');
    handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(index);
end
    
% Create input
numberrays = handles.Model(md).Input.numberrays;
for ii = 1:numberrays
    dat(ii,:) = [0,0,0,0,{' '}];
    data.X1(ii) = dat{ii,1};
    data.Y1(ii) = dat{ii,2};
    data.X2(ii) = dat{ii,3};
    data.Y2(ii) = dat{ii,4};
end
data.Ray = dat(:,5);
handles.Model(md).Input.RAYlocdata = data;

% Create table
columnformat = {'numeric', 'numeric','numeric','numeric','char'};
columneditable = [true true true true true];
t = uitable(fig,'Data',dat,'Position',[340 10 425 120],'ColumnWidth','auto','parent',get(handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(4).handle,'Parent'),...
   'ColumnName',{'X1' 'Y1' 'X2' 'Y2' 'Ray'},'ColumnFormat',columnformat,'ColumnEditable',columneditable,'CellEditCallback',@editRAYloctable);
handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(end+1).handle = t;
handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(end).style = {'table'};
handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(end).tag = {'createrayloctable'};
setHandles(handles);
% setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements);

function editRAYloctable(hObject,eventdata)
handles=getHandles;
dat = get(hObject,'Data');
if  isfield(handles.Model(md).Input,'RAYlocdata')
    data = handles.Model(md).Input.RAYlocdata;
end
data.X1 = dat(:,1);
data.Y1 = dat(:,2);
data.X2 = dat(:,3);
data.Y2 = dat(:,4);
data.Ray = dat(:,5);
for jj = 1:length(data.X1);
    handles.Model(md).Input.RAYlocdata.X1(jj) = data.X1{jj};
    handles.Model(md).Input.RAYlocdata.Y1(jj) = data.Y1{jj};
    handles.Model(md).Input.RAYlocdata.X2(jj) = data.X2{jj};
    handles.Model(md).Input.RAYlocdata.Y2(jj) = data.Y2{jj};
end
handles.Model(md).Input.RAYlocdata.Ray = data.Ray;
setHandles(handles);