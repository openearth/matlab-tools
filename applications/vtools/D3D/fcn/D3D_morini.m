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

%% OPEN

[fid,fname_local]=write_local_and_copy('open',simdef.file.mini,'overwrite',true);

%% WRITE

fprintf(fid,'[BedCompositionFileInformation]\r\n');
fprintf(fid,'FileVersion     = 01.00\r\n');
fprintf(fid,'FileCreatedBy   = %s\r\n',getenv("USERNAME"));
fprintf(fid,'FileCreationDate= %s\r\n',string(datetime('now')));
for ksl=1:nl
    fprintf(fid,'[Layer]\r\n');
    fprintf(fid,'Type = volume fraction\r\n');
    fprintf(fid,'Thick = %s/lyr%02d_thk.xyz\r\n',folder_out,ksl);
    for kf=1:nf
        fprintf(fid,'Fraction%d = %s/lyr%02d_frac%02d.xyz\r\n',kf,folder_out,ksl,kf);
    end %kf
end %kl

%% CLOSE

write_local_and_copy('close',fid,fname_local,simdef.file.mini)