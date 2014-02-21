classdef numericArray < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('[[D')
    end
    properties (SetAccess=immutable)        
        jEditor = com.jidesoft.grid.DoubleCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    methods
        function self = numericArray(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultClasses    = {'numeric'};

            self.CheckDefault();
        end
    end
end