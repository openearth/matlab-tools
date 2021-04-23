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
if isfield(mdu.geometry,'CrossDefFile')
    simdef.file.csdef=fullfile(path_sim,mdu.geometry.CrossDefFile);
end
if isfield(mdu.geometry,'CrossLocFile')
    simdef.file.csloc=fullfile(path_sim,mdu.geometry.CrossLocFile);
end
if isfield(mdu.geometry,'StructureFile')
    simdef.file.struct=fullfile(path_sim,mdu.geometry.StructureFile);
end
mdu.geometry.StructureFile

%sediment
if isfield(mdu,'sediment')
    simdef.file.mor=fullfile(path_sim,mdu.sediment.MorFile);
    simdef.file.sed=fullfile(path_sim,mdu.sediment.SedFile);
end

%output
if isfield(mdu.output,'OutputDir')
    path_output_loc=mdu.output.OutputDir;
    if isempty(path_output_loc)
        path_output_loc=sprintf('DFM_OUTPUT_%s',runid);
    end
        path_output=fullfile(path_sim,path_output_loc);
        file_aux=D3D_simpath_output(path_output);
        fnames=fieldnames(file_aux);
        nfields=numel(fnames);
        for kfields=1:nfields
            simdef.file.(fnames{kfields})=file_aux.(fnames{kfields});
        end
end

end %function