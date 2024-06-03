%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 07:25:35 +0200 (ma, 17 okt 2022) $
%$Author: chavarri $
%$Id: struct_assign_val.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/struct_assign_val.m $
%
%Compute x and y components of a magnitude and direction in degrees. 

function [vx,vy]=north_deg2xy(x,y,dir)

%% PARSE

%% CALC

error('use `magdir2uv`')

% rad=(dir-90)*2*pi/360;
% vx=mag.*cos(rad);
% vy=magdir2uv.*sin(rad);

end %function