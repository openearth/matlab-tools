%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19540 $
%$Date: 2024-04-11 16:54:42 +0200 (Thu, 11 Apr 2024) $
%$Author: chavarri $
%$Id: get_pol_along_line.m 19540 2024-04-11 14:54:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/private/get_pol_along_line.m $
%

function [br_mod_str,br_mod_num]=branch_str_num(rkm_mod,br,varargin)

switch which_river(br)
    case 1
        [br_mod_str,br_mod_num]=branch_rijntakken(rkm_mod,br,varargin{:}); %branch name to modify (e.g., BO) for a given rkm and river branch (e.g. WA). 
    case 2
        [br_mod_str,br_mod_num]=branch_maas(rkm_mod); %branch name to modify (e.g., BO) for a given rkm and river branch (e.g. WA). 
    otherwise
        %error is deal in `which_river`.
end

end %function