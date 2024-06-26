% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function simdef=adapt_input_01(simdef,input_m_s)

simdef.grd.L=10*input_m_s.ini__noise_Lb;

end %function