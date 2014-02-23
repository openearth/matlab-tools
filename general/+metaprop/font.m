% FONT property for a java font description. Editor is a dropdown with all available fonts
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
    % some methods to facilitate translation from java to matlab
    methods (Static)
        function FontName = FontName(value)
            FontName = char(value.getName);
        end
        function FontSize = FontSize(value)
            FontSize = double(value.getSize);
        end
        function FontAngle = FontAngle(value)
            if value.isItalic
                FontAngle = 'italic';
            else
                FontAngle = 'normal';
            end
        end
        function FontWeight = FontWeight(value)
            if value.isBold
                FontWeight = 'bold';
            else
                FontWeight = 'normal';
            end
        end
    end
end