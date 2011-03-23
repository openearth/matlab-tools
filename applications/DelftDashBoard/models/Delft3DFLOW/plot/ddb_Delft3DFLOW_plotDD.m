function handles=ddb_Delft3DFLOW_plotDD(handles,opt,varargin)

imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

vis=1;
act=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                act=varargin{i+1};
        end
    end
end

switch lower(opt)

    case{'plot'}

        % First delete old dd boundaries
        if isfield(handles.Model(imd),'DDplotHandles')
            if ~isempty(handles.Model(imd).DDplotHandles)
                try
                    delete(handles.Model(imd).DDplotHandles);
                end
            end
        end

        % Plot new boundaries
        ddbound=handles.Model(imd).DDBoundaries;
        if ~isempty(ddbound)
            handles.Model(imd).DDplotHandles=[];
            for i=1:length(ddbound)
                z=zeros(size(ddbound(i).x))+1000;
                plt=plot(ddbound(i).x,ddbound(i).y);
                set(plt,'LineWidth',3,'Color',[1 0.5 0],'Tag','ddboundaries');
                handles.Model(imd).DDplotHandles(i)=plt;
            end
        end
        
    case{'delete'}

        % Delete old dd boundaries
        if isfield(handles.Model(imd),'DDplotHandles')
            if ~isempty(handles.Model(imd).DDplotHandles)
                try
                    delete(handles.Model(imd).DDplotHandles);
                end
            end
        end

    case{'update'}
        if isfield(handles.Model(imd),'DDplotHandles')
            if ~isempty(handles.Model(imd).DDplotHandles)
                try                    
                    if act
                        set(handles.Model(imd).DDplotHandles,'Visible','on');
                    else
                        set(handles.Model(imd).DDplotHandles,'Visible','off');
                    end
                end
            end
        end
end
