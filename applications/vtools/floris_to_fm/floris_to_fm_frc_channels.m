%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20303 $
%$Date: 2025-08-28 11:32:58 +0200 (Thu, 28 Aug 2025) $
%$Author: chavarri $
%$Id: floris_to_fm_read_floin.m 20303 2025-08-28 09:32:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/floris_to_fm/floris_to_fm_read_floin.m $
%
%Create roughness channels

function frc_channels=floris_to_fm_frc_channels

frc_channels.General.fileVersion='3.00';
frc_channels.General.fileType='roughness';

frc_channels.Global0.frictionId='Channels';
frc_channels.Global0.frictionType='Strickler';
frc_channels.Global0.frictionValue=33;

end %function