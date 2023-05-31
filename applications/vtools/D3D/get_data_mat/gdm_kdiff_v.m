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

function kdiff_v=gdm_kdiff_v(flg_loc)

%% PARSE

if isfield(flg_loc,'do_s')==0 %difference between runs
    flg_loc.do_s=1; %this is checked at the beginning of the run, but doesn't harm
end

if isfield(flg_loc,'do_s_diff')==0 %difference between runs and initial time
    flg_loc.do_s_diff=0;
end

if isfield(flg_loc,'do_s_perc')==0 %difference between runs in percentage terms
    flg_loc.do_s_perc=0;
end

%% CALC

%needs to match `gdm_data_diff`
kdiff_v=[];
if flg_loc.do_s
    kdiff_v=cat(2,kdiff_v,2);
end
if flg_loc.do_s_perc
    kdiff_v=cat(2,kdiff_v,3);
end
if flg_loc.do_s_diff
    kdiff_v=cat(2,kdiff_v,4);
end

end %function 