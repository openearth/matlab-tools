%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function [E,u,h]=fcn_energy(ws,q,crest_height)

g=9.81;
h=ws;
u=q./h;
E=(h-crest_height)+0.5.*u.^2/g;

end