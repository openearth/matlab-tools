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

function is_done=D3D_is_done(simdef,varargin)

simdef=D3D_simpath(simdef);

switch simdef.D3D.structure
    case 1
        kl=search_text_ascii(simdef.file.dia,'*** Simulation finished ***',1);
    case 2
        kl=search_text_ascii(simdef.file.dia,'** INFO   : Computation finished at:',1);
end
is_done=true;
if numel(kl)>1
    messageOut(NaN,sprintf('Simulation run more than once: %s',simdef.D3D.dire_sim));
    kl=kl(end);
end
if isempty(kl) || isnan(kl)
    is_done=false;
end

end %function