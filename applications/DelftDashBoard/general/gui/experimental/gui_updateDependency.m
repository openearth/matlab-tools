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
        
        ok=gui_checkDependency(dependency,element);        
        
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

%%

