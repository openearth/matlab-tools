%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18361 $
%$Date: 2022-09-14 07:43:17 +0200 (Wed, 14 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18361 2022-09-14 05:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Generate paths of single run

function [simdef,leg_str]=gdm_paths_single_run(fid_log,in_plot,ks,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'disp',1);

parse(parin,varargin{:});

do_disp=parin.Results.disp;

%% CALC

fdir_sim=in_plot.fdir_sim{ks};
simdef=simulation_paths(fdir_sim,in_plot);
if do_disp
    messageOut(fid_log,sprintf('Simulation: %s',simdef.file.runid))	
end
if isfield(in_plot,'str_sim')
    leg_str=in_plot.str_sim{ks};
else
    leg_str='';
end

end %function 