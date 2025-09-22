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

function frc_channels=floris_to_fm_frc_sewer

frc_channels.General.fileVersion='3.00';
frc_channels.General.fileType='roughness';

frc_channels.Global0.frictionId='Sewer';
frc_channels.Global0.frictionType='WhiteColebrook';
frc_channels.Global0.frictionValue=0.2;

end %function