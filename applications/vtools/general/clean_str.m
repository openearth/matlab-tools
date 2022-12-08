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