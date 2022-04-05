%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17593 $
%$Date: 2021-11-16 10:28:04 +0100 (Tue, 16 Nov 2021) $
%$Author: chavarri $
%$Id: D3D_create_variation_simulations.m 17593 2021-11-16 09:28:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_create_variation_simulations.m $
%

function is_done=D3D_is_done(simdef,varargin)

simdef=D3D_simpath(simdef);

switch simdef.D3D.structure
    case 1
        kl=search_text_ascii(simdef.file.dia,'*** Simulation finished ***',1);
    case 2
        kl=search_text_ascii(simdef.file.dia,'** INFO   : Computation finished at:',1);
end
is_done=true;
if isnan(kl)
    is_done=false;
end

end %function