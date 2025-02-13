%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19687 $
%$Date: 2024-06-24 17:30:38 +0200 (Mon, 24 Jun 2024) $
%$Author: chavarri $
%$Id: twoD_study.m 19687 2024-06-24 15:30:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%
%Time unit depending on length. 

function [t_disp,t_str]=time_display(t_sec)

if t_sec<3600
    t_disp=t_sec;
    t_str='[s]';
elseif t_sec<24*3600
    t_disp=t_sec/3600;
    t_str='[h]';
elseif t_sec<24*3600*365    
    t_disp=t_sec/(24*3600);
    t_str='[d]';
else 
    t_disp=t_sec/(24*3600*365);
    t_str='[a]';
end

end %function