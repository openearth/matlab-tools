function [variables,description] = EHY_variablesOnFile(fname)

modelType = EHY_getModelType(fname);
[typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(fname);

error('function is not ready to be used')
%%
% initiate
variables   = {};
description = {};

switch modelType
    case 'dfm'
        infonc           = ncinfo(outputfile);
        variablesOnFile  = {infonc.Variables.Name};
        variablesOnFileInclAttr = variablesOnFile;
        for iV=1:length(variablesOnFile)
            % add attribute info - long_name
            indAttr =  strmatch('long_name',{infonc.Variables(iV).Attributes.Name},'exact');
            if ~isempty(indAttr)
                variablesOnFileInclAttr{iV} = strcat(variablesOnFile{iV},' [', infonc.Variables(iV).Attributes(indAttr).Value,']');
            end
        end
    case {'d3d','delwaq'}
        FI = qpfopen(fname);
        [~,DataProps] = qp_getdata(FI);
        variables = DataProps.Val1;
        
        dw = delwaq('open',outputfile);
        variablesOnFile = dw.SubsName;
        variablesOnFileInclAttr = variablesOnFile;
end
