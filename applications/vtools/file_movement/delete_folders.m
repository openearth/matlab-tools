%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19299 $
%$Date: 2023-12-12 17:03:24 +0100 (Tue, 12 Dec 2023) $
%$Author: chavarri $
%$Id: create_mat_map_sedtransoff_01.m 19299 2023-12-12 16:03:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sedtransoff_01.m $
%
%Creates a sh-file to submit to a cluster the deletion of folders
%depending on its size. 
%
%INPUT:
%   -fdir = directory to analyze [char]
%
%OUTPUT:
%   -
%
%OPTIONAL (pair input):
%   -fpath_sh = full path to the script to submit to the cluster with the erase commands [char]
%   -size     = limit size of the folder to erase [bytes] [double]. 1 MB = 1e6 bytes. 1 GB = 1e9 bytes.

function delete_folders(fdir,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_sh',fullfile(pwd,'delete_folder.sh'));
addOptional(parin,'size',0);

parse(parin,varargin{:});

fpath_sh=parin.Results.fpath_sh;
sz_lim=parin.Results.size;

%% OPEN

fid=fopen(fpath_sh,'w');
if fid<1
    error('Could not open file: %s',fpath_sh);
end
fprintf(fid,'#!/bin/bash \r\n');
fprintf(fid,'#$ -cwd \r\n');
fprintf(fid,'#$ -m bea \r\n');
fprintf(fid,'#$ -q normal-e3-c7 \r\n');
fprintf(fid,'# \r\n');
fprintf(fid,'# NOTES: \r\n');
fprintf(fid,'#	-do a dos2unix \r\n');
fprintf(fid,'# 	-call as qsub ./<fpath_sh> \r\n');
fprintf(fid,' \r\n');

%% CALL

messageOut(NaN,'Start computing.')
dir_size(fdir,fid,sz_lim);

%% CLOSE

fclose(fid);

messageOut(NaN,sprintf('File to run: %s',fpath_sh))

end %function