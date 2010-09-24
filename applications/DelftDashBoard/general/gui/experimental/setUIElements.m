function setUIElements(elements,getFcn,subFields,subIndices)

s=feval(getFcn);

if isempty(subIndices)
    subIndices=zeros(length(subFields))+1;
end

for i=1:length(elements)
    
    el=elements(i);
    switch lower(elements(i).style)
        
        %% Standard elements
        
        case{'edit'}
            
            % Edit box
            val=getSubFieldValue(s,subFields,subIndices,el.varName);
            switch el.varType
                case{'string'}
                otherwise
                    val=num2str(val);
            end
            set(el.handle,'String',val);
            
        case{'checkbox'}
            
            % Check box
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
            end
            
        %% Custom elements
        
        case{'pushselectfile'}
            
            val=getSubFieldValue(s,subFields,subIndices,el.varName);
            set(el.textHandle,'enable','on','String',['File : ' val]);
                        
    end
    
end
