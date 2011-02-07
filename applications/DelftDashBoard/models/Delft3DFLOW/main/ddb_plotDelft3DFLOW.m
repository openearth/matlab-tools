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
    else
        opt=opt0;
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
        handles=ddb_Delft3DFLOW_plotDryPoints(handles,opt,'active',1,'domain',id);
%        ddb_plotFlowAttributes(handles,'DryPoints',opt,id,0,1);
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
