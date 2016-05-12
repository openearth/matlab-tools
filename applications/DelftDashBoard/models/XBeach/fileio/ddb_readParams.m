function handles=ddb_readParams(handles,filename,ad)

xbs = xb_read_input(filename);

for is = 1:length(xbs.data)
    if isnumeric(xbs.data(is).value)
        ddb_xbmi.(xbs.data(is).name) = xbs.data(is).value;
    elseif ischar(xbs.data(is).value)
        ddb_xbmi.(xbs.data(is).name) = xbs.data(is).value;
    elseif isstruct(xbs.data(is).value)
        [pathstr,fname,ext] = fileparts(xbs.data(is).value.file);
        ddb_xbmi.(xbs.data(is).name) = [fname ext]; % get name of file 
    end
end

% Replace default values with model input
fieldNames = fieldnames(ddb_xbmi);
for i = 1:size(fieldNames,1)
    handles.model.xbeach.domain(ad).(fieldNames{i}) = ddb_xbmi.(fieldNames{i});
end

% Save variables
namesxb = [];
for ii = 1:length(xbs.data)
    namesxb{ii} = xbs.data(ii).name;
end

varsneeded = {'meanvars', 'globalvars'};
for ii = 1:length(varsneeded)
    nametesting = varsneeded{ii};
    ids =find((strcmp(namesxb, nametesting))>0);
    handles.model.xbeach.domain(ad).(varsneeded{ii}) = xbs.data(ids).value;
end
handles.model.xbeach.domain(ad).pwd = pwd;
disp('Params red successfully')
