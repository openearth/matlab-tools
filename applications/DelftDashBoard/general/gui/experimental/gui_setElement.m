function gui_setElement(h)
% Sets correct value for GUI element

% Check whether input is handle or tag
if ischar(h)
    h=findobj(gcf,'Tag',h);
end

if isempty(h)
    warning(['Error setting element ' h]);
    return
end

el=getappdata(h,'element');

switch lower(el.style)
    
    %% Standard elements
    
    case{'edit'}

        val=gui_getValue(el,el.variable);
        tp=lower(el.type);

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
                val=gui_getValue(el,el.text.variable);
                % Text
                set(el.texthandle,'String',val);
                setTextPosition(el.texthandle,el.position,el.textposition);
            end
        end
        
    case{'checkbox'}

        val=gui_getValue(el,el.variable);
        set(el.handle,'Value',val);

    case{'togglebutton'}

        val=gui_getValue(el,el.variable);
        set(el.handle,'Value',val);

    case{'radiobutton'}

        val=gui_getValue(el,el.variable);        
        tp=lower(el.type);

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
            val=gui_getValue(el,el.text.variable);
            % Text
            set(el.handle,'String',val);
        end

    case{'listbox','popupmenu'}

        % Texts
        if isfield(el.list.texts,'variable')
            stringlist=gui_getValue(el,el.list.texts.variable);
        else
            for jj=1:length(el.list.texts)
                stringlist{jj}=el.list.texts(jj).text;
            end
        end
        
        ii=1;
        if isempty(stringlist)
            ii=1;
        elseif isempty(stringlist{1})
            ii=1;
        else           
            if ~isempty(el.type)
                tp=lower(el.type);
            else
                tp=lower(el.variable.type);
            end
            switch tp
                case{'string'}                    

                    % Values
%                    if ~isempty(el.list.values)
                    if isfield(el.list,'values')
                        % Values prescribed in xml file
                        if isfield(el.list.values,'variable')
                            values=gui_getValue(el,el.list.values.variable);
                        else
                            for jj=1:length(el.list.values)
                                values{jj}=el.list.values(jj).value;
                            end
                        end
                    else
                        % Values are the same as the string list
                        values=stringlist;
                    end
                    
                    if isfield(el,'variable')
                        if ~isempty(el.variable)
                            str=gui_getValue(el,el.variable);
                            ii=strmatch(lower(str),lower(values),'exact');
                        end
                    end
                    
                otherwise
                    
                    if ~isempty(el.multivariable)
                        % Not sure anymore what this multivariable is
                        % supposed to do ...
                        ii=gui_getValue(el,el.multivariable);
                    else                        
                        % Values
%                        if ~isempty(el.list.values)
                        if isfield(el.list,'values')
                            % Values prescribed in xml file
                            if isfield(el.list.values,'variable')
                                values=gui_getValue(el,el.list.values.variable);
                            else
                                for jj=1:length(el.list.values)
                                    values(jj)=str2double(el.list.values(jj).value);
                                end
                            end
                        else
                            % Values 1 to length of stringlist
                            values=1:length(stringlist);
                        end
                        
                        if isfield(el.list,'values')
                            val=gui_getValue(el,el.variable);
                            ii=find(values==val,1,'first');
                        else
                            ii=gui_getValue(el,el.variable);
                        end
                    end
            end
        end
        set(el.handle,'Value',ii);
        set(el.handle,'String',stringlist);
                
    case{'text'}
        
        if isfield(el,'variable')

            if ~isempty(el.variable)
            
                val=gui_getValue(el,el.variable);

                tp=lower(el.type);

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
        if el.showfilename
           val=gui_getValue(el,el.variable);
           set(el.texthandle,'enable','on','String',['File : ' val]);
           pos=get(el.texthandle,'position');
           ext=get(el.texthandle,'Extent');
           pos(3)=ext(3);
           pos(4)=15;
           set(el.texthandle,'Position',pos);
        end
                      
    case{'pushsavefile'}
        if el.showfilename
            val=gui_getValue(el,el.variable);
            set(el.texthandle,'enable','on','String',['File : ' val]);
            pos=get(el.texthandle,'position');
            ext=get(el.texthandle,'Extent');
            pos(3)=ext(3);
            pos(4)=15;
            set(el.texthandle,'Position',pos);
        end

    case{'table'}
        % Determine number of rows in table
        for j=1:length(el.columns)
            val=gui_getValue(el,el.columns(j).column.variable);
            switch lower(el.columns(j).column.style)
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
            switch lower(el.columns(j).column.style)
                case{'popupmenu'}
                    ipopup=1;
                    popupText{j}=gui_getValue(el,el.columns(j).column.list.texts.variable);
            end
        end
        
        % Now set the data
        for j=1:length(el.columns)
            val=gui_getValue(el,el.columns(j).column.variable);
            for k=1:nrrows
                switch lower(el.columns(j).column.style)
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

% And now update the dependency of this element
gui_updateDependency(h);

