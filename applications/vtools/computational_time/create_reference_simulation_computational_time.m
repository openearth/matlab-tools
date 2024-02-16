%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18952 $
%$Date: 2023-05-22 16:55:45 +0200 (Mon, 22 May 2023) $
%$Author: chavarri $
%$Id: figure_layout.m 18952 2023-05-22 14:55:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

function create_reference_simulation_computational_time(fpath_runs)

simdef=input_D3D;

simdef.D3D.dire_sim=fullfile(fpath_runs,'r000');
simdef.runid.name='r000';

D3D_create_simulation(simdef,'overwrite',2);

end %function