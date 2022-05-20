%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Id$
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$

function isfig = isfigure(h)
if strcmp(get(h,'type'),'figure')
  isfig = true;
else
  isfig = false;
end