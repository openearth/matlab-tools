%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Id: $
%$Revision: 16973 $
%$Date: 2020-12-17 11:20:54 +0100 (do, 17 dec 2020) $
%$Author: chavarri $
%$Id: main_get_tiles.m 16973 2020-12-17 10:20:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/GE2Mat/main_get_tiles.m $

function isax = isaxes(h)
if strcmp(get(h,'type'),'axes')
  isax = true;
else
  isax = false;
end