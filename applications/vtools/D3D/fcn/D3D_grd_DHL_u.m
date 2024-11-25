%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17190 $
%$Date: 2021-04-15 10:24:15 +0200 (do, 15 apr 2021) $
%$Author: chavarri $
%$Id: D3D_grd_DHL.m 17190 2021-04-15 08:24:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_DHL.m $
%
function D3D_grd_DHL_u(simdef)

%% RENAME

file=simdef.file.grd;

grd4=D3D_grd_DHL_coordinates(simdef);

%% WRITE

write_structured_NC_grid(file,grd4.X,grd4.Y);

end %function