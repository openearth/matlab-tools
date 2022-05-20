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

function copy_and_delete(path_aux,path_file)

cstat=copyfile(path_aux,path_file);
if cstat~=true
   error('Could not copy the new boundary conditions file. Check that file %s exists.',path_aux) 
end
delete(path_aux);

end %function