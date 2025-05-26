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

%If there is a single value, we first turn in into a vector. `repmat` works for 
%doubles, cells, and datetimes.
if isscalar(val) %same value to all structure fields   
    val=repmat(val,ns,1);
end

ni=numel(val);
if ns~=ni
    error('The size of the vector is different than the size of the structure and it is not 1')
end

if iscell(val)
    if ischar(val{1})
        val=char(val);
        aux=char2cell(val);
    end
else
    aux=num2cell(val);
end

[stru.(str)]=aux{:};

end %function