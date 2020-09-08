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
%grid creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_grd_convert(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

path_grd=fullfile(dire_sim,'grd.grd');
path_enc=fullfile(dire_sim,'enc.enc');

path_out=fullfile(dire_sim,'net.nc');
path_out_net=fullfile(dire_sim,'net_net.nc');
path_out_xyz=fullfile(dire_sim,'sample.xyz');

%% dep from file

EHY_convert(path_grd,'nc','outputFile',path_out);
%actual file has the appendix _net, we rename it
movefile(path_out_net,path_out,'f')
    
%% depending on bedleveltyp
%if there is morphology, BedLevelTyp=1 and the bathymetry is read from the
%.dep file. If there is no morphology, to speed up the computation
%BedLevelTyp=3 and in this case the bathymetry is in the nc file. 

% if simdef.mor.morphology
%     EHY_convert(path_grd,'nc','outputFile',path_out);
%     %actual file has the appendix _net, we rename it
%     movefile(path_out_net,path_out,'f')
% else
%     if simdef.ini.etab0_type~=2
%         error('You have to adapt this part')
%         %I think the easiest is that you write the .dep file in strucutred
%         %form and just put the path to this file at continuation. 
%     else
%         dep=-simdef.ini.etab;
%         d3d2dflowfm_grd2net(path_grd,path_enc,dep,path_out,path_out_xyz)
%     end
% end
