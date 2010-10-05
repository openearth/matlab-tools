function updateUIDependees(elements,iac,getFcn)
    
for i=1:length(elements(iac).dependees)
    jac=elements(iac).dependees(i).dependeeNr;
    idep=elements(iac).dependees(i).dependencyNr;
    updateUIDependency(elements(jac),idep,getFcn);
end
