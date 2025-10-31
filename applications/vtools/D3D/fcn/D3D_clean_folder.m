%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%D3D_clean_folder Recursively delete specific files in all subfolders.
%
%   D3D_clean_folder(ROOTFOLDER, DRYRUN)
%
%   Searches all subdirectories of ROOTFOLDER and deletes files matching:
%       - core.d_hydro.<number>
%       - slurm-<number>.out
%       - tri-diag.<anything>
%
%   Arguments:
%       ROOTFOLDER : starting folder (default = current directory)
%       DRYRUN     : true to list files without deleting (default = false)
%
%   Example:
%       delete_matching_files('/home/user/data', true)
%       delete_matching_files('C:\projects', false)

function D3D_clean_folder(rootFolder, dryRun)

    if nargin < 1 || isempty(rootFolder)
        rootFolder = pwd; % Default: current directory
    end
    if nargin < 2
        dryRun = false;   % Default: actually delete
    end

    % Recursively get all files
    fileList = getAllFiles(rootFolder);

    % Define patterns (regular expressions)
    patterns = { ...
        '^core\.d_hydro\.\d+$', ...     % e.g., core.d_hydro.1743
        '^slurm-\d+\.out$', ...         % e.g., slurm-157446.out
        '^tri-diag\..+$'                % e.g., tri-diag.r016
    };

    deletedCount = 0;

    % Loop through files and delete matches
    for i = 1:numel(fileList)
        [~, name, ext] = fileparts(fileList{i});
        filename = [name ext];

        for p = 1:numel(patterns)
            if ~isempty(regexp(filename, patterns{p}, 'once'))
                if dryRun
                    fprintf('[DRY-RUN] Would delete: %s\n', fileList{i});
                else
                    fprintf('Deleting: %s\n', fileList{i});
                    delete(fileList{i});
                end
                deletedCount = deletedCount + 1;
                break;
            end
        end
    end

    % Summary
    if dryRun
        fprintf('\n[DRY-RUN] %d files matched.\n', deletedCount);
    else
        fprintf('\nDeleted %d files.\n', deletedCount);
    end
end

%%
%% FUNCTIONS
%%

function fileList = getAllFiles(dirName)
% Recursively get all files under dirName

    dirData = dir(dirName);                 % Get directory data
    dirIndex = [dirData.isdir];             % Find directories
    fileList = {dirData(~dirIndex).name}';  % Get file names
    fileList = fullfile(dirName, fileList); % Add full paths

    % Recursively call for subfolders
    subDirs = {dirData(dirIndex).name};
    validIndex = ~ismember(subDirs, {'.', '..'});
    for i = find(validIndex)
        nextDir = fullfile(dirName, subDirs{i});
        fileList = [fileList; getAllFiles(nextDir)]; %#ok<AGROW>
    end
end