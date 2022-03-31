%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17208 $
%$Date: 2021-04-23 08:52:13 +0200 (Fri, 23 Apr 2021) $
%$Author: chavarri $
%$Id: cor2cen.m 17208 2021-04-23 06:52:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/cor2cen.m $
%
%

function fext=ext_of_fig(fig_print)

switch fig_print
    case 1
        fext='.png';
    case 2
        fext='.fig';
    case 3
        fext='.eps';
    case 4
        fext='.jpg';
    otherwise
        error('add')
end

end %function