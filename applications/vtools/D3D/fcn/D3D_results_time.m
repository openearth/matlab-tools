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
%Read time from a netcdf-file
%
%[time_r,time_mor_r,time_dnum,time_dtime]=D3D_results_time(nc_map,ismor,kt)
%
%INPUT:
%   -fpath_nc: path to the netcdf-file [string]
%   -ismor: whether the simulation morphodynamic development: 0=NO; 1=YES [double]
%   -kt: time to read as [start,counter] [double]
%       if NaN it reads the last one

function [time_r,time_mor_r,time_dnum,time_dtime]=D3D_results_time(fpath_nc,ismor,kt)

%% calc
[~,fname,ext]=fileparts(fpath_nc);

time_mor_r=NaN;
if strcmp(ext,'.nc') %FM
    
    %take last
    if isnan(kt)
        nt=NC_nt(fpath_nc);
        kt=[nt,1];
    end
    
    ismap=0;
    if contains(fname,'_map')
        ismap=1;
    end
    [time_dtime,~,time_r]=NC_read_time(fpath_nc,kt);
    if ismor && ismap %morfo time not available in history
        time_mor_r=ncread(fpath_nc,'morft',kt(1),kt(2)); %results time vector [seconds since start date]
    end
elseif strcmp(ext,'.dat') %D3D4
    NFStruct=vs_use(fpath_nc,'quiet');
    ITMAPC=vs_let(NFStruct,'map-info-series','ITMAPC','quiet'); %results time vector
    ITDATE=vs_let(NFStruct,'map-const','ITDATE','quiet');
    TZONE=vs_let(NFStruct,'map-const','TZONE','quiet');
    TUNIT=vs_let(NFStruct,'map-const','TUNIT','quiet'); %dt unit
    DT=vs_let(NFStruct,'map-const','DT','quiet'); %dt
    time_r=ITMAPC*DT*TUNIT; %results time vector [s]
    if ITDATE(2)~=0
        error('modify this!')
    end
    if TZONE~=0
        error('solve this')
    end
    t0_str=sprintf('%d',ITDATE(1));
    t0_dtime=datetime(t0_str,'InputFormat','yyyyMMdd');
    if ismor==1
        MORFT=vs_let(NFStruct,'map-infsed-serie','MORFT','quiet'); %morphological time (days since start)
        time_mor_r=MORFT*24*3600; %seconds
    end
    time_dtime=t0_dtime+seconds(time_r);
    
%     %we output only the one we request. It would be better to only read the one we want...
%     time_r=time_r(kt(1));
%     time_dtime=time_dtime(kt(1));
end

time_dnum=datenum(time_dtime);

end %function