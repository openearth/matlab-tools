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
%Gets as output the path to each file type
%
%INPUT
%   -
%

function simdef=D3D_simpath_mdu(path_mdu)

simdef.D3D.structure=2;

mdu=D3D_io_input('read',path_mdu);

%% loop on sim folder

[path_sim,runid,~]=fileparts(path_mdu);
simdef.D3D.dire_sim=path_sim;

dire=dir(simdef.D3D.dire_sim);
nf=numel(dire)-2;

for kf1=1:nf
    kf=kf1+2; %. and ..
    if dire(kf).isdir==0 %it is not a directory
        [~,~,ext]=fileparts(dire(kf).name); %file extension
        switch ext
            case '.pol'
                tok=regexp(dire(kf).name,'_','split');
                str_name=strrep(tok{1,end},'.pol','');
                if strcmp(str_name,'part')
                    simdef.file.(str_name)=fullfile(dire(kf).folder,dire(kf).name);
                end
        end
    end
end

%% mdu paths

simdef.file.mdf=path_mdu;

%geometry
simdef.file.grd=fullfile(path_sim,mdu.geometry.NetFile);
% simdef=D3D_read_mdu_flag(mdu.geometry,'CrossDefFile',simdef.file,'csdef',path_sim);
if isfield(mdu.geometry,'CrossDefFile') && ~isempty(mdu.geometry.CrossDefFile)
    simdef.file.csdef=fullfile(path_sim,mdu.geometry.CrossDefFile);
else
    simdef.file.csdef='';
end
if isfield(mdu.geometry,'CrossLocFile') && ~isempty(mdu.geometry.CrossLocFile)
    simdef.file.csloc=fullfile(path_sim,mdu.geometry.CrossLocFile);
else
    simdef.file.csloc='';
end
if isfield(mdu.geometry,'StructureFile') && ~isempty(mdu.geometry.StructureFile)
    simdef.file.struct=fullfile(path_sim,mdu.geometry.StructureFile);
else
    simdef.file.struct='';
end
if isfield(mdu.geometry,'FixedWeirFile') && ~isempty(mdu.geometry.FixedWeirFile)
    simdef.file.fxw=fullfile(path_sim,mdu.geometry.FixedWeirFile);
else
    simdef.file.fxw='';
end
if isfield(mdu.geometry,'BedlevelFile') && ~isempty(mdu.geometry.BedlevelFile)
    simdef.file.dep=fullfile(path_sim,mdu.geometry.BedlevelFile);
else
    simdef.file.dep='';
end

%extenral forcing
if isfield(mdu.external_forcing,'ExtForceFileNew') && ~isempty(mdu.external_forcing.ExtForceFileNew)
    simdef.file.extforcefilenew=fullfile(path_sim,mdu.external_forcing.ExtForceFileNew);
end

%sediment
if isfield(mdu,'sediment')
    if isfield(mdu.sediment,'MorFile')
        simdef.file.mor=fullfile(path_sim,mdu.sediment.MorFile);
    end
    if isfield(mdu.sediment,'SedFile')
        simdef.file.sed=fullfile(path_sim,mdu.sediment.SedFile);
    end
end

%output
if isfield(mdu.output,'OutputDir')
    path_output_loc=mdu.output.OutputDir;
    if isempty(path_output_loc)
        path_output_loc=sprintf('DFM_OUTPUT_%s',runid);
    end
    simdef.file.output=fullfile(path_sim,path_output_loc);
    file_aux=D3D_simpath_output(simdef.file.output);
    fnames=fieldnames(file_aux);
    nfields=numel(fnames);
    for kfields=1:nfields
        simdef.file.(fnames{kfields})=file_aux.(fnames{kfields});
    end
    if isfield(mdu.output,'CrsFile')
        aux=mdu.output.CrsFile;
        tok=regexp(aux,' ','split');
        ncrs=numel(tok);
        for kcrs=1:ncrs
            simdef.file.crsfile{kcrs}=fullfile(path_sim,tok{1,kcrs});
        end
    end
    
end



end %function