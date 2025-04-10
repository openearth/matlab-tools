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
%       NaN     = last 
%       [1,Inf] = all 

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_nc,ismor,kt)

%% PARSE

if isscalar(kt)
    if ~isnan(kt)
        error('If only one input, it must be NaN')
    end
else
    if numel(kt)~=2
        error('The size must be 2.')
    end
end

%% calc
[~,fname,ext]=fileparts(fpath_nc);
ext=deblank(ext);

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
        [time_mor_dtime,~,time_mor_r]=NC_read_time(fpath_nc,kt,'type','morpho'); %results time vector [seconds since start date]
    else
        time_mor_dtime=NaT(size(time_dtime));
        time_mor_r=NaN(size(time_dtime));
    end
elseif strcmp(ext,'.dat') %D3D4
    ismap=1;
    str_get='map';
    if contains(fname,'trih')
        ismap=0;
        str_get='his';
    end
    NFStruct=vs_use(fpath_nc,'quiet');
    ITMAPC=vs_let(NFStruct,sprintf('%s-info-series',str_get),sprintf('IT%sC',upper(str_get)),'quiet'); %results time vector
    ITDATE=vs_let(NFStruct,sprintf('%s-const',str_get),'ITDATE','quiet');
    TZONE=vs_let(NFStruct,sprintf('%s-const',str_get),'TZONE','quiet');
    TUNIT=vs_let(NFStruct,sprintf('%s-const',str_get),'TUNIT','quiet'); %dt unit
    DT=vs_let(NFStruct,sprintf('%s-const',str_get),'DT','quiet'); %dt
    time_r=ITMAPC*DT*TUNIT; %results time vector [s]

    if isnan(kt) %we have already checked it is of size 1
        time_r=time_r(end);
    else
        %replace inf by last time
        bol_inf=isinf(kt);
        kt(bol_inf)=numel(time_r);

        time_r=time_r(kt(1):kt(1)+kt(2)-1);
    end

    if ITDATE(2)~=0
        error('modify this!')
    end
    if sign(TZONE)<0
        str_sign='-';
    else
        str_sign='+';
    end
    tzone_h=floor(TZONE);
    tzone_m=(TZONE-tzone_h).*60;
    str_tz=sprintf('%s%02d:%02d',str_sign,tzone_h,tzone_m);
    t0_str=sprintf('%d',ITDATE(1));
    t0_dtime=datetime(t0_str,'InputFormat','yyyyMMdd','TimeZone',str_tz);
    if ismor==1
        MORFT=vs_let(NFStruct,sprintf('%s-infsed-serie',str_get),'MORFT','quiet'); %morphological time (days since start)
        time_mor_r=MORFT*24*3600; %seconds
    else
        time_mor_r=NaN(size(time_r));
    end
    time_dtime=t0_dtime+seconds(time_r);
    time_mor_dtime=t0_dtime+seconds(time_mor_r);
%     %we output only the one we request. It would be better to only read the one we want...
%     time_r=time_r(kt(1));
%     time_dtime=time_dtime(kt(1));
end

time_dnum=datenum(time_dtime);
time_mor_dnum=datenum(time_mor_dtime);

end %function