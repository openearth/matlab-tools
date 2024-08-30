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