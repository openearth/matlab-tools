%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19687 $
%$Date: 2024-06-24 17:30:38 +0200 (Mon, 24 Jun 2024) $
%$Author: chavarri $
%$Id: twoD_study.m 19687 2024-06-24 15:30:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%

function gdm_adhoc_infinitesimal_perturbation_propagation(fid_log,in_plot_fig,simdef)

%% loop on simulations

%path to mat file with results from all simulations
%if exists file, skip loop
%load simdef
%convert simdef to ECT_input
%compute analytical celerity and wave dampening
%load ls section before and after
%compute observed celerity and wave dampening
%plot waves: initial, filtered, initial guess
%save to mat

%% plot

%scatter comparing observed against predicted celerity
%scatter comparing observed against predicted wave dampening
%scatter comparing lambda-beta-celerity for analytical (left) and observed (right) 
%scatter comparing lambda-beta-dampening for analytical (left) and observed (right)

end %function