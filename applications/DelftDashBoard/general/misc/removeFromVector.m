function v1=removeFromVector(v0,iac)
k=0;
v1=[];
iind=1:length(v0);
iind=iind(iind~=iac);
if ~isempty(iind)
    v1=v0(iind);
end
