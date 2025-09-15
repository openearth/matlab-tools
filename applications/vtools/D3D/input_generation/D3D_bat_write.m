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

function [strsoft_lin,strsoft_win]=D3D_bat_write(dire_sim,fpath_software,dimr_str,structure,OMP_num,cluster_str,runid,partition,time_duration,tasks_per_node,nodes)

% %% PARSE
% 
% parin=inputParser;
% 
% addOptional(parin,'cluster','h7');
% addOptional(parin,'runid','r000');
% 
% parse(parin,varargin{:});
% 
% cluster=parin.Results.cluster;
% runid=parin.Results.runid;

%% CALC

%% bat

fpath_file=fullfile(dire_sim,'run.bat');

%% first write local
fname_dest=fpath_file;
fpath_file=fullfile(pwd,now_chr);

%% WRITE

fid_bat=fopen(fpath_file,'w');
fprintf(fid_bat,'@ echo off \r\n');
switch structure
    case 1 %D3D4
        % fprintf(fid_bat,'del tri-diag* \r\n'); %If there is no dia-file, it crashes. 
        fpath_software_full=fullfile(fpath_software,'x64','dflow2d3d','scripts','run_dflow2d3d.bat');
        strsoft_win=sprintf('call "%s" %s',fpath_software_full,dimr_str);
    case 2 %FM
        if ~isnan(OMP_num)
            fprintf(fid_bat,'set OMP_NUM_THREADS=%d\r\n',OMP_num);
        end
        fpath_software_full=fullfile(fpath_software,'x64','bin','run_dimr.bat');
        strsoft_win=sprintf('call "%s" %s',fpath_software_full,dimr_str);
end
fprintf(fid_bat,'%s \r\n',strsoft_win); 
fprintf(fid_bat,'exit \r\n');
fclose(fid_bat);

%% copy to destination
copyfile_check(fpath_file,fname_dest);
delete(fpath_file);

%% sh

fpath_file=fullfile(dire_sim,'run.sh');

switch cluster_str
    case 'h6c7'
        strsoft_lin=D3D_sh_h6c7(fpath_file,OMP_num,structure,fpath_software,dimr_str);
    case 'h7'
        switch structure
            case 1
                strsoft_lin=D3D_d3d4_sh_h7(fpath_file,nodes,tasks_per_node,runid,time_duration,partition,fpath_software,dimr_str);
            case 2
                strsoft_lin=D3D_fm_sh_h7(fpath_file,nodes,tasks_per_node,runid,time_duration,partition,fpath_software,dimr_str);
        end
    otherwise
        error('<cluster> cannot be: %s',cluster_str)
end

end %function

%%
%% FUNCTIONS
%%

%%

function strsoft_lin=D3D_sh_h6c7(fpath_file,OMP_num,structure,fpath_software,dimr_str)

%% first write local
fname_dest=fpath_file;
fpath_file=fullfile(pwd,now_chr);

%% WRITE

fid_bat=fopen(fpath_file,'w');
switch structure
    case 1 %D3D4
        strsoft_lin=sprintf('%s\\lnx64\\bin\\submit_dflow2d3d.sh',fpath_software);
        strsoft_lin=sprintf('%s -q normal-e3-c7 -m %s',linuxify(strsoft_lin),dimr_str);
    case 2 %FM
        if ~isnan(OMP_num)
            fprintf(fid_bat,'export OMP_NUM_THREADS=%d',OMP_num);
        end
        strsoft_lin=sprintf('%s\\lnx64\\bin\\submit_dimr.sh',fpath_software);
        strsoft_lin=sprintf('%s -m %s -d 9 -q normal-e3-c7',linuxify(strsoft_lin),dimr_str);
end
fprintf(fid_bat,'%s \r\n',strsoft_lin); 
fclose(fid_bat);

%% copy to destination
copyfile_check(fpath_file,fname_dest);
delete(fpath_file);

end %function

%%

function strsoft_lin=D3D_fm_sh_h7(fpath_file,nodes,tasks_per_node,runid,time_duration,partition,fpath_software,dimr_str)

%%

strsoft_lin=''; %there is no point in calling in sequential in linux I think. Not sure how to do it. 
str_time_limit=duration2double_string(time_duration);

%% first write local
fname_dest=fpath_file;
fpath_file=fullfile(pwd,now_chr);

%% WRITE

fid=fopen(fpath_file,'w');

fprintf(fid,'#! /bin/bash \r\n');
fprintf(fid,'   \r\n');
fprintf(fid,'# Usage: \r\n');
fprintf(fid,'#   - Copy this script into your working folder, next to the dimr config file. \r\n');
fprintf(fid,'#   - Modify this script where needed (e.g. number of nodes, number of tasks per node). \r\n');
fprintf(fid,'#   - Execute this script from the command line of H7 using: ./run_native_h7.sh \r\n');
fprintf(fid,'# \r\n');
fprintf(fid,'# This is an h7 specific script for single or multi-node simulations. \r\n');
fprintf(fid,' \r\n');
fprintf(fid,'# Set bash options. Exit on failures (and propagate errors in pipes). \r\n');
fprintf(fid,'set -eo pipefail \r\n');
fprintf(fid,' \r\n');
fprintf(fid,'# These variables should be modified. \r\n');
fprintf(fid,'NODES=%d \r\n',nodes);
fprintf(fid,'TASKS_PER_NODE=%d \r\n',tasks_per_node);
fprintf(fid,'JOB_NAME="%s" \r\n',runid);
fprintf(fid,'PARTITION="%s" \r\n',partition);
fprintf(fid,'TIME_LIMIT="%s" \r\n',str_time_limit);
fprintf(fid,'DIMR_FOLDER="%s" \r\n',linuxify(fpath_software));
fprintf(fid,'DIMR_FILE="${PWD}/%s" \r\n',dimr_str);
fprintf(fid,'   \r\n');
fprintf(fid,'# Compute the total number of tasks (across all nodes). \r\n');
fprintf(fid,'NTASKS=$(( $NODES * $TASKS_PER_NODE )) \r\n');
fprintf(fid,' \r\n');
fprintf(fid,'# Modify the value of the process tag in dimr_config.xml. \r\n');
fprintf(fid,'PROCESS_STR="$(seq -s " " 0 $(( $NTASKS - 1 )))" \r\n');
fprintf(fid,'sed -i "s/\\(<process.*>\\)[^<>]*\\(<\\/process.*\\)/\\1$PROCESS_STR\\2/" $DIMR_FILE \r\n');
fprintf(fid,' \r\n');
fprintf(fid,'# The name of the MDU file is read from the DIMR configuration file. \r\n');
fprintf(fid,'MDU_FILENAME=$(sed -n ''s/\\r//; s/<inputFile>\\(.*[.]mdu\\)<\\/inputFile>/\\1/p'' $DIMR_FILE | sed -n ''s/^\\s*\\(.*\\)\\s*$/\\1/p'') \r\n');
fprintf(fid,' \r\n');
fprintf(fid,'# Partition data using dflowfm. \r\n');
fprintf(fid,'if [[ $NTASKS -gt 1 ]]; then \r\n');
fprintf(fid,'    #pushd dflowfm \r\n');
fprintf(fid,'    echo "Partitioning parallel model..." \r\n');
fprintf(fid,'    echo "Run dflowfm on $MDU_FILENAME with $NTASKS partitions." \r\n');
fprintf(fid,'    sbatch --job-name=partition_${JOB_NAME} \\\r\n');
fprintf(fid,'        --partition=1vcpu \\\r\n');
fprintf(fid,'        --time=00:15:00 \\\r\n');
fprintf(fid,'        --nodes=1 \\\r\n');
fprintf(fid,'        --ntasks-per-node=1 \\\r\n');
fprintf(fid,'        --wait \\\r\n');
fprintf(fid,'        ${DIMR_FOLDER}/lnx64/bin/submit_dflowfm_h7.sh \\\r\n');
fprintf(fid,'            --partition:ndomains=${NTASKS}:icgsolver=6 $MDU_FILENAME\r\n');
fprintf(fid,'    #popd \r\n');
fprintf(fid,'else \r\n');
fprintf(fid,'    echo "Sequential model..." \r\n');
fprintf(fid,'fi \r\n');
fprintf(fid,' \r\n');
fprintf(fid,'# Run simulation using dimr. \r\n');
fprintf(fid,'echo "Run simulation..." \r\n');
fprintf(fid,'sbatch --job-name=$JOB_NAME \\\r\n');
fprintf(fid,'    --partition=$PARTITION \\\r\n');
fprintf(fid,'    --time=$TIME_LIMIT \\\r\n');
fprintf(fid,'    --nodes=$NODES \\\r\n');
fprintf(fid,'    --ntasks-per-node=$TASKS_PER_NODE \\\r\n');
fprintf(fid,'    ${DIMR_FOLDER}/lnx64/bin/submit_dimr_h7.sh -m $DIMR_FILE\r\n');

fclose(fid);

%% copy to destination
copyfile_check(fpath_file,fname_dest);
delete(fpath_file);

end %function

%%

function strsoft_lin=D3D_d3d4_sh_h7(fpath_file,nodes,tasks_per_node,runid,time_duration,partition,fpath_software,dimr_str)

%%

strsoft_lin=''; %there is no point in calling in sequential in linux I think. Not sure how to do it. 
str_time_limit=duration2double_string(time_duration);

%% first write local
fname_dest=fpath_file;
fpath_file=fullfile(pwd,now_chr);

%% WRITE

fid=fopen(fpath_file,'w');

fprintf(fid,'#!/bin/bash\r\n');
fprintf(fid,'#\r\n');
fprintf(fid,'# This is an h7 specific script for single or multi-node simulations.\r\n');
fprintf(fid,'#\r\n');
fprintf(fid,'# Usage:\r\n');
fprintf(fid,'#   - Copy this script into your working folder, next to the config (and wave) file.\r\n');
fprintf(fid,'#   - Modify this script where needed (e.g. number of nodes, number of tasks per node).\r\n');
fprintf(fid,'#	- Start a command line in H7.\r\n');
fprintf(fid,'#	- Execute: `dos2unix ./run_dflow2d3d_h7.sh`\r\n');
fprintf(fid,'#   - Execute: `./run_dflow2d3d_h7.sh`\r\n');
fprintf(fid,'#\r\n');
fprintf(fid,'\r\n');
fprintf(fid,'# stop after an error occured:\r\n');
fprintf(fid,'set -e\r\n');
fprintf(fid,' \r\n');
fprintf(fid,'# Set numbers of hosts and cores per host\r\n');
fprintf(fid,'nNodes=%d\r\n',nodes);
fprintf(fid,'nProc=%d\r\n',tasks_per_node);
fprintf(fid,'TIME_LIMIT="%s" \r\n',str_time_limit);
fprintf(fid,'WAVES=rb_ny_wave_wit4_feiner.mdw\r\n');
fprintf(fid,'CONFIG=%s \r\n',dimr_str);
fprintf(fid,'PARTITION="%s" #`scontrol show partition` to see available partitions and time limit\r\n',partition);
fprintf(fid,'\r\n');
fprintf(fid,'# set Delft3D4 version to be used\r\n');
fprintf(fid,'delft3d4dir=%s\r\n',linuxify(fpath_software));
fprintf(fid,'\r\n');
fprintf(fid,'export jobName="%s"\r\n',runid);
fprintf(fid,'\r\n');
fprintf(fid,'#if FLOW\r\n');
fprintf(fid,'$delft3d4dir/lnx64/bin/submit_dflow2d3d_AL8.sh -n $nNodes -c $nProc -j $jobName -t $TIME_LIMIT -p $PARTITION -m $CONFIG\r\n');
fprintf(fid,'\r\n');
fprintf(fid,'#if FLOW+WAVES\r\n');
fprintf(fid,'#$delft3d4dir/lnx64/bin/submit_dflow2d3d_AL8.sh -n $nNodes -c $nProc -j $jobName -w $WAVES -t $TIME_LIMIT -p $PARTITION -m $CONFIG\r\n');

fclose(fid);

%% copy to destination
copyfile_check(fpath_file,fname_dest);
delete(fpath_file);

end %function