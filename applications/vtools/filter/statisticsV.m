%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19773 $
%$Date: 2024-09-05 16:20:30 +0200 (Thu, 05 Sep 2024) $
%$Author: chavarri $
%$Id: plot_his_01.m 19773 2024-09-05 14:20:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_01.m $
%
%

function [verr,vbias,vstd,vrmse,corr_R,corr_P,bias_01,rmsd_01]=statisticsV(v_mea,v_sim_atmea,thr)

v_mea=reshape(v_mea,[],1);
v_sim_atmea=reshape(v_sim_atmea,[],1);

% mean square error = variance + (bias)2 => vrmse=sqrt(vstd^2+vbias^2)

verr=v_sim_atmea-v_mea;
vbias=nanmean(verr);
vstd=std(verr,'omitnan');
vrmse=rmse(v_mea,v_sim_atmea);
% if isnan(vrmse)
%     error('It cannot be NaN!') %it can be NaN if no data?
% end

%Equation (5.1) in <"1209459-000-ZKS-0028-r-Evaluatie van het OSR-model voor zoutindringing in de Rijn-Maasmonding (I).pdf">
vstd_mea=std(v_mea,'omitnan');
vstd_sim=std(v_sim_atmea,'omitnan');
vmean_sim=mean(v_sim_atmea,'omitnan');
vmean_mea=mean(v_mea,'omitnan');

aux_bias=vmean_sim-vmean_mea;
bias_01(1)=aux_bias/vstd_mea; %original
bias_01(2)=aux_bias/vmean_mea;

aux1=((v_sim_atmea-vmean_sim)-(v_mea-vmean_mea)).^2;
bol_nn=~isnan(aux1);
aux2=sum(aux1,1,'omitnan')/sum(bol_nn);
aux_rmsd=sign(vstd_sim-vstd_mea)*sqrt(aux2);
rmsd_01(1)=aux_rmsd/vstd_mea; %original
rmsd_01(2)=aux_rmsd/vmean_mea;

%filtering signal
fil_bol=v_mea>thr(1) & v_mea<thr(2);
[corr_R_m,corr_P]=corrcoef(v_mea(fil_bol),v_sim_atmea(fil_bol),'Rows','complete');

if numel(corr_R_m)>1
    corr_R=corr_R_m(2,1);
else
    corr_R=corr_R_m;
end

end %function