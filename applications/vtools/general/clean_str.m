%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18532 $
%$Date: 2022-11-09 12:46:09 +0100 (Wed, 09 Nov 2022) $
%$Author: ottevan $
%$Id: plot_individual_runs.m 18532 2022-11-09 11:46:09Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_individual_runs.m $
%
%Plot results of a single run
    
function str=clean_str(str)

str=strrep(str,' ','_');
str=strrep(str,'%','_'); 
str=strrep(str,'+','_'); 
str=strrep(str,'-','_'); 
str=strrep(str,'.','_'); 
str=strrep(str,'&','_'); 
str=strrep(str,'(','_'); 
str=strrep(str,')','_'); 

end %function