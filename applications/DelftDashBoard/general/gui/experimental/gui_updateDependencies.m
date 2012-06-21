function gui_updateDependencies(elements,getFcn)

for i=1:length(elements)
    switch lower(elements(i).element.style)
        case{'tabpanel'}
            for j=1:length(elements(i).element.tabs)
                gui_updateDependency(elements(i).element.tabs(j).tab,0,getFcn);
            end
        otherwise
            gui_updateDependency(elements(i).element,0,getFcn);
    end
end
