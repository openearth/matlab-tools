function fouInfo = EHY_fouInfo(modelFile,grpName)

%% Only fourier variables
if ~contains(grpName,'fourier') fouInfo = []; return; end

%% Retrieves the attributes for variable grpName from modelFile
infonc   = ncinfo(modelFile);
varNames = {infonc.Variables.Name};
strcmp(varNames,grpName);
index   = strcmp(varNames,grpName);
fourier = infonc.Variables(index);

%% Attributes
Names   = {fourier.Attributes.Name};
Value   = {fourier.Attributes.Value};

%% Fill fouInfo
if contains(grpName,'mean') fouInfo.type = 'mean'; end
if contains(grpName,'max')  fouInfo.type = 'max' ; end
if contains(grpName,'min')  fouInfo.type = 'min' ; end

%  From the attributes
index                   = contains(Names,'long_name');
fouInfo.name            = Value{index};
index                   = contains(Names,'units');
fouInfo.unit            = Value{index};
index                   = contains(Names,'reference_date_in_yyyymmdd');
itDate                  = datenum(num2str(Value{index}),'yyyymmdd');
index                   = contains(Names,'starttime');
fouInfo.fouStart        = Value{index};
fouInfo.fouStartDatenum = fouInfo.fouStart/1440. + itDate; 
index                   = contains(Names,'stoptime');
fouInfo.fouStop         = Value{index};
fouInfo.fouStopDatenum  = fouInfo.fouStop/1440. + itDate; 




