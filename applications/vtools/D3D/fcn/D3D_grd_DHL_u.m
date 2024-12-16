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
function D3D_grd_DHL_u(simdef)

%% RENAME

file=simdef.file.grd;

grd4=D3D_grd_DHL_coordinates(simdef);

%% WRITE

write_structured_NC_grid(file,grd4.X,grd4.Y);

end %function