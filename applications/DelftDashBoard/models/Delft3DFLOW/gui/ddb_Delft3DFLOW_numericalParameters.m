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
            
            % Depth in cell centres
            handles.Model(md).Input(ad).depthZ=GetDepthZ(handles.Model(md).Input(ad).depth,handles.Model(md).Input(ad).dpsOpt);
            handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','visible',1,'domain',ad);
            
            % Boundary depths
            x=handles.Model(md).Input(ad).gridX;
            y=handles.Model(md).Input(ad).gridY;
            depthZ=handles.Model(md).Input(ad).depthZ;
            kcs=handles.Model(md).Input(ad).kcs;
            for ib=1:length(handles.Model(md).Input(ad).openBoundaries);                
                [xb,yb,zb,alphau,alphav,side,orientation]=delft3dflow_getBoundaryCoordinates(handles.Model(md).Input(ad).openBoundaries(ib),x,y,depthZ,kcs);
                handles.Model(md).Input(ad).openBoundaries(ib).depth=zb;
            end
            
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
