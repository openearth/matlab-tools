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
%Convert a cell array with char to a char array of given size.

function char_array=cell2char(cell_array,target_len)

n=numel(cell_array);
char_array=repmat(' ',n,target_len);  %preallocated with spaces

for i=1:n
    str=cell_array{i};
    len=min(length(str),target_len);
    char_array(i,1:len)=str(1:len);
end

end %function