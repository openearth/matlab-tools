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