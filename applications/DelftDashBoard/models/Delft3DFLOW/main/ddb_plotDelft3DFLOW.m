function ddb_plotDelft3DFLOW(handles,opt0,varargin)

imd=strmatch('Delft3DFLOW',{handles.Model(:).Name},'exact');

if isempty(varargin)
    n1=1;
    n2=handles.GUIData.NrFlowDomains;
else
    n1=varargin{1};
    n2=n1;
end

for id=n1:n2

    if strcmpi(opt0,'deactivate') && strcmpi(handles.ActiveModel.Name,'Delft3DFLOW') && id==handles.ActiveDomain
        % Simply Changing Tab
        opt='deactivatebutkeepvisible';
        optnew='update';
        vis=1;
        act=0;        
    else
        opt=opt0;

        optnew='update';
        vis=0;
        act=0;        
    end

    ddb_plotFlowBathymetry(handles,opt,id);
    ddb_plotGrid(handles.Model(imd).Input(id).GridX,handles.Model(imd).Input(id).GridY,id,'FlowGrid',opt);
    
    if handles.Model(imd).Input(id).NrObservationPoints>0
        ddb_plotFlowAttributes(handles,'ObservationPoints',opt,id,0,1);
    end

    if handles.Model(imd).Input(id).NrCrossSections>0
        ddb_plotFlowAttributes(handles,'CrossSections',opt,id,0,1);
    end

    if handles.Model(imd).Input(id).nrDryPoints>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'drypoints','visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).NrOpenBoundaries>0
        ddb_plotFlowAttributes(handles,'OpenBoundaries',opt,id,0,1);
    end

    if handles.Model(imd).Input(id).NrThinDams>0
        ddb_plotFlowAttributes(handles,'ThinDams',opt,id,0,1);
    end

    if handles.Model(imd).Input(id).NrDischarges>0
        ddb_plotFlowAttributes(handles,'Discharges',opt,id,0,1);
    end

    if handles.Model(imd).Input(id).NrDrogues>0
        ddb_plotFlowAttributes(handles,'Drogues',opt,id,0,1);
    end

end
