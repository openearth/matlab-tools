function setUIElements(elements)

for i=1:length(elements)
    
    if ~isempty(elements(i).handle)
        setUIElement(elements(i).handle);
    else
        disp(['Warning : no handle for ' elements(i).tag ' !']);
    end
    
end
