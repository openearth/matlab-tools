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

function ret=gdm_do_mat(fid_log,flg_loc,tag)

%% PARSE

if isfield(flg_loc,'do')==0
    flg_loc.do=1;
end

%% CALC

ret=0;

if ~flg_loc.do
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    ret=1;
    return
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

end %function