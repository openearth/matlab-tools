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

function [qh_cen,qh_mean,qh_std,yupper,ylower,q_env,qh_sep]=qh_prop_all(qh,tim_constr,q_edge)

station_names=fieldnames(qh);
ns=numel(station_names);

if isnat(tim_constr)
    tim_constr_v=[datetime(1,1,1,'timezone','+00:00'),datetime(5000,1,1,'timezone','+00:00')]; %maybe better to use maxium and minimum of time series
else
    tim_constr_v=[datetime(1,1,1,'timezone','+00:00'),tim_constr,datetime(5000,1,1,'timezone','+00:00')]; %maybe better to use maxium and minimum of time series
end
np=numel(tim_constr_v)-1;

qh_cen=cell(ns,np);
qh_mean=cell(ns,np);
qh_std=cell(ns,np);
yupper=cell(ns,np);
ylower=cell(ns,np);
q_env=cell(ns,np);
qh_sep=cell(ns,np);

for ks=1:ns
    
    qh_loc=qh.(station_names{ks});

    tim=qh_loc.tim;
    Q=qh_loc.Q;
    H=qh_loc.H;

    nm=numel(Q);
    bol=false(nm,np);

    for kp=1:np
        bol(:,kp)=tim>tim_constr_v(kp) & tim<tim_constr_v(kp+1);
    end
    
    for kp=1:np
        qh_sep{ks,kp}=[Q(bol(:,kp)),H(bol(:,kp))];
        [qh_cen{ks,kp},qh_mean{ks,kp},qh_std{ks,kp},yupper{ks,kp},ylower{ks,kp},q_env{ks,kp}]=qh_prop(qh_sep{ks,kp},q_edge);
    end %nt

end %ks
