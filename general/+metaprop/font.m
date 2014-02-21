classdef font < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.awt.Font');
    end
    properties (SetAccess=immutable)    
        jEditor = com.jidesoft.grid.FontCellEditor; 
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end    
    methods
        function self = font(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'scalar'};
            self.DefaultClasses    = {'java.awt.Font'};

            self.CheckDefault();
        end
    end
%     methods (Static)
%         function mValue = mValue(jValue)
%             % conversion from java value to matlab value
%             mValue = jValue;
%         end
%     end
end