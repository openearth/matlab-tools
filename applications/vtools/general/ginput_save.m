%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19670 $
%$Date: 2024-06-13 15:26:01 +0200 (Thu, 13 Jun 2024) $
%$Author: chavarri $
%$Id: D3D_mor_su.m 19670 2024-06-13 13:26:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mor_su.m $
%
%

function xy=ginput_save(ni)

[x,y]=ginput(ni);
xy=[x,y];
fpath_save=fullfile(pwd,sprintf('xy_%s',now_chr));
save(fpath_save,'xy');

end
