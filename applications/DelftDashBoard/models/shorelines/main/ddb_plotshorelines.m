function ddb_plotshorelines(option,varargin)

% Option can be on of three things: plot, delete, update
%
% The function refreshScreen always uses the option inactive.

handles=getHandles;

vis=1;
act=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'active'}
                act=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
        end
    end
end

switch option
    
    case{'plot'}
        
        col='r';
        handles=ddb_shorelines_plot_shoreline(handles,option,'color',col,'visible',1);
        
    case{'delete'}
        
        handles=ddb_shorelines_plot_shoreline(handles,option);
        
    case{'update'}
        
        % Change colors and visibility
        
        if act
            col=[1 1 0];
            vis=1;
        else
            col=[0.8 0.8 0.8];
            vis=0;
        end
        
        
        handles=ddb_shorelines_plot_shoreline(handles,option,'color',col,'visible',vis);
        
end

setHandles(handles);
