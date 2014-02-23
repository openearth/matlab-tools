% LOGICALSCALAR property for a single logical (true/false)
classdef logicalScalar < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Boolean');
    end
    properties (SetAccess=immutable)
        jEditor = com.jidesoft.grid.BooleanCheckBoxCellEditor;
        jRenderer = com.jidesoft.grid.BooleanCheckBoxCellRenderer;
    end
    methods
        function self = logicalScalar(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'scalar'};
            self.DefaultClasses    = {'logical'};

            self.CheckDefault();
        end
        function updateRenderer(self)
            self.jRenderer.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        end
     end
end