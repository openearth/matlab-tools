% CELLSTRING property that can be either a string or a cellstring. Has multiline editor
classdef cellstring < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Character');
    end
    properties (SetAccess=immutable)
        jEditor = com.jidesoft.grid.MultilineStringCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    methods
        function self = cellstring(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {};
            self.DefaultClasses    = {};
            
            self.CheckDefault();
        end
        function Check(self,value) % error/no error
            if iscellstr(value)
                atts = [{'vector'},self.Attributes];
                % merge default and custom attributes, as more atts is more restrictive
                % more classes means more permissive, so do seperate checks for
                % default attributes and custom classes. If no custom classes are
                % defined, skip the ceck
                validateattributes(value,{'cell'},atts,self.DefiningClass.Name,self.Name)
                if ~isempty(self.Classes)
                    validateattributes(value,self.Classes,{},self.DefiningClass.Name,self.Name)
                end
            elseif ischar(value)
                atts = [{'row'},self.Attributes];
                validateattributes(value,{'char'},atts,self.DefiningClass.Name,self.Name)
            else
                error('Eroro setting %s.%s, expected input to be a string or cellstring',self.DefiningClass.Name,self.Name)
            end
        end
    end
    
    methods (Static)
        function jValue = jValue(mValue)
            % conversion from matlab value to java value
            if iscellstr(mValue)
                jValue = sprintf('%s\n',mValue{:});
                % trim last linebreak
                jValue = jValue(1:end-1);
            else
                jValue = mValue;
            end
        end
        function mValue = mValue(jValue)
            % conversion from java value to matlab value
            % make cellstr from string with linebreaks
            mValue = textscan(jValue,'%s');
            mValue = mValue{1};
            % if sinlge line, convert cell to char
            if isscalar(mValue)
                mValue = mValue{1};
            end
        end
    end
end