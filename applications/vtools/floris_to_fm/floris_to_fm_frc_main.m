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

function frc_main=floris_to_fm_frc_main

frc_main.General.fileVersion='3.00';
frc_main.General.fileType='roughness';

frc_main.Global0.frictionId='Main';
frc_main.Global0.frictionType='Chezy';
frc_main.Global0.frictionValue=45;

end %function