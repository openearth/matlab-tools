%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18545 $
%$Date: 2022-11-15 13:06:55 +0100 (di, 15 nov 2022) $
%$Author: chavarri $
%$Id: D3D_io_input.m 18545 2022-11-15 12:06:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
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
