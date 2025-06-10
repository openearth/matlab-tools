%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19009 $
%$Date: 2023-06-20 07:14:19 +0200 (Tue, 20 Jun 2023) $
%$Author: chavarri $
%$Id: pol_str2double.m 19009 2023-06-20 05:14:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/private/pol_str2double.m $
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
