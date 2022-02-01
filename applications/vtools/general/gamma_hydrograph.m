%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 14 $
%$Date: 2021-08-04 13:25:20 +0200 (Wed, 04 Aug 2021) $
%$Author: chavarri $
%$Id: main_plot_all.m 14 2021-08-04 11:25:20Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/rmm_plot/main_plot_all.m $
%
%Gamma function hydrograph from USDA07 (National engineering handbook hydrology, chapter 16, hydrographs. United States Department of Agriculture, Natural Resources Conservation Service.)

function [q,qint]=gamma_hydrograph(q_b,q_p,m,t,t_p)

q=q_b+(q_p-q_b).*exp(m).*(t./t_p).^m.*exp(-m.*t./t_p);
qint=trapz(t,q);

end %function
