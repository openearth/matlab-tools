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
%Wrap around <D3D_results_time> to allow for SMT input
%
%INPUT
%   -
%
%OUTPUT
%   -
%
%TODO:
%   -

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time_wrap(sim_path)

simdef.D3D.dire_sim=sim_path;
simdef=D3D_simpath(simdef);

switch simdef.D3D.structure
    case {1,2,3}
        path_map=simdef.file.map;
        ismor=D3D_is(path_map);
        fpath_nc=path_map;
        [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_nc,ismor,[1,Inf]);
    case 4
        fdir_output=fullfile(sim_path,'output');
        dire=dir(fdir_output);
        nf=numel(dire)-2-1; %already the number of the files, which start at 0
        time_r=[];
        time_mor_r=[];
        time_dnum=[];
        time_dtime=[];
        time_mor_dnum=[];
        time_mor_dtime=[];
        for kf=0:1:nf
            fdir_loc=fullfile(fdir_output,num2str(kf));
            simdef.D3D.dire_sim=fdir_loc;
            simdef=D3D_simpath(simdef);
            path_map=simdef.file.map;
            ismor=D3D_is(path_map);
            fpath_nc=path_map;
            [time_r_loc,time_mor_r_loc,time_dnum_loc,time_dtime_loc,time_mor_dnum_loc,time_mor_dtime_loc]=D3D_results_time(fpath_nc,ismor,[1,Inf]);
            
            time_r=cat(1,time_r,time_r_loc);
            time_mor_r=cat(1,time_mor_r,time_mor_r_loc);
            time_dnum=cat(1,time_dnum,time_dnum_loc);
            time_dtime=cat(1,time_dtime,time_dtime_loc);
            time_mor_dnum=cat(1,time_mor_dnum,time_mor_dnum_loc);
            time_mor_dtime=cat(1,time_mor_dtime,time_mor_dtime_loc);
            
            messageOut(NaN,sprintf('Joined time %4.2f %%',kf/nf*100));
        end


end

end %function
