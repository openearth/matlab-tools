function ddb_plotXBeach(option, varargin)

handles=getHandles;

imd=strmatch('XBeach',{handles.Model(:).name},'exact');

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
    % Update all domains
    n1=1;
    n2=handles.Model(imd).nrDomains;
else
    % Update one domain
    n1=idomain;
    n2=n1;
end

if idomain==0 && ~act
    vis=0;
end

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

try
   ddb_plotXBeachBathymetry(handles,id);
   ddb_plotXBeachGrid(handles,id);
end
   
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


