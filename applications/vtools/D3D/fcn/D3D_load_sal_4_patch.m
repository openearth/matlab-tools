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

%E.G.:
%
% path_his=fpath_his{kh};
% stations={'an thuan'};
% [time_r,time_mor_r,time_dnum,time_dtime1,time_mor_dnum,time_mor_dtime]=D3D_results_time(path_his,1,[1,1]);
% [time_r,time_mor_r,time_dnum,time_dtime2,time_mor_dnum,time_mor_dtime]=D3D_results_time(path_his,1,NaN);
% t0=datenum(time_dtime1);
% tend=datenum(time_dtime1+days(7));
% [his_sal,his_zint,nt,ns,nl]=D3D_load_sal_4_patch(path_his,stations,t0,tend);
% D3D_plot_patch(his_sal,his_zint,stations,1,pwd);

function [his_sal,his_zint,nt,ns,nl]=D3D_load_sal_4_patch(path_his,stations,t0,tend)

messageOut(NaN,'loading salinity')
his_sal=EHY_getmodeldata(path_his,stations,'dfm','varName','sal','layer','0','t0',t0,'tend',tend);
messageOut(NaN,'loading cell interface')
his_zint=EHY_getmodeldata(path_his,stations,'dfm','varName','Zcen_int','layer','0','t0',t0,'tend',tend); %interfaces are wrong! don't use them!
 
[nt,ns,nl]=size(his_sal.val);

end