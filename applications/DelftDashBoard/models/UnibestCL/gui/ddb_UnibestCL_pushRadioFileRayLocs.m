function ddb_UnibestCL_pushRadioFileRayLocs(hObject,eventdata)

handles=getHandles;

elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements;

% Check whether table exists
for ii = 1:length(elements)
    A(ii) = strcmp(elements(ii).style,'table');
    B(ii) = strcmp(elements(ii).tag,'createrayloctable');
end
AA = find(A==1);
BB = find(B==1);

% If file table, make invisible; if create table, make visible
if      ~isempty(AA) & ~isempty(BB)
        set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(AA).handle,'Visible','off');
elseif  ~isempty(AA)
        set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(2).elements(AA).handle,'Visible','on');
end

handles=getHandles;