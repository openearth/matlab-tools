%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17514 $
%$Date: 2021-10-04 09:15:38 +0200 (ma, 04 okt 2021) $
%$Author: chavarri $
%$Id: labels4all.m 17514 2021-10-04 07:15:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/labels4all.m $
%
    
function [lab,str_var,str_un]=D3D_which_v_2_label(which_v,un,lan)

switch which_v
    case 10
        [lab,str_var,str_un]=labels4all('umag',un,lan); 
    case 17
        [lab,str_var,str_un]=labels4all('detab',un,lan); 
    otherwise
        error('ups')
end