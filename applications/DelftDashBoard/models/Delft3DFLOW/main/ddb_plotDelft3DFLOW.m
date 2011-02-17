function ddb_plotDelft3DFLOW(handles,option,plotlevel,domainnr)
% Option can be three things: plot, delete, update
% There are three options 
% There are three plot levels:
% 1) active
% 2) inactive
% 3) invisible
%
% The function refreshScreen always uses the option inactive.
% Plot Delft3DFLOW is only used for one domain!

imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

vis=0;
act=0;

switch plotlevel
    case 1
        act=1;
        vis=1;
    case 2
        act=0;
        vis=1;
    case 3
        act=0;
        vis=0;
end


if domainnr==0
    n1=1;
    n2=handles.GUIData.nrFlowDomains;
else
    n1=domainnr;
    n2=n1;
end

optnew=option;

for id=n1:n2

%     if strcmpi(opt0,'deactivate') && strcmpi(handles.activeModel.name,'Delft3DFLOW') && id==handles.activeDomain
%         % Simply Changing Tab
%         opt='deactivatebutkeepvisible';
%         optnew='update';
%         vis=1;
%         act=0;        
%     else
%         opt=opt0;
%         optnew='update';
%         vis=0;
%         act=0;        
%     end
    
    ddb_plotFlowBathymetry(handles,option,id);

    % Exception for grid
    ddb_plotGrid(handles.Model(imd).Input(id).gridX,handles.Model(imd).Input(id).gridY,id,'FlowGrid',option);
    
    if handles.Model(imd).Input(id).nrObservationPoints>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'observationpoints','visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrCrossSections>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'crosssections','visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrDryPoints>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'drypoints','visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrOpenBoundaries>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'openboundaries','visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrThinDams>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'thindams','visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrDischarges>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'discharges','visible',vis,'active',act);
    end

    if handles.Model(imd).Input(id).nrDrogues>0
        ddb_Delft3DFLOW_plotAttributes(handles,optnew,'drogues','visible',vis,'active',act);
    end

end
