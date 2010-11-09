function ddb_UnibestCL_pushEditRayLocations(varargin)

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
    
% Load input
data = handles.Model(md).Input.RAYlocdata;
if ~isempty(data)
    X1 = data.X1;
    Y1 = data.Y1;
    X2 = data.X2;
    Y2 = data.Y2;
    Ray = data.Ray;
    handles.Model(md).Input.numberrays = length(X1);
    for ii = 1:length(X1)
       dat(ii,:) = [X1(ii),Y1(ii),X2(ii),Y2(ii),Ray(ii)];
    end

    % Create table
    columnformat = {'numeric', 'numeric','numeric','numeric','char'};
    columneditable = [true true true true true];
    t = uitable(fig,'Data',dat,'Position',[340 10 425 120],'ColumnWidth','auto','parent',get(handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(1).handle,'Parent'),...
       'ColumnName',{'X1' 'Y1' 'X2' 'Y2' 'Ray'},'ColumnFormat',columnformat,'ColumnEditable',columneditable,'CellEditCallback',@editRAYloctable);
    handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(end+1).handle = t;
    handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(end).style = {'table'};
    handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(end).tag = {'filerayloctable'};
end
setHandles(handles);
setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements);

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
handles.Model(md).Input.RAYlocdata = data;
setHandles(handles);