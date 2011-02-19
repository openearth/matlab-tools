function setUIElements(elements)

if ischar(elements)
    h=findobj(gcf,'Tag',elements);
    elements=getappdata(h,'elements');
end

for i=1:length(elements)
    
    if isfield(elements(i),'handle')
        if ~isempty(elements(i).handle)
            try
                setUIElement(elements(i).handle);
            catch
                disp(['Something went wrong when setting UI element ' elements(i).tag]);
            end
            if strcmpi(elements(i).style,'tabpanel')
                for j=1:length(elements(i).tabs)
                    elements2=elements(i).tabs(j).elements;
                    setUIElements(elements2);
                end
            end
            
        else
            disp(['Warning : no handle for ' elements(i).tag ' !']);
        end
    else
        disp(['Warning : no handle for ' elements(i).tag ' !']);
    end
    
end
