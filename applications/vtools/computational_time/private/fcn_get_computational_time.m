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

function timeloop=fcn_get_computational_time(input_m)

nsim=numel(input_m);
timeloop=NaT(nsim,1)-NaT;
for ksim=1:nsim
    [tim_dur,t0,tf,processes,tim_sim,sim_efficiency,num_dt,timervals,timeloop(ksim)]=D3D_computation_time(input_m(ksim).D3D__dire_sim);
    if processes~=input_m(ksim).D3D__nodes*input_m(ksim).D3D__tasks_per_node
        error('ups...')
    end
    fprintf('%4.2f \n',ksim/nsim*100)
end %ksim

end %function