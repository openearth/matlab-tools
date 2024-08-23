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
%Generate paths of single run

function [simdef,leg_str]=gdm_paths_single_run(fid_log,in_plot,ks,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'disp',1);

parse(parin,varargin{:});

do_disp=parin.Results.disp;

%% CALC

fdir_sim=in_plot.fdir_sim{ks};
if do_disp
    messageOut(fid_log,sprintf('Finding paths: %s',fdir_sim));
end
simdef=simulation_paths(fdir_sim,in_plot);
if do_disp
    messageOut(fid_log,sprintf('Simulation: %s',simdef.file.runid),1)	
end
if isfield(in_plot,'str_sim')
    leg_str=in_plot.str_sim{ks};
else
    leg_str='';
end

end %function 