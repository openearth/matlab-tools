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
%get data from 1 time step in D3D, output name as in D3D

function [time_r,time_mor_r,time_dnum]=D3D_results_time(nc_map,ismor,kt)

[~,fname,ext]=fileparts(nc_map);

time_mor_r=NaN;
if strcmp(ext,'.nc') %FM
    ismap=0;
    if contains(fname,'_map')
        ismap=1;
    end

    nci=ncinfo(nc_map);
    time_r=ncread(nc_map,'time',kt(1),kt(2)); %results time vector [seconds since start date]
    if ismor && ismap %morfo time not available in history
        time_mor_r=ncread(nc_map,'morft',kt(1),kt(2)); %results time vector [seconds since start date]
    end
    idx=find_str_in_cell({nci.Variables.Name},{'time'});
    idx_units=strcmp({nci.Variables(idx).Attributes.Name},'units');
    str_time=nci.Variables(idx).Attributes(idx_units).Value;
    tok=regexp(str_time,' ','split');
    if numel(tok)>4
        t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tok{1,5});
    else
        t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone','+00:00');
    end
    switch tok{1,1}
        case 'seconds'
            time_dtime=t0_dtime+seconds(time_r);
        case 'minutes'
            time_dtime=t0_dtime+minutes(time_r);
        otherwise
            error('add')
    end
elseif strcmp(ext,'.dat') %D3D4
    NFStruct=vs_use(nc_map,'quiet');
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
end

time_dnum=datenum(time_dtime);

end %function