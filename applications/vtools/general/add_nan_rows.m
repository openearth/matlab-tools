%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17798 $
%$Date: 2022-02-28 12:05:51 +0100 (ma, 28 feb 2022) $
%$Author: chavarri $
%$Id: interp_line_double.m 17798 2022-02-28 11:05:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/interp_line_double.m $
%
%Add a row of NaN after every row in a matrix

function cn=add_nan_rows(c)

[nr,nc]=size(c);
cn=[c,NaN(nr,nc)]';
cn=reshape(cn,nc,nr*2)';

end
