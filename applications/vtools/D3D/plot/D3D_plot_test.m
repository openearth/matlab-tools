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
%

function D3D_plot_test(fdir_sim_runs,fdir_scrips,fdir_log)

%% TESTBENCH - LOG FILE

[fid_log,fpath_log] = open_log_file(fdir_log);
cleanupLog = onCleanup(@() close_log_file(fid_log)); %#ok<NASGU>

log_message(fid_log,'D3D_plot_test started: %s\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
log_message(fid_log,'Log file: %s\n',fpath_log);

%% TESTBENCH - CLEANUP

cleanup_sim_runs(fdir_sim_runs,fid_log);

%% TESTBENCH - RUN SCRIPTS

scriptDir = fdir_scrips;
scripts = dir(fullfile(scriptDir,'main_*.m'));

if isempty(scripts)
    log_message(fid_log,'No scripts found matching pattern "%s" in: %s\n', 'main_*.m', scriptDir);
    log_message(fid_log,'D3D_plot_test finished: no scripts to run.\n');
    return;
end

failedScripts = struct('name',{},'message',{});

for i = 1:numel(scripts)
    scriptName = scripts(i).name;
    scriptPath = fullfile(scriptDir,scriptName);
    log_message(fid_log,'Running script: %s\n',scriptPath);

    try
        run_script(scriptPath);

        % Stub for future checks (e.g. file equality vs reference)
        verify_outputs_stub(scriptPath,fdir_sim_runs);

        log_message(fid_log,'PASS: %s\n',scriptName);
    catch ME
        failedScripts(end+1).name = scriptName; %#ok<AGROW>
        failedScripts(end).message = ME.message;
        log_message(fid_log,'FAIL: %s\n',scriptName);
        log_message(fid_log,'%s\n',ME.getReport('extended','hyperlinks','off'));
    end
end

%% TESTBENCH - SUMMARY

if isempty(failedScripts)
    log_message(fid_log,'Testbench finished successfully. All scripts ran without errors.\n');
else
    log_message(fid_log,'Testbench finished with failures (%d/%d).\n',numel(failedScripts),numel(scripts));
    for i = 1:numel(failedScripts)
        log_message(fid_log,' - %s: %s\n',failedScripts(i).name,failedScripts(i).message);
    end
    log_message(fid_log,'Testbench completed with failures (no exception raised).\n');
end

end %function

%%
%% FUNCTIONS
%%

function cleanup_sim_runs(rootDir,fid_log)

    if ~isfolder(rootDir)
        log_message(fid_log,'Directory does not exist, skipping cleanup: %s\n', rootDir);
        return;
    end

    targetFolders = {'json','mat','csv','figures','logs'};

    folderPaths = find_target_folders_recursive(rootDir,targetFolders);

    [~,order] = sort(cellfun(@numel,folderPaths),'descend');
    folderPaths = folderPaths(order);

    for k = 1:numel(folderPaths)
        if isfolder(folderPaths{k})
            log_message(fid_log,'Deleting folder: %s\n',folderPaths{k});
            rmdir(folderPaths{k},'s');
        end
    end

    fRoot = fullfile(rootDir,'simdef.mat');
    if isfile(fRoot)
        log_message(fid_log,'Deleting file: %s\n',fRoot);
        delete(fRoot);
    end

    f = dir(fullfile(rootDir,'**','simdef.mat'));
    for i = 1:numel(f)
        fpath = fullfile(f(i).folder,f(i).name);
        if isfile(fpath)
            log_message(fid_log,'Deleting file: %s\n',fpath);
            delete(fpath);
        end
    end
end

function verify_outputs_stub(scriptPath,fpaths) %#ok<INUSD>
% Future checks can be added here, e.g. compare generated files to references.
end

function folderPaths = find_target_folders_recursive(rootDir,targetFolders)

    folderPaths = {};

    entries = dir(rootDir);
    isDot = ismember({entries.name},{'.','..'});
    entries = entries(~isDot);
    entries = entries([entries.isdir]);

    for i = 1:numel(entries)
        thisName = entries(i).name;
        thisPath = fullfile(entries(i).folder,thisName);

        if any(strcmpi(thisName,targetFolders))
            folderPaths{end+1} = thisPath; %#ok<AGROW>
            continue;
        end

        subPaths = find_target_folders_recursive(thisPath,targetFolders);
        if ~isempty(subPaths)
            folderPaths = [folderPaths, subPaths]; %#ok<AGROW>
        end
    end

    folderPaths = unique(folderPaths);
end

function [fid_log,fpath_log] = open_log_file(fdir_log)

    if ~isfolder(fdir_log)
        mkdir(fdir_log);
    end

    fpath_log = fullfile(fdir_log,sprintf('D3D_plot_test_%s.log',now_chr()));
    fid_log = fopen(fpath_log,'w');

    if fid_log == -1
        warning('D3D_plot_test:LogOpenFailed', ...
            'Could not open log file for writing: %s', fpath_log);
    end
end

function close_log_file(fid_log)
    if fid_log ~= -1
        fclose(fid_log);
    end
end

function log_message(fid_log,varargin)
    fprintf(varargin{:});
    if fid_log ~= -1
        fprintf(fid_log,varargin{:});
    end
end

%%

%In this way, the input arguments are not visible in the workspace, which is cleaner and avoids accidental modifications. Also, it allows to easily add future arguments without changing the function signature.
function run_script(scriptPath)
    run(scriptPath);
end