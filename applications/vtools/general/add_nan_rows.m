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
%Add a row of NaN after every row in a matrix

function cn=add_nan_rows(c)

[nr,nc]=size(c);
cn=[c,NaN(nr,nc)]';
cn=reshape(cn,nc,nr*2)';

end
