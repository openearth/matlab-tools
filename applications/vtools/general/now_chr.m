%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17748 $
%$Date: 2022-02-10 07:51:59 +0100 (Thu, 10 Feb 2022) $
%$Author: chavarri $
%$Id: absolute_limits.m 17748 2022-02-10 06:51:59Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%String of now

function nowchr=now_chr

nowchr=strrep(num2str(datenum(datetime('now'))),'.','');

end %function