function handles=ddb_readParams(handles,filename,id)

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
    handles.Model(handles.activeModel.nr).Input(handles.activeDomain).(fieldNames{i}) = ddb_xbmi.(fieldNames{i});
end
