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
%if it is a string, it changes comma by dot and makes it a number
%in case it is a cell array do:
%
%matrix=cellfun(@(x)undutchify(x),cell_array);

function meaningfull_value=undutchify(nonsense_number)

if ischar(nonsense_number)
    meaningfull_value=str2double(strrep(nonsense_number,',','.'));
else
    meaningfull_value=nonsense_number;
end

end %function