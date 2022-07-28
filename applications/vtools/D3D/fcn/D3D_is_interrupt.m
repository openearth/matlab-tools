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

function is_done=D3D_is_interrupt(simdef,varargin)

simdef=D3D_simpath(simdef);

switch simdef.D3D.structure
    case 1
        warning('add text of a D3D4 crash')
%         kl=search_text_ascii(simdef.file.dia,'*** Simulation finished ***',1);
    case 2
        kl=search_text_ascii(simdef.file.dia,'** INFO   : Simulation did not reach stop time',1);
end
is_done=true;
if isnan(kl)
    is_done=false;
end

end %function