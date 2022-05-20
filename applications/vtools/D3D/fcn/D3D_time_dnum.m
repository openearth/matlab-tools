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
%Read time in datenum format
%
%double: represent indices of the times to load. I.e., load the results at times [1,5,10];
%NaN = all
%Inf = last

function [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=D3D_time_dnum(fpath_map,in_dtime)

if isa(in_dtime(1),'double') 
    if isfolder(fpath_map) %SMT
        [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=D3D_results_time_wrap(fpath_map);
    else
        [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_map,0,[1,Inf]);
        sim_idx=NaN;
    end
    
    if isnan(in_dtime(1)) 
        
    elseif isinf(in_dtime(1))
        time_dnum=time_dnum(end);
        time_dtime=time_dtime(end);
        time_mor_dnum=time_mor_dnum(end);
        time_mor_dtime=time_mor_dtime(end);
        sim_idx=sim_idx(end);
    else
        time_dnum=time_dnum(in_dtime);
        time_dtime=time_dtime(in_dtime);
        time_mor_dnum=time_mor_dnum(in_dtime);
        time_mor_dtime=time_mor_dtime(in_dtime);
        sim_idx=sim_idx(in_dtime);
    end
elseif isa(in_dtime(1),'datetime')
    time_dnum=datenum_tzone(in_dtime);
    time_dtime=in_dtime;
else
    error('ups...')
end
