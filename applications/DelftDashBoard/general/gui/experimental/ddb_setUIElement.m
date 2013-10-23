function setUIElement(th)

% Check whether input is handle or tag
if ischar(th)
    h=findobj(gcf,'Tag',th);
else
    h=th;
end

p=get(h,'Parent');

getFcn=getappdata(p,'getFcn');
elements=getappdata(p,'elements');
subFields=getappdata(p,'subFields');
subIndices=getappdata(p,'subIndices');

tags={elements.tag};

i=strmatch(tag,tags,'exact');

el=elements(i);

s=feval(getFcn);

switch lower(elements(i).style)
    
    %% Standard elements
    
    case{'edit'}
        val=getSubFieldValue(s,subFields,subIndices,el.varName);
        switch el.varType
            case{'string'}
            otherwise
                val=num2str(val);
        end
        set(el.handle,'String',val);
        
    case{'checkbox'}
        val=getSubFieldValue(s,subFields,subIndices,el.varName);
        set(el.handle,'Value',val);
        
    case{'listbox'}
        
    case{'text'}
        if ~isempty(el.varName)
            val=getSubFieldValue(s,subFields,subIndices,el.varName);
            switch el.varType
                case{'string'}
                otherwise
                    val=num2str(val);
            end
            str=[el.prefix ' ' val ' ' el.suffix];
            set(el.handle,'String',str);
            
            pos=el.position;
            pos=pos*1.2;
            
            ext=get(el.handle,'Extent');
            pos(3)=ext(3);
            pos(4)=15;
            set(elements(i).handle,'Position',pos);
            
        end
        
        %% Custom elements
        
    case{'pushselectfile'}
        val=getSubFieldValue(s,subFields,subIndices,el.varName);
        set(el.textHandle,'enable','on','String',['File : ' val]);
        
    case{'popupmenu'}
        val=getSubFieldValue(s,subFields,subIndices,el.varName);
        set(el.handle,'Value',val);
        
    case{'table'}
        % Determine number of rows in table
        for j=1:length(el.columns)
            val=getSubFieldValue(s,subFields,subIndices,el.columns(j).varName);
            switch lower(el.columns(j).style)
                case{'editreal','checkbox'}
                    % Reals must be a vector
                    sz=size(val);
                    nrrows=max(sz);
                case{'editstring','text','popupmenu'}
                    % Strings must be cell array
                    nrrows=length(val);
            end
        end
        
        % Now set the data
        for j=1:length(el.columns)
            val=getSubFieldValue(s,subFields,subIndices,el.columns(j).varName);
            for k=1:nrrows
                switch lower(el.columns(j).style)
                    case{'editreal'}
                        data{k,j}=val(k);
                    case{'editstring'}
                        data{k,j}=val{k};
                    case{'popupmenu'}
                        data{k,j}=val{k};
                    case{'checkbox'}
                        data{k,j}=val(k);
                    case{'pushbutton'}
                        data{k,j}=[];
                    case{'text'}
                        data{k,j}=val{k};
                end
            end
        end
        table(el.handle,'setdata',data);        
end

