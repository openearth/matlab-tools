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

function stru=struct_assign_val(stru,str,val)

ns=numel(stru);
ni=numel(val);
if ni==1 %same value to all structure fields        
    vec=val.*ones(ns,1);
elseif ns==ni
    vec=val;
else
    error('The size of the vector is different than the size of the structure and it is not 1')
end

aux=num2cell(vec);
[stru.(str)]=aux{:};

end %function