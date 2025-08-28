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
%Writes initial composition main file <morini.ini>, which points to the
%initial composition files for every fraction and layer. 

function D3D_morini(simdef)

frac=simdef.mor.frac;
if isfield(simdef.mor,'path_dir_gsd_rel2mdu')
    folder_out=simdef.mor.path_dir_gsd_rel2mdu;
elseif isfield(simdef.mor,'folder_out')
    folder_out=simdef.mor.folder_out;
else
    folder_out='gsd';
end
dire_sim=simdef.D3D.dire_sim;

nf=size(frac,3);
nl=size(frac,2);

%%
kl=1;
data{kl,1}='[BedCompositionFileInformation]'; kl=kl+1;
data{kl,1}='FileVersion     = 01.00'; kl=kl+1;
data{kl,1}=sprintf('FileCreatedBy   = %s',username); kl=kl+1;
data{kl,1}=sprintf('FileCreationDate= %s',string(datetime('now'))); kl=kl+1;
for ksl=1:nl
data{kl,1}='[Layer]'; kl=kl+1;
data{kl,1}='Type = volume fraction'; kl=kl+1;
data{kl,1}=sprintf('Thick = %s/lyr%02d_thk.xyz',folder_out,ksl); kl=kl+1;
for kf=1:nf
data{kl,1}=sprintf('Fraction%d = %s/lyr%02d_frac%02d.xyz',kf,folder_out,ksl,kf); kl=kl+1;
end %kf
end %kl
           
%% WRITE

file_name=fullfile(dire_sim,'morini.ini');
writetxt(file_name,data)