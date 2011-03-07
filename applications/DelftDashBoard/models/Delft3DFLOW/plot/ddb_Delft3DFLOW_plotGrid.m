function handles=ddb_Delft3DFLOW_plotGrid(handles,opt,varargin)

imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

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

        % First delete old grid
        if isfield(handles.Model(imd).Input(id).grid,'plotHandles')
            if ~isempty(handles.Model(imd).Input(id).grid.plotHandles)
                try
                    delete(handles.Model(imd).Input(id).grid.plotHandles);
                end
            end
        end
        
        % Now plot new grid
        x=handles.Model(imd).Input(id).gridX;
        y=handles.Model(imd).Input(id).gridY;
        handles.Model(imd).Input(id).grid.plotHandles=ddb_plotCurvilinearGrid(x,y,'color',col);
        if vis
            set(handles.Model(imd).Input(id).grid.plotHandles,'Color',col,'Visible','on');
        else
            set(handles.Model(imd).Input(id).grid.plotHandles,'Color',col,'Visible','off');
        end
        
    case{'delete'}

        % Delete old grid
        if isfield(handles.Model(imd).Input(id).grid,'plotHandles')
            if ~isempty(handles.Model(imd).Input(id).grid.plotHandles)
                try
                    delete(handles.Model(imd).Input(id).grid.plotHandles);
                end
            end
        end

    case{'update'}
        if isfield(handles.Model(imd).Input(id).grid,'plotHandles')
            if ~isempty(handles.Model(imd).Input(id).grid.plotHandles)
                try                    
                    set(handles.Model(imd).Input(id).grid.plotHandles,'Color',col);
                    if vis
                        set(handles.Model(imd).Input(id).grid.plotHandles,'Color',col,'Visible','on');
                    else
                        set(handles.Model(imd).Input(id).grid.plotHandles,'Color',col,'Visible','off');
                    end
                end
            end
        end
end
