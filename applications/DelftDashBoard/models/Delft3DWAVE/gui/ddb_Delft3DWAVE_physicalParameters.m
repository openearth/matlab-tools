function ddb_Delft3DWAVE_physicalParameters(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'togglewind'}
            toggleWind;
    end
end

%%
function toggleWind

handles=getHandles;
if ~handles.Model(md).Input.windgrowth
    handles.Model(md).Input.whitecapping='None';
    handles.Model(md).Input.quadruplets=0;
end
setHandles(handles);
