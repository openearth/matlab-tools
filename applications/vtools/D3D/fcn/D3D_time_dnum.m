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

function [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=D3D_time_dnum(fpath_map,in_dtime,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim_type',1);
addOptional(parin,'tol',1);

parse(parin,varargin{:});

tim_type=parin.Results.tim_type;
tol=parin.Results.tol;

%%

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
        nt=numel(in_dtime);
        time_dnum_s=NaN(nt,1);
        time_dtime_s=NaT(nt,1);
        time_dtime_s.TimeZone='+00:00';
        time_mor_dnum_s=NaN(nt,1);
        time_mor_dtime_s=NaT(nt,1);
        time_mor_dtime_s.TimeZone='+00:00';
        sim_idx_s=NaN(nt,1);
        for kt=1:nt
            if tim_type==1
                tim_cmp=time_dnum;
            elseif tim_type==2
                tim_cmp=time_mor_dnum;
            else
                error('not sure what you want')
            end
            idx_g=absmintol(tim_cmp,in_dtime(kt),'tol',tol,'dnum',1);
            
            time_dnum_s(kt,1)=time_dnum(idx_g);
            time_dtime_s(kt,1)=time_dtime(idx_g);
            time_mor_dnum_s(kt,1)=time_mor_dnum(idx_g);
            time_mor_dtime_s(kt,1)=time_mor_dtime(idx_g);
            sim_idx_s(kt,1)=sim_idx(idx_g);
        end
        time_dnum=time_dnum_s;
        time_dtime=time_dtime_s;
        time_mor_dnum=time_mor_dnum_s;
        time_mor_dtime=time_mor_dtime_s;
        sim_idx=sim_idx_s;
    end
elseif isa(in_dtime(1),'datetime')
    time_dnum=datenum_tzone(in_dtime);
    time_dtime=in_dtime;
else
    error('ups...')
end
