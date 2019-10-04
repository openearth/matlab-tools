function [variables,description] = EHY_variablesOnFile(fname)

modelType = EHY_getModelType(fname);
[typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(fname);


%%
variables   = {};
description = {};

switch modelType
    case 'dfm'
        
    case {'d3d','delwaq'}
        FI = qpfopen(fname);
        [~,DataProps] = qp_getdata(FI);
        variables = DataProps.Val1;
end
