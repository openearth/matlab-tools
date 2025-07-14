%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20235 $
%$Date: 2025-07-07 14:32:25 +0200 (Mon, 07 Jul 2025) $
%$Author: chavarri $
%$Id: D3D_gdm.m 20235 2025-07-07 12:32:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Read FLORIS CFG file. 

function [cfg,file]=floris_to_fm_read_cfg(fpath_cfg,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 

%% CHECK FILE

messageOut(fid_log,'Start processing CFG.')

[fdir,~,fext]=fileparts(fpath_cfg);

if ~exist(fpath_cfg,'file')==2
    messageOut(fid_log,sprintf('cfg-file does not exist: %s',fpath_cfg))
end
if ~strcmp(fext,'.cfg')
    messageOut(fid_log,sprintf('This is supposed to be a cfg-file: %s',fpath_cfg))
end

%% CALC

cfg=D3D_io_input('read',fpath_cfg);

file.cfg=fpath_cfg;

file_cell={'floin_file','floab_file','funin_file','funtab_file'}; %add more
nf=numel(file_cell);
for kf=1:nf
    file_tag=file_cell{kf};
    file_tag_reduced=strrep(file_tag,'_file',''); 
    if isfield(cfg,file_tag)
        file.(file_tag_reduced)=fullfile(fdir,cfg.(file_tag));
    else
        file.(file_tag_reduced)='';
        messageOut(fid_log,sprintf('Flag not found: %s',file_tag))
    end
end %nf

end %function