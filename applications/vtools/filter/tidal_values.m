%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 2 $
%$Date: 2021-05-21 09:51:39 +0200 (Fri, 21 May 2021) $
%$Author: chavarri $
%$Id: max_etaw_min_sal.m 2 2021-05-21 07:51:39Z chavarri $
%$HeadURL: file:///P:/11205272_waterverd_verzilting_2020/023_RMM2021/04_data_rework/04_scripts/svn/max_etaw_min_sal.m $
%


function [tim_etaw_max,etaw_max,tim_sal_min,sal_min]=max_etaw_min_sal(etaw,tim_etaw,sal,tim_sal,T,shift_hvh_etaw)

%preallocate
npre=1000;
etaw_max=NaN(npre,1);
tim_etaw_max=NaT(npre,1);
tim_etaw_max.TimeZone='+01:00';
sal_min=NaN(npre,1);
tim_sal_min=NaT(npre,1);
tim_sal_min.TimeZone='+01:00';

%initialize
t0_etaw=tim_etaw(1);
% idx_etaw=1:1:numel(etaw);
% idx_sal=1:1:numel(sal);
kc=1;

%first is different because time series may not start at a maximum

%maximum water level
bol_etaw=tim_etaw>t0_etaw & tim_etaw<t0_etaw+T; %different than in loop
tim_etaw_loc=tim_etaw(bol_etaw);
[etaw_max(kc),idx_loc_max]=max(etaw(bol_etaw));
tim_etaw_max(kc)=tim_etaw_loc(idx_loc_max);

%minimum salinity
bol_sal=tim_sal>tim_etaw_max(kc)+T/4+shift_hvh_etaw & tim_sal<tim_etaw_max(kc)+3/4*T+shift_hvh_etaw; 
tim_sal_loc=tim_sal(bol_sal);
[sal_min(kc),idx_loc_min]= min(sal(bol_sal));
tim_sal_min(kc)=tim_sal_loc(idx_loc_min);

%update
t0_etaw=tim_etaw_max(kc); %t0 is a maximum 
kc=kc+1;

while t0_etaw+2*T<tim_etaw(end)
    
    %maximum water level
    bol_etaw=tim_etaw>t0_etaw+3/4*T & tim_etaw<t0_etaw+3/2*T;
    tim_etaw_loc=tim_etaw(bol_etaw);
    [etaw_max(kc),idx_loc_max]=max(etaw(bol_etaw));
    tim_etaw_max(kc)=tim_etaw_loc(idx_loc_max);

    %minimum salinity
    bol_sal=tim_sal>tim_etaw_max(kc)+T/4+shift_hvh_etaw & tim_sal<tim_etaw_max(kc)+3/4*T+shift_hvh_etaw;
    tim_sal_loc=tim_sal(bol_sal);
    [sal_min(kc),idx_loc_min]= min(sal(bol_sal));
    tim_sal_min(kc)=tim_sal_loc(idx_loc_min);
    
    %preallocate
    if kc==numel(tim_etaw_max)
        tim_prea=NaT(npre,1);
        tim_prea.TimeZone='+01:00';

        tim_etaw_max=cat(1,tim_etaw_max,tim_prea);
        etaw_max=cat(1,etaw_max,NaN(npre,1));
        tim_sal_min=cat(1,tim_sal_min,tim_prea);
        sal_min=cat(1,sal_min,NaN(npre,1));
    end
    
    %display
    pdone=(tim_etaw_max(kc)-tim_etaw(1))/(tim_etaw(end)-tim_etaw(1)); 
    fprintf('done %4.2f %% \n',pdone*100)
    
    %update
    t0_etaw=t0_etaw+T;
    kc=kc+1;
    
end

%cut
tim_etaw_max=tim_etaw_max(1:kc-1);
etaw_max=etaw_max(1:kc-1);
tim_sal_min=tim_sal_min(1:kc-1);
sal_min=sal_min(1:kc-1);
