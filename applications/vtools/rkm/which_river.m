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

function river=which_river(ident_pol_str)

if any(contains(ident_pol_str,{'BR','IJ','LE','NI','NR','PK','RH','WL','WA'}))
    river=1;
elseif any(contains(ident_pol_str,{'MA'}))
    river=2;
else
    error('A cell array is found with information about the name of each polygon. This is expected to contain the information of the branch and the river kilometer. However, the branch is not known.')
end

end %function