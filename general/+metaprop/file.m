% FILE property that points to a file. Editor is a filepicker
classdef file < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Character');
    end
    properties (SetAccess=immutable)    
        jEditor = com.jidesoft.grid.FileCellEditor; 
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end    
    methods
        function self = file(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'row'};
            self.DefaultClasses    = {'char'};

            self.CheckDefault();
        end
    end
    methods (Static)
        function mValue = mValue(jValue)
            % conversion from java value to matlab value
            mValue = char(jValue);
        end
    end
end