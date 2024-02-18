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

simdef.err=0;

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

simdef.file=read_flag(path_sim,simdef.file,mdu,'NetFile','grd');
simdef.file=read_flag(path_sim,simdef.file,mdu,'GridEnclosureFile','enc');
simdef.file=read_flag(path_sim,simdef.file,mdu,'CrossDefFile','csdef');
simdef.file=read_flag(path_sim,simdef.file,mdu,'CrossLocFile','csloc');
simdef.file=read_flag(path_sim,simdef.file,mdu,'PillarFile','pillars');
simdef.file=read_flag(path_sim,simdef.file,mdu,'StructureFile','struct');
simdef.file=read_flag(path_sim,simdef.file,mdu,'FixedWeirFile','fxw');
simdef.file=read_flag(path_sim,simdef.file,mdu,'BedlevelFile','dep');
simdef.file=read_flag(path_sim,simdef.file,mdu,'ThinDamFile','thd');
simdef.file=read_flag(path_sim,simdef.file,mdu,'ExtForceFile','extforcefile');
simdef.file=read_flag(path_sim,simdef.file,mdu,'ExtForceFileNew','extforcefilenew');
simdef.file=read_flag(path_sim,simdef.file,mdu,'MorFile','mor');
simdef.file=read_flag(path_sim,simdef.file,mdu,'SedFile','sed');
simdef.file=read_flag(path_sim,simdef.file,mdu,'CrsFile','crsfile');
simdef.file=read_flag(path_sim,simdef.file,mdu,'ObsFile','obsfile');
simdef.file=read_flag(path_sim,simdef.file,mdu,'SubstanceFile','sub');

%output
if isfield(mdu,'output')
    %output dir
    if isfield(mdu.output,'OutputDir')
        path_output_loc=mdu.output.OutputDir;
        if isempty(path_output_loc)
            path_output_loc=sprintf('DFM_OUTPUT_%s',runid);
        end
        simdef.file.output=fullfile(path_sim,path_output_loc);
        [file_aux,simdef.err]=D3D_simpath_output(simdef.file.output,runid);
        fnames=fieldnames(file_aux);
        nfields=numel(fnames);
        for kfields=1:nfields
            simdef.file.(fnames{kfields})=file_aux.(fnames{kfields});
        end
    end
end

end %function

%%
%% FUNCTION
%%

function c=paths_str2cell(path_sim,s)

tok=regexp(s,' ','split');
ns=numel(tok);
if ns>1
    c=cell(1,ns);
    for ks=1:ns
        c{1,ks}=fullfile(path_sim,tok{1,ks});
    end
else
    c=fullfile(path_sim,s);
end

end %function

%%

function simdef_file=read_flag(path_sim,simdef_file,mdu,mdu_str,save_str)

fn=fieldnames(mdu);
nf=numel(fn);
for kf=1:nf
    fn_loc=fieldnames(mdu.(fn{kf}));
    bol_flag=strcmpi(fn_loc,mdu_str);
    nflags=sum(bol_flag);
    if nflags>1
        error('In file %s there is more than one flag with name %s',simdef_file.mdf,mdu_str)
    elseif nflags==1 && ~isempty(mdu.(fn{kf}).(fn_loc{bol_flag}))
        simdef_file.(save_str)=paths_str2cell(path_sim,mdu.(fn{kf}).(fn_loc{bol_flag}));
    end
end %kf

end %function