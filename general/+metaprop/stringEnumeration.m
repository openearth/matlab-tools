% STRINGENUMERATION property for a string that is limited to a set of possible values (on/off,left/right/top/bottom, etc)
classdef stringEnumeration < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Character');
    end
    properties (SetAccess = immutable)
        jEditor
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    properties
        Options = {}
    end
    methods
        function self = stringEnumeration(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'row'};
            self.DefaultClasses    = {'char'};

            self.CheckDefault();
                    
            self.jEditor = com.jidesoft.grid.ListComboBoxCellEditor(self.Options);
        end
        function set.Options(self,value)
            % check options
            validateattributes(value,{'cell'},{'vector','nonempty'},self.DefiningClass.Name,self.Name)
            assert(iscellstr(value))
            self.Options = value;
        end
        % Overload Check method
        function Check(self,value) % error/no error
            validatestring(value,self.Options,self.DefiningClass.Name,self.Name);
        end
        
    end
end