function handles = ddb_shorelines_plot_shoreline(handles, opt, varargin)

col=[0.35 0.35 0.35];
vis=1;
id=ad;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old shoreline
        try
            delete(handles.model.shorelines.domain.shoreline.handle);
        end
        handles.model.shorelines.domain.shoreline.handle=[];
        
        if handles.model.shorelines.domain.shoreline.length>0
            
            xp=handles.model.shorelines.domain.shoreline.x;
            yp=handles.model.shorelines.domain.shoreline.y;
            
            h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@change_shoreline,'tag','shorelines_shoreline','marker','o');
            handles.model.shorelines.domain.shoreline.handle=h;
                        
            if vis
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
            
        end
        
        
    case{'delete'}
        
        % First delete old shoreline
        try
            delete(handles.model.shorelines.domain.shoreline.handle);
        end
        handles.model.shorelines.domain.shoreline.handle=[];
        
    case{'update'}
        
        try
            h=handles.model.shorelines.domain.shoreline.handle;
            if ~isempty(h)
                try
                    if vis
                        set(h,'Visible','on');
                    else
                        set(h,'Visible','off');
                    end
                end
            end
        end
end

%%
function change_shoreline(h,x,y,nr)

handles=getHandles;
handles.model.shorelines.domain.shoreline.x=x;
handles.model.shorelines.domain.shoreline.y=y;
setHandles(handles);
