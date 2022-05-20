%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Gamma function hydrograph from USDA07 (National engineering handbook hydrology, chapter 16, hydrographs. United States Department of Agriculture, Natural Resources Conservation Service.)

function [q,qint]=gamma_hydrograph(q_b,q_p,m,t,t_p)

q=q_b+(q_p-q_b).*exp(m).*(t./t_p).^m.*exp(-m.*t./t_p);
qint=trapz(t,q);

end %function
