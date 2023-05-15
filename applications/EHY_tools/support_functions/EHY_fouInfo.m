function fouInfo = EHY_fouInfo(modelFile,grpName)

%% Only fourier variables
if ~contains(grpName,'fourier') fouInfo = []; return; end

%% Retrieves the attributes for variable grpName from modelFile
infonc   = ncinfo(modelFile);
varNames = {infonc.Variables.Name};
index   = strcmp(varNames,grpName);
fourier = infonc.Variables(index);

%% Attributes
Names   = {fourier.Attributes.Name};
Value   = {fourier.Attributes.Value};

%% Fill fouInfo
if contains(grpName,'_avg')  fouInfo.type = 'mean'; end
if contains(grpName,'_mean') fouInfo.type = 'mean'; end
if contains(grpName,'_max')  fouInfo.type = 'max' ; end
if contains(grpName,'_min')  fouInfo.type = 'min' ; end

%  From the attributes
index                   = contains(Names,'long_name');
fouInfo.name            = Value{index};
index                   = contains(Names,'units');
fouInfo.unit            = Value{index};
index                   = contains(lower(Names),'reference_date_in_yyyymmdd');
itDate                  = datenum(num2str(Value{index}),'yyyymmdd');
index                   = contains(Names,'starttime');
if ~any(index)
    index                   = contains(Names,'Starttime_fourier_analysis_in_minutes_since_reference_date');
end
fouInfo.fouStart        = Value{index};
fouInfo.fouStartDatenum = fouInfo.fouStart/1440. + itDate; 
index                   = contains(Names,'stoptime');
if ~any(index)
    index                   = contains(Names,'Stoptime_fourier_analysis_in_minutes_since_reference_date');
end
fouInfo.fouStop         = Value{index};
fouInfo.fouStopDatenum  = fouInfo.fouStop/1440. + itDate; 
