%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 13:43:41 +0200 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_is_done.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_is_done.m $
%

function is_done=D3D_is_interrupt(simdef,varargin)

simdef=D3D_simpath(simdef);

switch simdef.D3D.structure
    case 1
        error('do')
        kl=search_text_ascii(simdef.file.dia,'*** Simulation finished ***',1);
    case 2
        kl=search_text_ascii(simdef.file.dia,'** INFO   : Simulation did not reach stop time',1);
end
is_done=true;
if isnan(kl)
    is_done=false;
end

end %function