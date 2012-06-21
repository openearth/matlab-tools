function ddb_plotDelft3DWAVE(option,varargin)

% Option can be on of three things: plot, delete, update
%
% The function refreshScreen always uses the option inactive.
% Plot Delft3DFLOW is only used for one domain!

handles=getHandles;

imd=strmatch('Delft3DWAVE',{handles.Model(:).name},'exact');

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
    n2=handles.Model(imd).Input.NrComputationalGrids;
else
    % Update one domain
    n1=idomain;
    n2=n1;
end

if idomain==0 && ~act
    vis=0;
end
    
for id=n1:n2
    
    % Exception for grid, make grid grey if it's not the active grid
    % or if all domains are selected and not active
    if id~=awg || ~act
        col=[0.7 0.7 0.7];
    else
        col=[0.35 0.35 0.35];
    end
    
    % Always plot grid (even is vis is 0)
    handles=ddb_Delft3DWAVE_plotGrid(handles,option,'domain',id,'color',col,'visible',1);
           
end

setHandles(handles);


