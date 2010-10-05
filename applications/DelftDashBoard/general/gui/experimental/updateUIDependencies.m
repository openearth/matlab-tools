function updateUIDependencies(elements,getFcn)

for i=1:length(elements)
    updateUIDependency(elements(i),0,getFcn);
end
