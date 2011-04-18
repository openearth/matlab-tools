function handles=ddb_Delft3DFLOW_plotBathy(handles,option,varargin)

% Default values
id=ad;
vis=1;
act=1;

% model number imd
imd=strmatch('Delft3DFLOW',{handles.Model(:).name},'exact');

% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i}))
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                act=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
        end
    end
end

switch lower(option)

    case{'plot'}

        % First delete old bathy
        if isfield(handles.Model(imd).Input(id).bathy,'plotHandles')
            if ~isempty(handles.Model(imd).Input(id).bathy.plotHandles)
                try
                    delete(handles.Model(imd).Input(id).bathy.plotHandles);
                end
            end
        end

        if size(handles.Model(md).Input(ad).depthZ,1)>0
           
            x=handles.Model(md).Input(id).gridX;
            y=handles.Model(md).Input(id).gridY;
%            z=handles.Model(md).Input(id).depth;
            z=zeros(size(x));
            z(z==0)=NaN;
            z(1:end-1,1:end-1)=handles.Model(md).Input(id).depthZ(2:end,2:end);
%            z=handles.Model(md).Input(id).depthZ(2:end,2:end);

            handles.Model(imd).Input(id).bathy.plotHandles=ddb_plotBathy(x,y,z);
            
            if vis
                set(handles.Model(imd).Input(id).bathy.plotHandles,'Visible','on');
            else
                set(handles.Model(imd).Input(id).bathy.plotHandles,'Visible','off');
            end

        end

    case{'delete'}
        if isfield(handles.Model(imd).Input(id).bathy,'plotHandles')
            if ~isempty(handles.Model(imd).Input(id).bathy.plotHandles)
                try
                    delete(handles.Model(imd).Input(id).bathy.plotHandles);
                end
            end
        end

    case{'update'}
        if isfield(handles.Model(imd).Input(id).bathy,'plotHandles')
            if ~isempty(handles.Model(imd).Input(id).bathy.plotHandles)
                try
                    if vis
                        set(handles.Model(imd).Input(id).bathy.plotHandles,'Visible','on');
                    else
                        set(handles.Model(imd).Input(id).bathy.plotHandles,'Visible','off');
                    end
                end
            end
        end

end

