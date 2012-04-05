function varargout = ncgen_mainFcn(readFcn,writeFcn,varargin)

narginchk(2,inf)
if isempty(readFcn);  readFcn   = @(~,~,~)struct('undefined',true); else  assert(isa(readFcn, 'function_handle'), 'readFcn must be a function handle'); end
if isempty(writeFcn); writeFcn  = @(~,~,~)struct('undefined',true); else  assert(isa(writeFcn,'function_handle'),'writeFcn must be a function handle'); end
%% list options

% general settings
OPT.main.zip            = 0; % specify if source files are compressed or not
OPT.main.zip_regex      = '1x1\.xyz\.7z$';
OPT.main.unzip_with_gui = 1;
OPT.main.regex          = 'xyz$';
OPT.main.dateFcn        = @(s) datenum(s(1:6),'yymmdd'); % how to extract date from the filename
OPT.main.defaultdate    = []; 

% path settings
OPT.main.path_src       = ''; % path to source data
OPT.main.path_src_unz   = fullfile(tempdir,'ncgen)grid'); % path to unzipped source data, should be a tempdir
OPT.main.path_ncf_loc   = 'D:\products\nc'; % local path to write ncdf files to
OPT.main.path_ncf_net   = ''; % network path to copy nc files to once generation is completed 
OPT.main.path_ncf_www   = ''; % path on which the nc filese are accesible, on e.g. the nc server

OPT.read                = readFcn([],[],[]);
OPT.write               = writeFcn([],[],[]);

processed_varargin      = setproperty(OPT,varargin);

OPT.main                = setproperty(OPT.main, processed_varargin.main);
OPT.read                = setproperty(OPT.read, processed_varargin.read);
OPT.write               = setproperty(OPT.write,processed_varargin.write);
% if nargin == 3
    varargout = {OPT};
    return
% end


% seperately check the properties for the dataype
OPT.main.(datatype) = setproperty(processFcn(),OPT.main.(datatype));


%% input check

assert(~isempty(OPT.main.path_src),    'No source directory was defined');
assert(~isempty(OPT.main.path_ncf_loc),'No nc directory to write to was defined');
assert(logical(exist(OPT.main.path_src,'dir')),'Source directory ''%s'' does not exist',OPT.main.path_src);



%% other preparations
% initialize waitbars
multiWaitbar('Generating netcdf from source files...',          'reset', 'Color', [0.2 0.6 0.2])     % green
% initialise cache dir and locate source files
if OPT.main.zip
    if ~exist(OPT.main.path_src_unz,'dir'); mkpath(OPT.main.path_src_unz); end
    fns1 = dir2(OPT.main.path_src,'file_incl',OPT.main.zip_regex,'no_dirs',true);
else
    fns1 = dir2(OPT.main.path_src,'file_incl',OPT.main.regex,'no_dirs',true);
    % get the timestamp from the file date
    fns1 = get_date_from_filename(OPT,fns1);
 end

% check if files are found
if isempty(fns1)
     error('NCGEN_GRID:noSourcefiles','No source files were found in directory %s',OPT.main.path_src)
end

% generate md5 hashes of all source files
fns1 = hash_files(fns1);


%%
% if a nc files exist in the destination directory, check the hashes and grid settings

% initialise netcdf dir
if exist(OPT.main.path_ncf_loc,'dir');
    fns1 = check_existing_nc_files(fns1,OPT);
else
    mkpath(OPT.main.path_ncf_loc);
end

if isempty(fns1)
    returnmessage(1,'Netcdf files were alreay up to date, no changes made\n')
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
        readFcn(OPT);
        
        % waitbar
        multiWaitbar('Generating netcdf from source files...',(WB.bytesDone + sum(fns2(1:ii).bytes)/WB.zipRatio)/WB.bytesToDo);
    end
    WB.bytesDone = WB.bytesDone + fns1(jj).bytes;
end
multiWaitbar('Processing file','close');
multiWaitbar('Generating netcdf from source files...',1);

returnmessage(1,'Netcdf generation completed\n')

function fns2 = unzip_src_files(OPT,fns1)
%delete files in cache

delete(fullfile(OPT.main.path_src_unz,'*.*'))

% uncompress files with a gui for progress indication
uncompress(fullfile(fns1.pathname,fns1.name),...
    'outpath',fullfile(OPT.main.path_src_unz),'gui',OPT.main.unzip_with_gui,'quiet',true);

% read the output of unpacked files
fns2 = dir2(OPT.main.path_src_unz,'file_incl',OPT.main.regex,'no_dirs',true);

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

function fns1 = check_existing_nc_files(fns1,OPT)

nc_fns = dir2(OPT.main.path_ncf_loc,'file_incl','\.nc$','no_dirs',true);
outdated = false;
ii=0;
source_file_hash = [];
while ~outdated && ii<length(nc_fns)
    ii = ii+1;
    ncfile = [nc_fns(ii).pathname nc_fns(ii).name];
    try
        outdated = ~isequal(...
            OPT.main.meta.history,...
            ncreadatt(ncfile,'/','history'));
        source_file_hash = [source_file_hash; ncread(ncfile,'source_file_hash')']; %#ok<AGROW>
    catch  %#ok<CTCH>
        outdated = true;
    end
end

if ~outdated
    % check hashes
    source_file_hash = unique(source_file_hash,'rows');
    % all hashes in nc structure must be in files.
    outdated = ~all(ismember(source_file_hash,vertcat(fns1.hash),'rows'));
end   

if outdated
    delete(fullfile(OPT.main.path_ncf_loc,'*.*'));
    returnmessage(1,'netcdf output directory was outdated and therefore emptied\n')
else
    % remove files already in nc from file name stucture  as they are
    % already in the nc file
    fns1(ismember(vertcat(fns1.hash),source_file_hash,'rows')) = [];
end  