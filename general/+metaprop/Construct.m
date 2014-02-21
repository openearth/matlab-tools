function metaprops = Construct(metaclass,metaPropertyBlock)
validateattributes(metaclass        ,{'meta.class'},{'scalar'});
validateattributes(metaPropertyBlock,{'cell'}      ,{'ncols',3});
assert(all(cellfun(@(x) isa(x,'char')            ,metaPropertyBlock(:,1))));
assert(all(cellfun(@(x) isa(x,'function_handle') ,metaPropertyBlock(:,2))));
assert(all(cellfun(@(x) isa(x,'cell')            ,metaPropertyBlock(:,3))));

PropertyList =  metaclass.PropertyList;

for ii = 1:size(metaPropertyBlock,1)
    name      = metaPropertyBlock{ii,1};
    fcn       = metaPropertyBlock{ii,2};
    % transpose for when the cell is a nx2 cell, so keyword/value pairs
    % stay together
    extraArgs = metaPropertyBlock{ii,3}';
    
    n = strcmp(name,{PropertyList.Name});
    assert(sum(n)==1)
    
    metaprops.(name) = fcn(PropertyList(n),extraArgs{:});
end
