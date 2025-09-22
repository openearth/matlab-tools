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

function frc_main=floris_to_fm_frc_main

frc_main.General.fileVersion='3.00';
frc_main.General.fileType='roughness';

frc_main.Global0.frictionId='Main';
frc_main.Global0.frictionType='Chezy';
frc_main.Global0.frictionValue=45;

end %function