function ddb_OceanModelsToolbox_download(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('oceanmodelspanel.download');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'nesthd1'}
            nestHD1;
    end    
end
