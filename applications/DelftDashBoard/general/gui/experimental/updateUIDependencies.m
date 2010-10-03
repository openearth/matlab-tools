function updateUIDependencies(elements,iac,getFcn)

s=feval(getFcn);

% Loop around all elements that are dependent on active element

if iac==0
    % Loop through all elements
    ii1=1;
    ii2=length(elements);
else
    ii1=iac;
    ii2=iac;
end

for iac=ii1:ii2
    
    for i=1:length(elements(iac).dependees)
        
        jac=elements(iac).dependees(i).dependeeNr;
        idep=elements(iac).dependees(i).dependencyNr;
        dependency=elements(jac).dependencies(idep);
        
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
        
        switch lower(dependency.action)
            case{'enable'}
                if ok
                    enableElement(elements(jac));
                else
                    disableElement(elements(jac));
                end
            case{'on'}
                if ok
                    turnOn(elements(jac));
                else
                    turnOff(elements(jac));
                end
        end
        
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
