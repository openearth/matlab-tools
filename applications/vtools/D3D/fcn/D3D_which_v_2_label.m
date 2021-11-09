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
    
function [lab,str_var,str_un,str_diff]=D3D_which_v_2_label(which_v,un,lan)

switch which_v
    case 1
        [lab,str_var,str_un,str_diff]=labels4all('etab',un,lan); 
    case 2
        [lab,str_var,str_un,str_diff]=labels4all('h',un,lan); 
    case 10
        [lab,str_var,str_un,str_diff]=labels4all('umag',un,lan); 
    case 12
        [lab,str_var,str_un,str_diff]=labels4all('etaw',un,lan); 
    case 17
        [lab,str_var,str_un,str_diff]=labels4all('detab',un,lan); 
    case 43
        [lab,str_var,str_un,str_diff]=labels4all('vicouv',un,lan); 
    otherwise
        error('ups')
end