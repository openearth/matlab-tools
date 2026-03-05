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
%

function val_cum=gdm_compute_cumulative(data_xvt,statis,tim_dtime_plot)

[nx,nsim,nt,nD]=size(data_xvt.(statis));
diff_tim=seconds(diff(tim_dtime_plot));
val_tim=data_xvt.(statis)(:,:,1:end-1,:).*repmat(reshape(diff_tim,1,1,[]),nx,nsim,1,nD); %we do not use the last value. Block approach with variables 1:end-1 with time 1:end
val_cum=cumsum(cat(3,zeros(nx,nsim,1,nD),val_tim),3);

end