function updateUIDependency(element,idep,getFcn)

s=feval(getFcn);

if idep==0
    ii1=1;
    ii2=length(element.dependencies);
else
    ii1=idep;
    ii2=idep;
end

for iac=ii1:ii2
    
    dependency=element.dependencies(iac);
    
    if ~isempty(dependency.checkFor)
        switch lower(dependency.checkFor)
            case{'any'}
                ok=0;
                for k=1:length(dependency.checks)
                    
                    val=getSubFieldValue(s,dependency.checks(k).variable);
                    if ischar(val)
                        if strcmpi(val,dependency.checks(k).value)
                            ok=1;
                        end
                    else
                        switch dependency.checks(k).operator
                            case{'eq'}
                                if val==dependency.checks(k).value
                                    ok=1;
                                end
                            case{'lt'}
                                if val<dependency.checks(k).value
                                    ok=1;
                                end
                            case{'gt'}
                                if val>dependency.checks(k).value
                                    ok=1;
                                end
                            case{'le'}
                                if val<=dependency.checks(k).value
                                    ok=1;
                                end
                            case{'ge'}
                                if val>=dependency.checks(k).value
                                    ok=1;
                                end
                        end
                    end
                end
                
            case{'all'}
                ok=1;
                for k=1:length(dependency.checks)
                    val=getSubFieldValue(s,dependency.checks(k).variable);
                    if ischar(val)
                        if ~strcmpi(val,dependency.checks(k).value)
                            ok=0;
                        end
                    else
                        switch dependency.checks(k).operator
                            case{'eq'}
                                if val~=dependency.checks(k).value
                                    ok=0;
                                end
                            case{'lt'}
                                if val>=dependency.checks(k).value
                                    ok=0;
                                end
                            case{'gt'}
                                if val<=dependency.checks(k).value
                                    ok=0;
                                end
                            case{'le'}
                                if val>dependency.checks(k).value
                                    ok=0;
                                end
                            case{'ge'}
                                if val<dependency.checks(k).value
                                    ok=0;
                                end
                        end
                    end
                end
                
            case{'none'}
                ok=1;
                for k=1:length(dependency.checks)
                    
                    val=getSubFieldValue(s,dependency.checks(k).variable);
                    if ischar(val)
                        if strcmpi(val,dependency.checks(k).value)
                            ok=0;
                        end
                    else
                        switch dependency.checks(k).operator
                            case{'eq'}
                                if val==dependency.checks(k).value
                                    ok=0;
                                end
                            case{'lt'}
                                if val<dependency.checks(k).value
                                    ok=0;
                                end
                            case{'gt'}
                                if val>dependency.checks(k).value
                                    ok=0;
                                end
                            case{'le'}
                                if val<=dependency.checks(k).value
                                    ok=0;
                                end
                            case{'ge'}
                                if val>=dependency.checks(k).value
                                    ok=0;
                                end
                        end
                    end
                end
        end
    end
        
    switch lower(dependency.action)
        case{'enable'}
            if ok
                enableElement(element);
            else
                disableElement(element);
            end
        case{'on'}
            if ok
                turnOn(element);
            else
                turnOff(element);
            end
        case{'update'}
            setUIElement(element.handle);
    end
        
end

%%
function enableElement(element)
set(element.handle,'Enable','on');
if ~isempty(element.textHandle)
    set(element.textHandle,'Enable','on');
end

%%
function disableElement(element)
set(element.handle,'Enable','off');
if ~isempty(element.textHandle)
    set(element.textHandle,'Enable','off');
end

%%
function turnOn(element)
set(element.handle,'Value',1);

%%
function turnOff(element)
set(element.handle,'Value',0);

%%
function update(element)
setUIElement(element.handle);
