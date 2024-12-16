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