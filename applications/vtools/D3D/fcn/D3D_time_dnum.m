%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%NaN = all
%Inf = last

function [time_dnum,time_dtime]=D3D_time_dnum(fpath_map,in_dtime)

if isa(in_dtime(1),'double') 
    [~,~,time_dnum,time_dtime,~,~]=D3D_results_time(fpath_map,0,[1,Inf]);
    if isnan(in_dtime(1)) 
        
    elseif isinf(in_dtime(1))
        time_dnum=time_dnum(end);
        time_dtime=time_dtime(end);
    else
        time_dnum=time_dnum(in_dtime);
        time_dtime=time_dtime(in_dtime);
    end
elseif isa(in_dtime(1),'datetime')
    time_dnum=datenum_tzone(in_dtime);
    time_dtime=in_dtime;
else
    error('ups...')
end
