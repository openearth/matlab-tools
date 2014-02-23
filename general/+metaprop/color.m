% COLOR property with three numbers between 0 and 1. Has colorpicker editor
classdef color < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.awt.Color')
    end
    properties (SetAccess=immutable)        
        jEditor = com.jidesoft.grid.ColorCellEditor;
        jRenderer = com.jidesoft.grid.ColorCellRenderer;
    end
    methods
        function self = color(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultClasses    = {'numeric'};
            self.DefaultAttributes = {'size',[1 3],'>=',0,'<=',1};
            self.CheckDefault();
        end
        function Check(self,value)
            value = self.parseOneLetterColor(value);
            Check@metaprop.base(self,value);
        end
    end
    methods (Static)
        function value = parseOneLetterColor(value)
            % make exception for one-letter named colors
            if ischar(value) && numel(value) == 1
                if any(value == 'krgybmcw')
                    value = bitget(find('krgybmcw'==value)-1,1:3);
                end
            end
        end
        function jValue = jValue(mValue)
            mValue = metaprop.color.parseOneLetterColor(mValue);
            jValue = java.awt.Color(mValue(1),mValue(2),mValue(3));
        end
        function mValue = mValue(jValue)
            mValue = jValue.getColorComponents([])';
        end 
    end
end