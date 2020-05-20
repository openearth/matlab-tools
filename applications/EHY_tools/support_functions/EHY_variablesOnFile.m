function [variables,varAndDescr] = EHY_variablesOnFile(fname,modelType)

% if not provided, get additional information
if ~exist('fname','var')
    disp('Open a model output file')
    [filename, pathname] = uigetfile('*.*','Open a model output file');
    if isnumeric(filename); disp('EHY_variablesOnFile stopped by user.'); return; end
    fname = [pathname filename];
end

if ~exist('modelType','var')
    modelType = EHY_getModelType(fname);
end

%% defaults
defaults = {'waterlevel','';
    'waterdepth','';
    'uv','x,y-velocity';
    'salinity','';
    'temperature','';
    'Zcen_cen','z-coordinates (pos. up) of cell centers';
    'Zcen_int','z-coordinates (pos. up) of cell interfaces'};

%%
switch modelType
    case {'dfm','nc'}
        infonc    = ncinfo(fname);
        variables = {infonc.Variables.Name}';
        description(1:numel(variables),1) = {''};
        for iV = 1:length(variables)
            % add attribute info - long_name
            if ~isempty(infonc.Variables(iV).Attributes)
                AttrInd =  strmatch('long_name',{infonc.Variables(iV).Attributes.Name},'exact');
                if ~isempty(AttrInd)
                    description{iV,1} = infonc.Variables(iV).Attributes(AttrInd).Value;
                end
            end
        end
        
    case 'd3d'
        d3d = vs_use(fname,'quiet');
        
        variables = [defaults(1:end-2,1); {d3d.ElmDef.Name}'];
        description = [defaults(1:end-2,2); {d3d.ElmDef.Description}'];
        
    case 'delwaq'
        dw = delwaq('open',fname);
        variables = dw.SubsName;
        
        % additional info
        FI = qpfopen(fname);
        [~,DataProps] = qp_getdata(FI);
        variables2 = {DataProps.ShortName}';
        [lia,locb] = ismember(variables2,variables);
        dmy1 = cellstr(repmat(' [',numel(DataProps),1));
        dmy2 = cellstr(repmat( ']',numel(DataProps),1));
        description2 = strcat({DataProps.Name}', dmy1, {DataProps.Units}', dmy2);
        
        description(1:length(variables),1) = {''};
        description(locb(locb~=0)) = description2(lia);
        
    case 'simona'
        variables   = defaults(1:5,1);
        description = defaults(1:5,2);
        
    case {'sobek3','sobek3_new','implic'}
        variables   = defaults(1,1);
        description = defaults(1,2);
        
end

%%
varAndDescr = strcat(variables,' [',description,']');
varAndDescr = strtrim(strrep(varAndDescr,'[]',''));
