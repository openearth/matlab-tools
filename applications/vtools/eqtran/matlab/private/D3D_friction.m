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