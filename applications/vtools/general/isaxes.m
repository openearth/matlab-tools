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

function isax = isaxes(h)
if strcmp(get(h,'type'),'axes')
  isax = true;
else
  isax = false;
end