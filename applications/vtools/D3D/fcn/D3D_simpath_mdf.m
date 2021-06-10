%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17240 $
%$Date: 2021-04-30 12:26:05 +0200 (Fri, 30 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_simpath_mdu.m 17240 2021-04-30 10:26:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath_mdu.m $
%
%Gets as output the path to each file type
%
%INPUT
%   -
%

function simdef=D3D_simpath_mdf(path_mdu)

simdef.D3D.structure=2;

mdu=D3D_io_input('read',path_mdu);

%% loop on sim folder

[path_sim,runid,~]=fileparts(path_mdu);
% simdef.D3D.dire_sim=path_sim;

% dire=dir(simdef.D3D.dire_sim);
% nf=numel(dire)-2;

% for kf1=1:nf
%     kf=kf1+2; %. and ..
%     if dire(kf).isdir==0 %it is not a directory
%         [~,~,ext]=fileparts(dire(kf).name); %file extension
%         switch ext
%             case '.pol'
%                 tok=regexp(dire(kf).name,'_','split');
%                 str_name=strrep(tok{1,end},'.pol','');
%                 if strcmp(str_name,'part')
%                     simdef.file.(str_name)=fullfile(dire(kf).folder,dire(kf).name);
%                 end
%         end
%     end
% end

%% mdu paths

simdef.file.mdf=path_mdu;

%grid
if isfield(mdu.keywords,'filcco') && ~isempty(mdu.keywords.filcco)
    simdef.file.grd=fullfile(path_sim,mdu.keywords.filcco);
end
if isfield(mdu.keywords,'filgrd') && ~isempty(mdu.keywords.filgrd)
    simdef.file.enc=fullfile(path_sim,mdu.keywords.filgrd);
end

%sediment
if isfield(mdu.keywords,'filsed') && ~isempty(mdu.keywords.filsed)
    simdef.file.sed=fullfile(path_sim,mdu.keywords.filsed);
end
if isfield(mdu.keywords,'filmor') && ~isempty(mdu.keywords.filmor)
    simdef.file.mor=fullfile(path_sim,mdu.keywords.filmor);
end

%bc
if isfield(mdu.keywords,'filbct') && ~isempty(mdu.keywords.filbct)
    simdef.file.bct=fullfile(path_sim,mdu.keywords.filbct);
end

%dep
if isfield(mdu.keywords,'fildep') && ~isempty(mdu.keywords.fildep)
    simdef.file.dep=fullfile(path_sim,mdu.keywords.fildep);
end

%output
% if isfield(mdu.output,'OutputDir')
%     path_output_loc=mdu.output.OutputDir;
%     if isempty(path_output_loc)
%         path_output_loc=sprintf('DFM_OUTPUT_%s',runid);
%     end
%         path_output=fullfile(path_sim,path_output_loc);
        path_output=path_sim;
        file_aux=D3D_simpath_output_s(path_output);
        fnames=fieldnames(file_aux);
        nfields=numel(fnames);
        for kfields=1:nfields
            simdef.file.(fnames{kfields})=file_aux.(fnames{kfields});
        end
% end

end %function