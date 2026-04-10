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
F=scatteredInterpolant(reshape(Xcen(~bol_nan),[],1),reshape(Ycen(~bol_nan),[],1),reshape(Zcen(~bol_nan),[],1),'nearest','nearest');
Zcor=F(Xcor,Ycor);

end %function
