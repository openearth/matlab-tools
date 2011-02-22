function ddb_plotDelft3DFLOW(option,varargin)
% Option can be on of three things: plot, delete, update
%
% The function refreshScreen always uses the option inactive.
% Plot Delft3DFLOW is only used for one domain!

handles=getHandles;

imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

vis=1;
act=0;
idomain=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'active'}
                act=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                idomain=varargin{i+1};
        end
    end
end

if idomain==0
    n1=1;
    n2=handles.GUIData.nrFlowDomains;
else
    n1=idomain;
    n2=n1;
end

for id=n1:n2
    
    % Exception for grid, make bathy invisible if it's not the active grid
    if id~=ad
        bvis=0;
    else
        bvis=vis;
    end
    handles=ddb_Delft3DFLOW_plotBathy(handles,option,'domain',id,'visible',bvis);

    % Exception for grid, make grid grey if it's not the active grid
    if id~=ad
        col=[0.7 0.7 0.7];
    else
        col=[0 0 0];
    end
    handles=ddb_Delft3DFLOW_plotGrid(handles,option,'domain',id,'color',col,'visible',vis);
    
    if handles.Model(imd).Input(id).nrObservationPoints>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'observationpoints','domain',id,'visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrCrossSections>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'crosssections','domain',id,'visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrDryPoints>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'drypoints','domain',id,'visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrOpenBoundaries>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'openboundaries','domain',id,'visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrThinDams>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'thindams','domain',id,'visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrDischarges>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'discharges','domain',id,'visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrDrogues>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'drogues','domain',id,'visible',vis,'active',act);
    end

end

setHandles(handles);
