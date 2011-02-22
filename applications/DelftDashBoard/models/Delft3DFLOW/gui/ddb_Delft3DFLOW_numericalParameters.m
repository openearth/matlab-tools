function ddb_Delft3DFLOW_numericalParameters(varargin)


if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.numericalparameters');
else
    
    opt=varargin{1};
    
    switch(lower(opt))

        case{'selectdps'}
            handles=getHandles;
            if strcmpi(handles.Model(md).Input(ad).dpsOpt,'DP')
                switch handles.Model(md).Input(ad).dpuOpt
                    case{'min','upw'}
                    otherwise
                        handles.Model(md).Input(ad).dpuOptions={'MIN','UPW'};
                        handles.Model(md).Input(ad).dpuOpt='MIN';
                        setHandles(handles);     
                        setUIElement('delft3dflow.numericalparameters.selectdpu');
                end
            else
                handles.Model(md).Input(ad).dpuOptions={'MEAN','MIN','UPW','MOR'};
                setHandles(handles);     
                setUIElement('delft3dflow.numericalparameters.selectdpu');
            end
    end
end
