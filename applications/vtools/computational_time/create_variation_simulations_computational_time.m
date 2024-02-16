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

function create_variation_simulations_computational_time(path_folder_sims,path_input_folder,path_input_folder_refmdf,path_software)

%% sims
path_ref=fullfile(path_folder_sims,sprintf('r%03d',0));
fcn_adapt=@(X)input_variation(X);

%% CALL

input_m=D3D_input_variation(path_folder_sims,path_input_folder,path_input_folder_refmdf,fcn_adapt);
D3D_create_variation_simulations(path_ref,input_m,'software',path_software);

end %function