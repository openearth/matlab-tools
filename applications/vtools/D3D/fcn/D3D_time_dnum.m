%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 7 $
%$Date: 2022-02-24 12:09:33 +0100 (Thu, 24 Feb 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_01.m 7 2022-02-24 11:09:33Z chavarri $
%$HeadURL: file:///P:/11208075-002-ijsselmeer/07_scripts/svn/create_mat_map_sal_01.m $
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
