%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17737 $
%$Date: 2022-02-07 09:06:58 +0100 (Mon, 07 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_crosssectionlocation.m 17737 2022-02-07 08:06:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_crosssectionlocation.m $
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