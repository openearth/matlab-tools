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
%Create mdu of FLORIS simulation

function [mdu,file,D3D]=floris_to_fm_mdu(mdu,file,fdir_out,time_unit,fname_structures,fname_extn,fname_csl,fname_csd,fname_FrictFile_Channels,fname_FrictFile_Main,fname_FrictFile_Sewer,fname_ini)

%% INPUT

time_f=time_factor('seconds',time_unit);

Dt=3600; %it is always in seconds in mdu file

simdef.D3D.dire_sim=fdir_out;
simdef.D3D.structure=2;

% simdef.runid.name='FlowFM';
simdef.file.mdfid='FlowFM';

simdef.mdf=mdu;

switch time_unit
    case 'seconds'
        time_unit_w='S';
    case 'minutes'
        time_unit_w='M';
    case 'hours'
        time_unit_w='H';
    case 'days'
        time_unit_w='D';
    otherwise
        error('do')
end
simdef.mdf.Tunit=time_unit_w;
% simdef.mdf.Tunit='S';
simdef.mdf.Flmap_dt=Dt;
simdef.mdf.Flhis_dt=Dt;
simdef.file.obs='';
Flmap_dt_Tunit=Dt*time_f;
simdef.mdf.nparts_res=simdef.mdf.Tstop/Flmap_dt_Tunit;
simdef.mdf.Dt=Dt;
simdef.mdf.StructureFile=fname_structures;
simdef.mdf.CrossDefFile=fname_csd;
simdef.mdf.CrossLocFile=fname_csl;
simdef.mdf.FrictFile=sprintf('%s;%s;%s',fname_FrictFile_Channels,fname_FrictFile_Main,fname_FrictFile_Sewer);
simdef.mdf.IniFieldFile=fname_ini;
simdef.mdf.extn=fname_extn;
simdef.mdf.C=42; %it will be overwritten by the friction files
simdef.mdf.ext='';

%% CALL

simdef=D3D_rework(simdef);

%% OUTPUT

mdu=simdef.mdf;
mdu.fname=simdef.runid.name;

file.mdf=fullfile(fdir_out,sprintf('%s.mdu',simdef.runid.name));
file.mdfid=simdef.file.mdfid;
file.software=simdef.file.software;

D3D=simdef.D3D;

end %function
