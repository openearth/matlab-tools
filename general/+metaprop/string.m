classdef string < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Character');
    end
    properties (SetAccess=immutable)    
        jEditor = com.jidesoft.grid.StringCellEditor; 
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end    
    methods
        function self = string(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'row'};
            self.DefaultClasses    = {'char'};

            self.CheckDefault();
        end
    end
end