function ddb_plotXBeach(handles,varargin)

ii=strmatch('XBeach',{handles.Model.name},'exact');

% if isempty(varargin)
%     n1=1;
%     n2=handles.GUIData.nrXBeachDomains;
% else
%    n1=varargin{2};
%    n2=n1;
% end
n1 = 1;
n2 = 1;

for id=n1:n2

%     if strcmpi(opt0,'deactivate') && strcmpi(handles.activeModel.name,'XBeach') && id==handles.activeDomain
%         % Simply Changing Tab
%         opt='deactivatebutkeepvisible';
%     else
%         opt=opt0;
%     end

   ddb_plotXBeachBathymetry(handles,id);
   ddb_plotXBeachGrid(handles,id);
   
   % % TO DO: ZOOM TO MODEL DOMAIN
    
   % TO DO: 
   % - PLOT OFFSHORE BOUNDARY + ORIGIN OF MODEL
   % - PLOT OBSERVATION POINTS
   
%     if handles.Model(md).Input(id).NrObservationPoints>0
%         ddb_plotFlowAttributes(handles,'ObservationPoints',opt,id,0,1);
%     end
% 
%     if handles.Model(md).Input(id).NrCrossSections>0
%         ddb_plotFlowAttributes(handles,'CrossSections',opt,id,0,1);
%     end
    
% id = id;

end


