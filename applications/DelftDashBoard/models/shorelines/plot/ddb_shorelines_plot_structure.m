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
        
        
        if handles.model.shorelines.domain.nrstructures>0
            for as=1:handles.model.shorelines.domain.nrstructures
                % First delete old shoreline
                try
                    delete(handles.model.shorelines.domain.structures(as).handle);
                end
                handles.model.shorelines.domain.structures(as).handle=[];
                xp=handles.model.shorelines.domain.structures(as).x;
                yp=handles.model.shorelines.domain.structures(as).y;
                
                % h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@change_shoreline,'tag','shorelines_shoreline','marker','o');
                if as==handles.model.shorelines.domain.activestructure
                    %h=plot(xp,yp,'r','linewidth',2)
                    h=gui_polyline('plot','x',xp,'y',yp,'changecallback',@modify_structure,'tag','shorelines_structure','color','k','marker','o');
                else
                    h=plot(xp,yp,'k','linewidth',1.5)
                end
                handles.model.shorelines.domain.structures(as).handle=h;
                
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
            delete(handles.model.shorelines.domain.structure.handle);
        end
        handles.model.shorelines.domain.structure.handle=[];
        
    case{'update'}
        
        try
            h=handles.model.shorelines.domain.structure.handle;
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
as=handles.model.shorelines.domain.activestructure;
handles.model.shorelines.domain.structures(as).x=x;
handles.model.shorelines.domain.structures(as).y=y;
%handles.model.shorelines.domain.structures(as).handle=h;

setHandles(handles);


