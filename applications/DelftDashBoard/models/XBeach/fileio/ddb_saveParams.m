function ddb_saveParams(handles,ndomain)

%% This function saves the structure from DDB 
% Makes use of xb_read_input and xb_save_input
handles = getHandles;

%% Get XBeach structure
xbeach_ddb = handles.model.xbeach.domain(ndomain);
xbeach_writing = xs_set('');

%% Check which variables are different than default?
xbeach_empty = ddb_initializeXBeachInput([],1,'empty');
xbeach_empty = xbeach_empty.model.xbeach.domain;
names = fieldnames(xbeach_empty);

count = 1; varchanged = [];
varchanged{1} = 'tst';
for ii = 1:length(names);
    nametesting = names{ii};
    try
        if isnumeric(xbeach_empty.(nametesting))
            if xbeach_ddb.(nametesting) == xbeach_empty.(nametesting);
            else
            varchanged{count} = nametesting;
            count = count +1;
            end
        else
            if strcmp(xbeach_ddb.(nametesting), xbeach_empty.(nametesting))
            else
                varchanged{count} = nametesting;
                count = count +1;
            end
        end
    end
end

for ii = 1:count-1
    nametesting = varchanged{ii};
    xbeach_writing.data(ii).name = nametesting;
    xbeach_writing.data(ii).value = xbeach_ddb.(nametesting);
end

%% Always write these variables
% -> make sure no double!
varsneeded = {'alfa', 'xori', 'yori', 'front', 'back', 'depfile', 'xfile', 'yfile', 'thetamin' ,'thetamax', 'dtheta', 'CFL', 'bedfriction', 'instat', 'outputformat' ,'tintm','tintg', 'tstart', 'tstop', 'globalvars', 'meanvars', 'morfac'};
for ii = 1:length(varsneeded)
    nametesting = varsneeded{ii};

    try
    if sum(strcmp(varchanged, nametesting))>0
    else
        xbeach_writing.data(count).name = nametesting;
        xbeach_writing.data(count).value = xbeach_ddb.(nametesting);
        count = count+1;
    end
    end
end

%% Make sure tides are correct
for jj = 1:length(xbeach_writing.data)
    vars{jj} = xbeach_writing.data(jj).name;
end
ids =find((strcmp(vars, 'zs0file'))>0);
if isempty(ids);
    ids = length(xbeach_writing.data)+1
else
end
zs0file = xbeach_writing.data(ids).value;
xbeach_writing.data(ids).value = [];
xbeach_writing.data(ids).value = xbeach_ddb.zs0file_info.name;

xbeach_writing.data(count).name = 'tidelen';
xbeach_writing.data(count).value = length(xbeach_ddb.zs0file_info.time);


%% Always delete
varsdelete = {'runid', 'attname', 'ParamsFile'};
for ii = 1:length(varsdelete)
    nametesting = varsdelete{ii};
    for jj = 1:length(xbeach_writing.data)
        vars{jj} = xbeach_writing.data(jj).name;
    end
    ids =find((strcmp(vars, nametesting))>0);
    xbeach_writing.data(ids) = [];
end

%% Check is every cell 'full'
ndatathings = length(length(xbeach_writing.data));
for jj = 1:ndatathings
    if isempty(xbeach_writing.data(jj).value)
        iddel = jj;
    end
    try
    if ~isempty(iddel)
    xbeach_writing.data(iddel) = [];
    end
    end
    ndatathings = length(length(xbeach_writing.data));
end


%% Writing
pathname = xbeach_ddb.params_file;
iddot = strfind(pathname, 'params.txt');
pathname = pathname(1:(iddot-1)); cd(pathname);
xb_write_params('params.txt', xbeach_writing);
