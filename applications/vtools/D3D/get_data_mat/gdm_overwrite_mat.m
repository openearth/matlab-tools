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

function [ret,flg_loc]=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat)

%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end

%% CALC

ret=0;

if exist(fpath_mat,'file')==2
    messageOut(fid_log,'Mat-file already exist.')
    if flg_loc.overwrite==0
        messageOut(fid_log,'Not overwriting mat-file.')
        ret=1;
        return
    end
    messageOut(fid_log,'Overwriting mat-file.')
else
    messageOut(fid_log,'Mat-file does not exist. Reading.')
end

end %function