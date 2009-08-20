classdef mtesteventdata < event.EventData
    
    properties
        workspace = {};
        removetempobj = true;
        time = [];
    end
    
    methods
        function obj = mtesteventdata(varargin)
            vars = varargin{1};
            ws = cell(length(vars),2);
            ws(strcmp(ws(:,1),'mtest_245y7e_tic'),:)=[];
            for ivars = 1:length(vars)
                ws{ivars,1} = vars(ivars).name;
                ws{ivars,2} = evalin('caller',vars(ivars).name);
            end
            id = find(strcmp(varargin,'remove'),1,'first');
            if ~isempty(id)
                obj.removetempobj = varargin{id+1};
            end
            id = find(strcmp(varargin,'time'),1,'first');
            if ~isempty(id)
                obj.time = varargin{id+1};
            end

            obj.workspace = ws;
        end
    end
    
end