%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18279 $
%$Date: 2022-08-02 16:45:02 +0200 (Tue, 02 Aug 2022) $
%$Author: chavarri $
%$Id: absmintol.m 18279 2022-08-02 14:45:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absmintol.m $
%
%Interpolate centre to corners
%

function Zcor=cen2cor_2D(Xcen,Ycen,Xcor,Ycor,Zcen)

bol_nan=isnan(Xcen);
F=scatteredInterpolant(Xcen(~bol_nan),Ycen(~bol_nan),Zcen(~bol_nan));
Zcor=F(Xcor,Ycor);

end %function
