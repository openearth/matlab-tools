function setUIElement(th,varargin)

return

dependencyUpdate=1;

for i=1:length(varargin)
    if ischar(lower(varargin{i}))
        switch lower(varargin{i})
            case{'dependencyupdate'}
                dependencyUpdate=varargin{i+1};
        end
    end
end

% Check whether input is handle or tag
if ischar(th)
    h=findobj(gcf,'Tag',th);
else
    h=th;
end

getFcn=getappdata(h,'getFcn');

el=getappdata(h,'element');

s=feval(getFcn);


switch lower(el.style)
    
    %% Standard elements
    
    case{'edit'}

        val=getSubFieldValue(s,el.variable);
        if ~isempty(el.type)
            tp=lower(el.type);
        else
            tp=lower(el.variable.type);
        end
        switch tp
            case{'string'}
            case{'datetime'}
                val=datestr(val,'yyyy mm dd HH MM SS');
            case{'date'}
                val=datestr(val,'yyyy mm dd');
            case{'time'}
                val=datestr(val,'HH MM SS');
            otherwise
                if isnan(val)
                    val='';
                else
                    if ~isempty(el.format)
                        val=num2str(val,el.format);
                    else
                        val=num2str(val);
                    end
                end
        end
        
        set(el.handle,'String',val);

        % Set text
        if ~isempty(el.text)
            if isfield(el.text,'variable')
                val=getSubFieldValue(s,el.text.variable);
                % Text
                set(el.textHandle,'String',val);
                setTextPosition(el.textHandle,el.position,el.textPosition);
            end
        end
        
    case{'checkbox'}
        val=getSubFieldValue(s,el.variable);
        set(el.handle,'Value',val);
        % Set text
        if ~isempty(el.text)
            if isfield(el.text,'variable')
                val=getSubFieldValue(s,el.text.variable);
                % Text
                set(el.handle,'String',val);
                % Length of string is known
                pos=get(el.handle,'Position');
                ext=get(el.handle,'Extent');
                pos(3)=ext(3)+20;
                pos(4)=20;                
                set(el.handle,'Position',pos);
            end
        end

    case{'togglebutton'}
        val=getSubFieldValue(s,el.variable);
        set(el.handle,'Value',val);

    case{'radiobutton'}
        val=getSubFieldValue(s,el.variable);
        
        if ~isempty(el.type)
            tp=lower(el.type);
        else
            tp=lower(el.variable.type);
        end

        switch lower(tp)
            case{'string'}
                if strcmpi(el.value,val)
                    set(el.handle,'Value',1);
                else
                    set(el.handle,'Value',0);
                end
            otherwise
                if str2double(el.value)==val
                    set(el.handle,'Value',1);
                else
                    set(el.handle,'Value',0);
                end
        end
        
        if isfield(el.text,'variable')
            val=getSubFieldValue(s,el.text.variable);
            % Text
            set(el.handle,'String',val);
        end

    case{'listbox','popupmenu'}

        if isfield(el.list.text,'variable')
            stringList=getSubFieldValue(s,el.list.text.variable);
        else
            stringList=el.list.text;
        end
        
        ii=1;
        if isempty(stringList)
            ii=1;
        elseif isempty(stringList{1})
            ii=1;
        else           
            if ~isempty(el.type)
                tp=lower(el.type);
            else
                tp=lower(el.variable.type);
            end
            switch tp
                case{'string'}
                    if ~isempty(el.variable)
                        str=getSubFieldValue(s,el.variable);
                        %                    if isfield(el.list.value,'variable')
                        if isfield(el.list,'value')
                            if isfield(el.list.value,'variable')
                                values=getSubFieldValue(s,el.list.value.variable);
                            else
                                values=el.list.value;
                            end
                            ii=strmatch(lower(str),lower(values),'exact');
                        else
                            ii=strmatch(lower(str),lower(stringList),'exact');
                        end
                    end
                otherwise
%                    ii=getSubFieldValue(s,el.variable);
                    if ~isempty(el.multivariable)
                        ii=getSubFieldValue(s,el.multivariable);
                    else
                        if isfield(el.list,'value')
                            if isfield(el.list.value,'variable')
                                values=getSubFieldValue(s,el.list.value.variable);
                            else
                                values=el.list.value;
                            end
                            for jj=1:length(values)
                                vnum(jj)=str2double(values{jj});
                            end
                            val=getSubFieldValue(s,el.variable);
                            ii=find(vnum==val);
                        else
                            ii=getSubFieldValue(s,el.variable);
                        end
                    end
            end
        end
        set(el.handle,'Value',ii);
        set(el.handle,'String',stringList);

    case{'selectcolor'}

        if isfield(el,'includenone')
            includenone=el.includenone;
        else
            includenone=0;
        end
        stringList=colorlist('getlist','includenone',includenone);      
        if ~isempty(el.variable)
            str=getSubFieldValue(s,el.variable);
            ii=strmatch(lower(str),lower(stringList),'exact');
        else
            ii=1;
        end
        
        set(el.handle,'Value',ii);
        set(el.handle,'String',stringList);

    case{'selectmarker'}

        stringList={'o','x','d','none'};      
        if ~isempty(el.variable)
            str=getSubFieldValue(s,el.variable);
            ii=strmatch(lower(str),lower(stringList),'exact');
        else
            ii=1;
        end
        
        set(el.handle,'Value',ii);
        set(el.handle,'String',stringList);

    case{'selectlinestyle'}

        stringList={'-','--','.-','.'};      
        if ~isempty(el.variable)
            str=getSubFieldValue(s,el.variable);
            ii=strmatch(lower(str),lower(stringList),'exact');
        else
            ii=1;
        end
        
        set(el.handle,'Value',ii);
        set(el.handle,'String',stringList);
        
    case{'text'}
        if isfield(el,'variable')
            if ~isempty(el.variable)
                val=getSubFieldValue(s,el.variable);

                if ~isempty(el.type)
                    tp=lower(el.type);
                else
                    tp=lower(el.variable.type);
                end

                switch tp
                    case{'string'}
                    otherwise
                        val=num2str(val);
                end
                str=[el.prefix ' ' val ' ' el.suffix];
                set(el.handle,'String',str);
                
                pos=el.position;
                ext=get(el.handle,'Extent');
                pos(3)=ext(3);
                pos(4)=15;
                set(el.handle,'Position',pos);
            end
        end
        
        %% Custom elements
        
    case{'pushselectfile'}
        if el.showFileName
           val=getSubFieldValue(s,el.variable);
           set(el.textHandle,'enable','on','String',['File : ' val]);
           pos=get(el.textHandle,'position');
           ext=get(el.textHandle,'Extent');
           pos(3)=ext(3);
           pos(4)=15;
           set(el.textHandle,'Position',pos);
        end
                      
    case{'pushsavefile'}
        if el.showFileName
            val=getSubFieldValue(s,el.variable);
            set(el.textHandle,'enable','on','String',['File : ' val]);
            pos=get(el.textHandle,'position');
            ext=get(el.textHandle,'Extent');
            pos(3)=ext(3);
            pos(4)=15;
            set(el.textHandle,'Position',pos);
        end

    case{'table'}
        % Determine number of rows in table
        for j=1:length(el.columns)
            val=getSubFieldValue(s,el.columns(j).variable);
            switch lower(el.columns(j).style)
                case{'editreal','checkbox','edittime'}
                    % Reals must be a vector
                    sz=size(val);
                    nrrows=max(sz);
                case{'editstring','text','popupmenu'}
                    % Strings must be cell array
                    nrrows=length(val);
            end
        end
        
        % Determine string list in case of popup menu
        ipopup=0;
        for j=1:length(el.columns)
            popupText{j}={' '};
            switch lower(el.columns(j).style)
                case{'popupmenu'}
                    ipopup=1;
                    popupText{j}=getSubFieldValue(s,el.columns(j).list.text.variable);
            end
        end
        
        % Now set the data
        for j=1:length(el.columns)
            val=getSubFieldValue(s,el.columns(j).variable);
            for k=1:nrrows
                switch lower(el.columns(j).style)
                    case{'editreal'}
                        data{k,j}=val(k);
                    case{'edittime'}
                        data{k,j}=val(k);
                    case{'editstring'}
                        data{k,j}=val{k};
                    case{'popupmenu'}
                        data{k,j}=val(k);
%                        data{k,j}=val{k};
                    case{'checkbox'}
                        data{k,j}=val(k);
                    case{'pushbutton'}
                        data{k,j}=[];
                    case{'text'}
                        data{k,j}=val{k};
                end
            end
        end
        if ipopup
            table(el.handle,'refresh','popuptext',popupText);
        end
        table(el.handle,'setdata',data);
end

if dependencyUpdate
    switch lower(el.style)
        case{'tabpanel'}
            for j=1:length(el.tabs)
                updateUIDependency(el.tabs(j),0,getFcn);
            end
        otherwise
            updateUIDependency(el,0,getFcn);
    end
end
