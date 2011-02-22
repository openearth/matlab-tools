function updateUIDependencies(elements,getFcn)

for i=1:length(elements)
    switch lower(elements(i).style)
        case{'tabpanel'}
            for j=1:length(elements(i).tabs)
                updateUIDependency(elements(i).tabs(j),0,getFcn);
            end
        otherwise
            updateUIDependency(elements(i),0,getFcn);
    end
end
