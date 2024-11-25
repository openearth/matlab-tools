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
function D3D_grd_DHL(simdef)

%% RENAME

file=simdef.file.grd;

grd4=D3D_grd_DHL_coordinates(simdef);

%% WRITE

enc =[];
try
   ok=wlgrid('write',file,grd4.X,grd4.Y,enc);
%    disp(['Gridfile written to ',file]) 
catch
   error('Function wlgrid could not be accessed')
end

end %function