%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18819 $
%$Date: 2023-03-13 16:40:14 +0100 (Mon, 13 Mar 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18819 2023-03-13 15:40:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%

function str=conccellstr(c)

sep=',';

nc=numel(c);

str='';
for kc=1:nc
    str=strcat(str,c{kc},sep);
end

str(end)='';

end %function