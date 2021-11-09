%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                      RIVV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17208 $
%$Date: 2021-04-23 08:52:13 +0200 (Fri, 23 Apr 2021) $
%$Author: chavarri $
%$Id: fig_qt.m 17208 2021-04-23 06:52:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/q_analysis/fig_qt.m $
%

function [q_cen,q_mean,q_std,yupper,ylower,q_env]=qh_prop(qh_2env,q_edge)

%mean discharge for bins
q_cen=cor2cen(q_edge);
nb=numel(q_cen);  

q_mean=NaN(nb,1); 
q_std=NaN(nb,1); 
yupper=NaN(nb,1);
ylower=NaN(nb,1);

%% loop on bins
for kb=1:nb
    bol_bin=qh_2env(:,1)>q_edge(kb) & qh_2env(:,1)<q_edge(kb+1);
    etaw_bin=qh_2env(bol_bin,2);
    q_mean(kb)=mean(etaw_bin,'omitnan');
    q_std(kb)=std(etaw_bin,'omitnan');

    if ~isempty(etaw_bin)
        yupper(kb)=max(etaw_bin);
        ylower(kb)=min(etaw_bin);
    end
    
    %disp
    fprintf('unique q %4.2f %%\n',kb/nb*100)
end

bol_nan=isnan(yupper);
yupper(bol_nan)=[];
ylower(bol_nan)=[];

q_env=q_cen';
q_env(bol_nan)=[];

%%
% figure
% hold on
% scatter(qh_2env(:,1),qh_2env(:,2))
% plot(q_cen,q_mean,'*-')
% plot(q_env,yupper,'*-')
% plot(q_env,ylower,'*-')

end %function
