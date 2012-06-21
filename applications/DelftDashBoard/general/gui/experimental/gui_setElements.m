function gui_setElements(elements)

if ischar(elements)
    h=findobj(gcf,'Tag',elements);
    if isempty(h)
        return
    end
    elements=getappdata(h,'elements');
end

for i=1:length(elements)
    
    if isfield(elements(i).element,'handle')
        if ~isempty(elements(i).element.handle)
            try
                gui_setElement(elements(i).element.handle);
            catch
                disp(['Something went wrong when setting UI element ' elements(i).element.tag]);
            end
        else
            disp(['Warning : no handle for ' elements(i).element.tag ' !']);
        end
    else
        disp(['Warning : no handle for ' elements(i).element.tag ' !']);
    end
    
end
