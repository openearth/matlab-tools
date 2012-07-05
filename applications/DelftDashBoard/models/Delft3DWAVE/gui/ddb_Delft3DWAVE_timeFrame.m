function ddb_Delft3DWAVE_timeFrame(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'settimelist'}
            setTimeList;
    end
end

%%
function setTimeList

handles = getHandles;
handles.Model(md).Input.listtimes={datestr(handles.Model(md).Input.selectedtime,'yyyy mm dd HH MM SS')};
setHandles(handles);
