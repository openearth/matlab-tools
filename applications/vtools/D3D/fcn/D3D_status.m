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
%INPUT
%   simdef: several options:
%       -simdef structure
%       -cell array with path to simulation folder
%
%OUTPUT:
%   sta=1: not started
%   sta=2: running
%   sta=3: done
%   sta=4: interrupted (did not reach final time but exit controlled)

function [sta,time_comp,tgen,version,tim_ver,source,processes]=D3D_status(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN);

parse(parin,varargin{:});

fid_log=parin.Results.fid_log;

%% case input is cell array

if iscell(simdef)
    ns=numel(simdef);
    sta=NaN(ns,1);
    time_comp=NaT(ns,1)-datetime(2000,1,1); %duration
    tgen=NaT(ns,1);
    version=cell(ns,1);
    tim_ver=NaT(ns,1);
    source=cell(ns,1);
    processes=NaN(ns,1);
    for ks=1:ns
        if isfolder(simdef{ks})
            simdef_true.D3D.dire_sim=simdef{ks};
            [sta(ks),time_comp(ks),tgen(ks),version{ks},tim_ver(ks),source{ks}]=D3D_status(simdef_true,varargin{:});
        else
            error('do')
        end
    end
    return
end

%% case input is structure

    %% check if file with status exists

fdir_mat=fullfile(simdef.D3D.dire_sim,'mat');
fpath_status=fullfile(fdir_mat,'status.mat');
if isfolder(fdir_mat)
    if exist(fpath_status,'file')==2
        messageOut(fid_log,sprintf('Loading status from file: %s',fpath_status));
        load(fpath_status,'status');
        if status.sta>2
            messageOut(fid_log,'Simulation finished.')
            v2struct(status);
            return
        end
    end
else
    mkdir_check(fdir_mat);
end

    %% file with status does not exist or simulation has not finished

%allocate
sta=NaN;
time_comp=NaT-datetime(2000,1,1); %duration
tgen=NaT;
version='';
tim_ver=NaT;
source='';
processes=NaN;

%get paths
simdef=D3D_simpath(simdef);

    %% check if simulation has started

%this can be improved seeing whether a map and his file are requested
if isfield(simdef.file,'map')==0 && isfield(simdef.file,'his')==0
    sta=1; 
    messageOut(fid_log,'Simulation has not started.')
    return
end

    %% Simulation Management Tool (SMT) structure

if ismember(simdef.D3D.structure,[4,5]) %SMT
    fdir_output=fullfile(simdef.D3D.dire_sim,'output');
    if ~isfolder(fdir_output)
        sta=1; 
        messageOut(fid_log,'Simulation has not started.')
        return
    end
    dire=dir(fdir_output);
    if any(ismember({dire.name},{'work'}))
        sta=2; 
        messageOut(fid_log,'Simulation is running.')
        return
    else
        sta=3; 
        %modify function below to compute simulation time of SMT and make function to compute time, pack, and save. 
        % [time_comp,~,~,processes]=D3D_computation_time(simdef.file.dia);
        %save if simulation has finished
        status=v2struct(sta,time_comp,tgen,version,tim_ver,source,processes);
        save_check(fpath_status,'status');
        messageOut(fid_log,'Simulation finished.')
        return
    end
end

    %% check if simulation is interrupted

is_inter=D3D_is_interrupt(simdef,varargin);
if is_inter
    sta=4;
    if simdef.D3D.structure==2
        time_comp=D3D_computation_time(simdef.file.dia);
        [tgen,version,tim_ver,source]=D3D_version(simdef,varargin);
    end
    messageOut(fid_log,'Simulation is interrupted.')
    return 
end

    %% check if simulation is done

is_done=D3D_is_done(simdef,varargin);

    %% compute time and version if done, and save status

if is_done
    sta=3;
    [time_comp,~,~,processes]=D3D_computation_time(simdef.file.dia);
    [tgen,version,tim_ver,source]=D3D_version(simdef,varargin);
    %save if simulation has finished
    status=v2struct(sta,time_comp,tgen,version,tim_ver,source,processes);
    save_check(fpath_status,'status');
    messageOut(fid_log,'Simulation finished.')
    return 
end

    %% if not interrupted and not done, then is running
    
sta=2; 
[tgen,version,tim_ver,source]=D3D_version(simdef,varargin);
messageOut(fid_log,'Simulation is running.')

end %function