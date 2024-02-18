%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19243 $
%$Date: 2023-11-20 11:49:45 +0100 (Mon, 20 Nov 2023) $
%$Author: chavarri $
%$Id: branch_rijntakken.m 19243 2023-11-20 10:49:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/branch_rijntakken.m $
%
%

function rkm=rkm_limits(tag)

switch lower(tag)
    case {'linne-roermond','lr'}
        rkm=[67,84];
    otherwise
        error('No known branch %s',tag);
end %switch

end %function