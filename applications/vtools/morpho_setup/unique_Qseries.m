%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19849 $
%$Date: 2024-10-24 17:40:56 +0200 (Thu, 24 Oct 2024) $
%$Author: chavarri $
%$Id: D3D_sediment_transport_offline.m 19849 2024-10-24 15:40:56Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_sediment_transport_offline.m $
%

function Qseries_u=unique_Qseries(Qseries)

tim_dt=Qseries(:,2);
Q_disc=Qseries(:,1);

[Q_u,~]=unique(Q_disc);
nu=numel(Q_u);
tim_u=NaN(size(Q_u));
for ku=1:nu
    bol_u=Q_disc==Q_u(ku);
    tim_u(ku)=sum(tim_dt(bol_u));
end %ku

Qseries_u=[Q_u,tim_u];

end 