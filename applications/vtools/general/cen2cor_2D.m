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
%Interpolate centre to corners
%

function Zcor=cen2cor_2D(Xcen,Ycen,Xcor,Ycor,Zcen)

bol_nan=isnan(Xcen);
F=scatteredInterpolant(Xcen(~bol_nan),Ycen(~bol_nan),Zcen(~bol_nan));
Zcor=F(Xcor,Ycor);

end %function
