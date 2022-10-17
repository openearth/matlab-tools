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

function [ndiff,flg_loc]=gdm_ndiff(flg_loc)

if isfield(flg_loc,'do_diff')==0
    flg_loc.do_diff=1;
end

if flg_loc.do_diff==0
    ndiff=1;
else 
    ndiff=2;
end

end %function