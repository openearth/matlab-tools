function gui_updateDependency(h)
% Updates element settings based on dependencies

% h can be the handle of element of handle of a tab
element=getappdata(h,'element');

if isempty(element)
    % Should be a tab, find dependencies
    p=get(h,'Parent');
    usd=get(p,'userdata');
    iac= usd.largeTabHandles==h;
    el=getappdata(p);
    element=el.element.tab(iac).tab;
    tabname=usd.tabNames{iac};
end

if isfield(element,'dependency')

    for iac=1:length(element.dependency);
        
        dependency=element.dependency(iac).dependency;
        
        if ~isempty(dependency.checkfor)
            switch lower(dependency.checkfor)
                case{'any'}
                    ok=0;
                    for k=1:length(dependency.check)
                        val=gui_getValue(element,dependency.check(k).check.variable);
                        if ischar(val)
                            % String
                            switch dependency.check(k).check.operator
                                case{'eq'}
                                    if strcmpi(val,dependency.check(k).check.value)
                                        ok=1;
                                    end
                                case{'ne'}
                                    if ~strcmpi(val,dependency.check(k).check.value)
                                        ok=1;
                                    end
                            end
                        else
                            % Numeric
                            v=str2double(dependency.check(k).check.value);
                            switch dependency.check(k).check.operator
                                case{'eq'}
                                    if isnan(v)
                                        if isnan(val)
                                            ok=1;
                                        end
                                    else
                                        if val==v
                                            ok=1;
                                        end
                                    end
                                case{'ne'}
                                    if isnan(v)
                                        if ~isnan(val)
                                            ok=1;
                                        end
                                    else
                                        if val~=v
                                            ok=1;
                                        end
                                    end
                                case{'lt'}
                                    if val<v
                                        ok=1;
                                    end
                                case{'gt'}
                                    if val>v
                                        ok=1;
                                    end
                                case{'le'}
                                    if val<=v
                                        ok=1;
                                    end
                                case{'ge'}
                                    if val>=v
                                        ok=1;
                                    end
                            end
                        end
                    end
                    
                case{'all'}
                    ok=1;
                    for k=1:length(dependency.check)
                        val=gui_getValue(element,dependency.check(k).check.variable);
                        if isempty(val)
                            if strcmpi(dependency.check(k).check.value,'isempty')
                                if strcmpi(dependency.check(k).check.operator,'eq')
                                    ok=1;
                                else
                                    ok=0;
                                end
                            end
                        elseif ischar(val)
                            % String
                            switch dependency.check(k).check.operator
                                case{'eq'}
                                    if ~strcmpi(val,dependency.check(k).check.value)
                                        ok=0;
                                    end
                                case{'ne'}
                                  if isempty(val)
                                    if strcmpi(dependency.check(k).check.value,'isempty')
                                      ok=0;
                                    end
                                  else
                                    if strcmpi(val,dependency.check(k).check.value)
                                      ok=0;
                                    end
                                  end
                            end
                        else
                            % Numeric
                            v=str2double(dependency.check(k).check.value);
                            switch dependency.check(k).check.operator
                                case{'eq'}
                                    if isnan(v)
                                        if ~isnan(val)
                                            ok=0;
                                        end
                                    else
                                        if val~=v
                                            ok=0;
                                        end
                                    end
                                case{'ne'}
                                    if isnan(v)
                                        if isnan(val)
                                            ok=0;
                                        end
                                    else
                                        if val==v
                                            ok=0;
                                        end
                                    end
                                case{'lt'}
                                    if val>=v
                                        ok=0;
                                    end
                                case{'gt'}
                                    if val<=v
                                        ok=0;
                                    end
                                case{'le'}
                                    if val>v
                                        ok=0;
                                    end
                                case{'ge'}
                                    if val<v
                                        ok=0;
                                    end
                            end
                        end
                    end
                    
                case{'none'}
                    ok=1;
                    for k=1:length(dependency.check)
                        
                        val=gui_getValue(element,dependency.check(k).check.variable);
                        if ischar(val)
                            % String
                            switch dependency.check(k).check.operator
                                case{'eq'}
                                    if strcmpi(val,dependency.check(k).check.value)
                                        ok=0;
                                    end
                                case{'ne'}
                                    if ~strcmpi(val,dependency.check(k).check.value)
                                        ok=0;
                                    end
                            end
                        else
                            % Numeric
                            v=str2double(dependency.check(k).check.value);
                            switch dependency.check(k).check.operator
                                case{'eq'}
                                    if val==v
                                        ok=0;
                                    end
                                case{'ne'}
                                    if val~=v
                                        ok=0;
                                    end
                                case{'lt'}
                                    if val<v
                                        ok=0;
                                    end
                                case{'gt'}
                                    if val>v
                                        ok=0;
                                    end
                                case{'le'}
                                    if val<=v
                                        ok=0;
                                    end
                                case{'ge'}
                                    if val>=v
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
                    switch element.style
                        case{'table'}
                            table(element.handle,'enable');
                        case{'tab'}
                            tabpanel('enabletab','handle',p,'tabname',tabname);
                        otherwise
                            enableElement(element);
                    end
                else
                    switch element.style
                        case{'table'}
                            table(element.handle,'disable');
                        case{'tab'}
                            tabpanel('disabletab','handle',p,'tabname',tabname);
                        otherwise
                            disableElement(element);
                    end
                end
            case{'on'}
                if ok
                    turnOn(element);
                else
                    turnOff(element);
                end
            case{'update'}
                setUIElement(element.handle,'dependencyupdate',0);
            case{'visible'}
                if ok
                    setVisible(element);
                else
                    setInvisible(element);
                end
                
        end
        
    end
end

%%
function enableElement(element)
set(element.handle,'Enable','on');
if ~isempty(element.texthandle)
    set(element.texthandle,'Enable','on');
end

%%
function disableElement(element)
set(element.handle,'Enable','off');
if ~isempty(element.texthandle)
    set(element.texthandle,'Enable','off');
end

%%
function setVisible(element)
set(element.handle,'Visible','on');
if ~isempty(element.texthandle)
    set(element.texthandle,'Visible','on');
end

%%
function setInvisible(element)
set(element.handle,'Visible','off');
if ~isempty(element.texthandle)
    set(element.texthandle,'Visible','off');
end

%%
function turnOn(element)
set(element.handle,'Value',1);

%%
function turnOff(element)
set(element.handle,'Value',0);

