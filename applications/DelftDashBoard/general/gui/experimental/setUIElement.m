function setUIElement(th,varargin)

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
                val=num2str(val);
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
                if el.value==val
                    set(el.handle,'Value',1);
                else
                    set(el.handle,'Value',0);
                end
        end

    case{'listbox','popupmenu'}
        
        if isfield(el.list.text,'variable')
            stringList=getSubFieldValue(s,el.list.text.variable);
        else
            stringList=el.list.text;
        end
        
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
        set(el.handle,'String',stringList);
        set(el.handle,'Value',ii);
                
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
                    str=getSubFieldValue(s,el.columns(j).list.text.variable);
                    for k=1:length(str)
                        popupText{j}=str;
                    end
            end
        end
%         if ipopup
%             table(el.handle,'refresh','popuptext',popupText);
%         end
        
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
        table(el.handle,'setdata',data,'popuptext',popupText);
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
