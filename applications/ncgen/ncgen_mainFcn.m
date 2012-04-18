function varargout = ncgen_mainFcn(schemaFcn,readFcn,writeFcn,varargin)

narginchk(3,inf)
if isempty(schemaFcn); schemaFcn = @(~)    struct('undefined',true); else  assert(isa(schemaFcn,'function_handle'),'schemaFcn must be a function handle'); end
if isempty(readFcn);   readFcn   = @(~,~,~)struct('undefined',true); else  assert(isa(readFcn,  'function_handle'),  'readFcn must be a function handle'); end
if isempty(writeFcn);  writeFcn  = @(~,~)  struct('undefined',true); else  assert(isa(writeFcn, 'function_handle'), 'writeFcn must be a function handle'); end
%% list options

% general settings
OPT.main.log            = 1;
OPT.main.file_incl      = '.*';
OPT.main.zip            = false; % specify if source files are compressed or not
OPT.main.zip_file_incl  = '.*';
OPT.main.unzip_with_gui = 1;
OPT.main.dateFcn        = @(s) datenum(s(1:6),'yymmdd'); % how to extract date from the filename
OPT.main.defaultdate    = []; 
OPT.main.dir_depth      = inf;

% path settings
OPT.main.path_source    = ''; % path to source data
OPT.main.path_unzip_tmp = fullfile(tempdir,'ncgen'); % path to unzipped source data, should be a tempdir
OPT.main.path_netcdf    = 'D:\products\nc'; % local path to write ncdf files to

OPT.schema              = schemaFcn([]);
OPT.read                = readFcn([],[],[]);
OPT.write               = writeFcn([],[]);

processed_varargin      = setproperty(OPT,varargin);

% seperately check the properties for each of the functions
OPT.main                = setproperty(OPT.main,  processed_varargin.main);
OPT.schema              = setproperty(OPT.schema,processed_varargin.schema);
OPT.read                = setproperty(OPT.read,  processed_varargin.read);
OPT.write               = setproperty(OPT.write, processed_varargin.write);

if nargin == 3
    varargout = {OPT};
    return
end


%% input check
assert(~isempty(OPT.main.path_source) ,'No source directory was defined');
assert(~isempty(OPT.main.path_netcdf) ,'No netcdf directory to write to was defined');
assert(exist(OPT.main.path_source,'dir') || exist(OPT.main.path_source,'file'),...
    'Source directory ''%s'' does not exist',OPT.main.path_source);

%% create schema
if isempty(OPT.write.schema)
    OPT.write.schema = schemaFcn(OPT);
else
    required_fields = {'Filename','Name','Dimensions','Variables','Attributes','Groups','Format'};
    assert(all(ismember(required_fields,fieldnames(OPT.write.schema))),'User defined netcdf schema is not valid. Use schemaFcn to create a validschema');
end

%% other preparations
% initialize waitbars
multiWaitbar('Generating netcdf from source files...',          'reset', 'Color', [0.2 0.6 0.2])     % green
% initialise cache dir and locate source files
if OPT.main.zip
    if ~exist(OPT.main.path_unzip_tmp,'dir'); mkpath(OPT.main.path_unzip_tmp); end
    fns1 = dir2(OPT.main.path_source,'file_incl',OPT.main.zip_file_incl,'no_dirs',true,'depth',OPT.main.dir_depth);
else
    fns1 = dir2(OPT.main.path_source,'file_incl',OPT.main.file_incl,'no_dirs',true,'depth',OPT.main.dir_depth);
    % get the timestamp from the file date
    fns1 = get_date_from_filename(OPT,fns1);
 end

% check if files are found
if isempty(fns1)
     error('NCGEN_GRID:noSourcefiles','No source files were found in directory %s',OPT.main.path_source)
end

% generate md5 hashes of all source files
fns1 = hash_files(fns1);


%% check the contents of the output directory
if exist(OPT.main.path_netcdf,'dir');
    fns1 = check_existing_nc_files(OPT,fns1);
else
    mkpath(OPT.main.path_netcdf);
end
    
WB.bytesToDo         = sum([fns1.bytes]);
WB.bytesDone         = 0;
WB.zipRatio          = 1;

%% loop through source files
multiWaitbar('Processing file','reset', 'Color', [0.9 0.7 0.1]);
for jj = 1:length(fns1);
    % unzip
    if OPT.main.zip
        fns2 = unzip_src_files(OPT,fns1(jj));
        % calculate a zip ratio to estimate the compression level (used to estimate the total work for the progress bar)
        WB.zipRatio  = sum([fns2.bytes])/fns1(jj).bytes;
    else
        fns2 = fns1(jj);
    end
    
    for ii = length(fns2);
        % do function
        readFcn(OPT,writeFcn,fns2(ii));
        
        % waitbar
        multiWaitbar('Generating netcdf from source files...',(WB.bytesDone + sum(fns2(1:ii).bytes)/WB.zipRatio)/WB.bytesToDo);
    end
    WB.bytesDone = WB.bytesDone + fns1(jj).bytes;
end
multiWaitbar('Processing file','close');
multiWaitbar('Generating netcdf from source files...','close');
returnmessage(OPT.main.log,'Netcdf generation completed\n')

function fns2 = unzip_src_files(OPT,fns1)
%delete files in cache

delete(fullfile(OPT.main.path_unzip_tmp,'*.*'))

% uncompress files with a gui for progress indication
uncompress(fullfile(fns1.pathname,fns1.name),...
    'outpath',fullfile(OPT.main.path_unzip_tmp),'gui',OPT.main.unzip_with_gui,'quiet',true);

% read the output of unpacked files
fns2 = dir2(OPT.main.path_unzip_tmp,'file_incl',OPT.main.file_incl,'no_dirs',true,'depth',OPT.main.dir_depth);

[fns2.hash] = deal(fns1.hash); % hash of zipped file is passed

fns2 = get_date_from_filename(OPT,fns2);

function fns = get_date_from_filename(OPT,fns)

if isempty(OPT.main.defaultdate);
    try
        date_from_filename = cellfun(OPT.main.dateFcn,{fns.name});
        for ii = 1:length(fns)
            fns(ii).date_from_filename = date_from_filename(ii);
        end
        clear date_from_filename
    catch ME
        error('NCGEN_GRID:unreadableDateStr',...
            'Failed to get date from filename, reason:\n%s',ME.message);
    end
else
    [fns1.date_from_filename] = deal(OPT.main.defaultdate);
end

function fns1 = check_existing_nc_files(OPT,fns1)

nc_fns = dir2(OPT.main.path_netcdf,'file_incl','\.nc$','no_dirs',true,'depth',OPT.main.dir_depth);
outdated = false;
ii=0;
source_file_hash = [];
while ~outdated && ii<length(nc_fns)
    ii = ii+1;
    ncfile = [nc_fns(ii).pathname nc_fns(ii).name];
    % query nc schema to compare variables and dimensions
    ncschema = ncinfo(ncfile);
    try
        % compare attributes (only compare the attributes to the user
        % define attributes as additional attributes may be added by hthe
        % netcdf write function as e.g. x_range
        if ~isequal(ncschema.Attributes(1:length(OPT.write.schema.Attributes)),OPT.write.schema.Attributes)
            outdated = true;
            continue;
        end
        
        % compare dimension names
        if ~isequal([ncschema.Dimensions.Name],[OPT.write.schema.Dimensions.Name]);
            outdated = true;
            continue;
        end
        
        % compare variables
        if ...
                ~isequal([ncschema.Variables.Name],        [OPT.write.schema.Variables.Name])     || ...
                ~isequal([ncschema.Variables.Datatype],    [OPT.write.schema.Variables.Datatype]) || ...
                ~isequal([ncschema.Variables.DeflateLevel],[OPT.write.schema.Variables.DeflateLevel]);
            outdated = true;
            continue;
        end
        
        % compare dimension lengths
        current_length = [ncschema.Dimensions.Length];
        current_length([ncschema.Dimensions.Unlimited]) = nan;
        new_length = [OPT.write.schema.Dimensions.Length];
        new_length([OPT.write.schema.Dimensions.Length] == inf | [OPT.write.schema.Dimensions.Unlimited])= nan;
        if ~isequalwithequalnans(current_length,new_length);
            outdated = true;
            continue;
        end
        
    catch  %#ok<CTCH>
        % isf anything went wrong, assume netcdf is outdated
        outdated = true;
        continue;
    end
    
    % collect source file hashes
    source_file_hash = [source_file_hash; ncread(ncfile,'source_file_hash')']; %#ok<AGROW>
end
if ~outdated
    % check hashes
    source_file_hash = unique(source_file_hash,'rows');
    % all hashes in nc structure must be in files.
    outdated = ~all(ismember(source_file_hash,vertcat(fns1.hash),'rows'));
end   

if outdated
    delete(fullfile(OPT.main.path_netcdf,'*.*'));
    returnmessage(OPT.main.log,'Netcdf output directory was outdated and therefore emptied.\n')
else
    % remove files already in nc from file name stucture  as they are
    % already in the nc file
    a = length(fns1);
    fns1(ismember(vertcat(fns1.hash),source_file_hash,'rows')) = [];
    b = length(fns1);
    returnmessage(OPT.main.log,'%d of %d source files where skipped as they where already processed.\n',a-b,a);
end  