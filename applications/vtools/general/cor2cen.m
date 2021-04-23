%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16608 $
%$Date: 2020-09-30 10:28:54 +0200 (Wed, 30 Sep 2020) $
%$Author: chavarri $
%$Id: cen2cor.m 16608 2020-09-30 08:28:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/cen2cor.m $
%
%corners to centers in a vector

function cen=cor2cen(cor)

dx=diff(cor);
cen=cor(1:end-1)+dx/2;

end %function