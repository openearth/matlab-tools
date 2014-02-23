% DATE property for matlab datenums, has calender editor. Does not (yet) support editing time 
classdef date < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.util.Date');
    end
    properties (SetAccess=immutable)    
        jEditor
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end    
    methods
        function self = date(varargin)
            self = self@metaprop.base(varargin{:});
            
            dateModel = com.jidesoft.combobox.DefaultDateModel;
            dateFormat = java.text.SimpleDateFormat('dd-MMM-yyyy');
            dateModel.setDateFormat(dateFormat);

            self.jEditor   = com.jidesoft.grid.DateCellEditor(dateModel, 1);

            % set specific restrictions
            self.DefaultAttributes = {'scalar'};
            self.DefaultClasses    = {'double'};

            self.CheckDefault();
        end
    end
    methods (Static)
        function mValue = mValue(jValue)
            % conversion from java value to matlab value
            mValue = datenum(...
                jValue.getYear + 1900,...
                jValue.getMonth + 1,...
                jValue.getDate,...
                jValue.getHours,...
                jValue.getMinutes,...
                jValue.getSeconds);
        end
        function jValue = jValue(mValue)
            jValue = java.util.Date(datestr(mValue));
        end
    end
end