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

function create_reference_simulation_computational_time(fpath_runs)

simdef=input_D3D;

simdef.D3D.dire_sim=fullfile(fpath_runs,'r000');
simdef.runid.name='r000';

D3D_create_simulation(simdef,'overwrite',2);

end %function