function ddb_Delft3DWAVE_grids(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dwave.grids');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
    end
end