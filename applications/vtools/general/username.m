%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19670 $
%$Date: 2024-06-13 15:26:01 +0200 (Thu, 13 Jun 2024) $
%$Author: chavarri $
%$Id: D3D_grd_rect.m 19670 2024-06-13 13:26:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_rect.m $
%
%

function uname=username()
uname=getenv('USERNAME');
if isempty(uname)
    uname = getenv('USER'); % Fallback for Linux/macOS
end
end