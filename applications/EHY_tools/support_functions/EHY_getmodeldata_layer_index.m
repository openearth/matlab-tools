function OPT=EHY_getmodeldata_layer_index(OPT,no_layers)

if isempty(OPT.layer) || all(OPT.layer==0)
    OPT.layer=1:no_layers;
elseif no_layers==1 && length(OPT.layer)>1
    warning('User selected multiple layers, but there is only 1 layer available. Setting OPT.layer=1; ')
    disp('User selected multiple layers, but there is only 1 layer available. Setting OPT.layer=1; ')
    OPT.layer=1;
elseif any(OPT.layer>no_layers)
    warning(['User asked for layer ' num2str(max(OPT.layer)) ', but there are only ' num2str(no_layers) ' layers available. Setting OPT.layer to ''all''']);
    warning(['OPT.layer is set to [' num2str(1:no_layers) ']'])
    disp(['User asked for layer ' num2str(max(OPT.layer)) ', but there are only ' num2str(no_layers) ' layers available. Setting OPT.layer to ''all''']);
    disp(['OPT.layer is set to [' num2str(1:no_layers) ']'])
    OPT.layer=1:no_layers;
end

if strcmp(OPT.varName,'Zint') || strcmp(OPT.varName,'zcoordinate_w')
    % return all data > no_layers+1
    OPT.layer=1:no_layers+1;
end

end