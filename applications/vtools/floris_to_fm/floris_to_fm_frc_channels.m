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
%Create roughness channels

function frc_channels=floris_to_fm_frc_channels

frc_channels.General.fileVersion='3.00';
frc_channels.General.fileType='roughness';

frc_channels.Global0.frictionId='Channels';
frc_channels.Global0.frictionType='Strickler';
frc_channels.Global0.frictionValue=33;

end %function