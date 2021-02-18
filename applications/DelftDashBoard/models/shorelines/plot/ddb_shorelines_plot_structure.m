function handles = ddb_shorelines_plot_structure(handles, opt, varargin)

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
        
        
        if handles.model.shorelines.nrstructures>0
            for as=1:handles.model.shorelines.nrstructures
                % First delete old shoreline
                try
                    delete(handles.model.shorelines.structures(as).handle);
                end
                handles.model.shorelines.structures(as).handle=[];
                xp=handles.model.shorelines.structures(as).x;
                yp=handles.model.shorelines.structures(as).y;
                
                % h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@change_shoreline,'tag','shorelines_shoreline','marker','o');
                if as==handles.model.shorelines.activestructure
                    %h=plot(xp,yp,'r','linewidth',2)
                    h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@modify_structure,'tag','shorelines_structure','color','k','marker','o');
                else
                    h=plot(xp,yp,'k','linewidth',1.5)
                end
                handles.model.shorelines.structures(as).handle=h;
                
                if vis
                    set(h,'Visible','on');
                else
                    set(h,'Visible','off');
                end
            end
        end
        
        
    case{'delete'}
        
        % First delete old structure
        try
            delete(handles.model.shorelines.structure.handle);
        end
        handles.model.shorelines.structure.handle=[];
        
    case{'update'}
        
        try
            h=handles.model.shorelines.structure.handle;
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
function modify_structure(h,x,y,number)

handles=getHandles;

% Delete temporary structure

% delete(h);
as=handles.model.shorelines.activestructure;
handles.model.shorelines.structures(as).x=x;
handles.model.shorelines.structures(as).y=y;
%handles.model.shorelines.structures(as).handle=h;

setHandles(handles);


