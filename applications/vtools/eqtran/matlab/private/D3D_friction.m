%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19428 $
%$Date: 2024-02-10 10:41:10 +0100 (Sat, 10 Feb 2024) $
%$Author: chavarri $
%$Id: D3D_erosed.m 19428 2024-02-10 09:41:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/eqtran/matlab/fcn/D3D_erosed.m $
%
%Computation of Chezy coefficient in Delft3D

function [z0rou,chezy]=D3D_friction(jawave,z0rouk,z0cur,sag,h1,ee,vonkar)

% if (jawave > 0 .and. .not. flowWithoutWaves) then
%  z0rou = max(epsz0,z0rouk(nm))
% else ! currents only
%  z0rou = z0curk(nm)       ! currents+potentially trachy
% end if

if jawave
    z0rou=z0rouk;
else
    z0rou=z0cur;
end

chezy=sag*log(h1/ee/z0rou)/vonkar;

end %function