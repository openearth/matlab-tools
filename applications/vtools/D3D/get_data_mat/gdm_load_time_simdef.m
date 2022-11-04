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
%

function [nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'results_type','map'); 

parse(parin,varargin{:});

results_type=parin.Results.results_type;

if isfield(simdef,'file') && isfield(simdef.file,'mat') && isfield(simdef.file.mat,'dir')
    fdir_mat=simdef.file.mat.dir;
else
    fdir_mat='';
end

%% CALC

switch simdef.D3D.structure
    case {4,5}
        fpath_pass=simdef.D3D.dire_sim;
    otherwise
        switch results_type
            case 'map'
                fpath_pass=simdef.file.map;
            case 'his'
                fpath_pass=simdef.file.his;
        end
end

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_pass,fdir_mat,'results_type',results_type);

end %function
