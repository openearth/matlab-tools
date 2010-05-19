function ddb_plotXBeach(handles,opt0,id,varargin)

ii=strmatch('XBeach',{handles.Model.Name},'exact');

if isempty(varargin)
    n1=1;
    n2=handles.GUIData.NrXBeachDomains;
else
    n1=varargin{1};
    n2=n1;
end

for id=n1:n2

    if strcmpi(opt0,'deactivate') && strcmpi(handles.ActiveModel.Name,'XBeach') && id==handles.ActiveDomain
        % Simply Changing Tab
        opt='deactivatebutkeepvisible';
    else
        opt=opt0;
    end

    ddb_plotXBeachBathymetry(handles,opt,id);
    ddb_plotXBeachGrid(handles,opt,id);
    
%     if handles.Model(md).Input(id).NrObservationPoints>0
%         ddb_plotFlowAttributes(handles,'ObservationPoints',opt,id,0,1);
%     end
% 
%     if handles.Model(md).Input(id).NrCrossSections>0
%         ddb_plotFlowAttributes(handles,'CrossSections',opt,id,0,1);
%     end
    
% id = id;

end


