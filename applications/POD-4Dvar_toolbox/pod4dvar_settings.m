function [] = pod4dvar_toolbox()
%START Add mc_toolbox wl_toolbox and mos2_tools to search path.
%   This routine add the path of all toolboxes necesary to the current
%   MATLAB search path
%

%        Date: 05.06.2009
%      Author: I. Garcia Triana
%--------------------------------------------------------------------------

pod_4dvar_toolbox = cd;
addpath(genpath(pod_4dvar_toolbox),'-end')
disp([char(10),'Toolbox ready to be used.'])

end