function ddb_menuSelect(hObject, eventdata, varargin)

varargin=varargin{:};

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'callback'}
                cb=varargin{i+1};
            case{'options'}
                opt=varargin{i+1};
        end
    end
end
    
if isempty(opt)
    feval(cb);
else
    feval(cb,opt);
end
