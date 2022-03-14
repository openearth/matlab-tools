%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 5 $
%$Date: 2022-02-18 17:28:47 +0100 (Fri, 18 Feb 2022) $
%$Author: chavarri $
%$Id: input_D3D_bars.m 5 2022-02-18 16:28:47Z chavarri $
%$HeadURL: file:///P:/11206884-007-delft3d-fm/04-sensitivity-grid-type-and-resolution/scripts/svn/input_D3D_bars.m $
%
%Check if monotonically increasing vector

function tf=mono_increase(y_int)
tf=all(diff(y_int)>0);
end