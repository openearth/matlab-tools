classdef doubleScalar < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Double')
    end
    properties (SetAccess=immutable)
        jEditor = com.jidesoft.grid.CalculatorCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    methods
        function self = doubleScalar(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'scalar'};
            self.DefaultClasses    = {'numeric'};

            self.CheckDefault();
        end
    end
    methods (Static)
        function jValue = jValue(value)
            jValue = value;
        end
    end
end