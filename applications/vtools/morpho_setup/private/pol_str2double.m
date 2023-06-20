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

function pol_lo=pol_str2double(pol_lo_str)

if strcmp(pol_lo_str(1),'R')
    s=1;
elseif strcmp(pol_lo_str(1),'L')
    s=-1;
else
    s=NaN;
end

pol_lo=s*str2double(pol_lo_str(2));

end %function
