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
        rkm=[67,79];
    case {'roermond-belfeld','rb'}
        rkm=[79,101];
    case {'belfeld-sambeek','bs'}
        rkm=[101,148];
    case {'sambeek-grave','sg'}
        rkm=[145,175];
    case {'grave-lith','gl'}
        rkm=[175,202];
    case {'lith-keizersveer','lk'}
        rkm=[200,249];
    otherwise
        error('No known branch %s',tag);
end %switch

end %function