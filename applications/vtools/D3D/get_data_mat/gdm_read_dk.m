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
%GDM_READ_SED reads sediment transport data from D3D sediment transport offline files

function dk=gdm_read_dk(simdef)

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,'dk.mat');
if exist(fpath_mat,'file')==2
    messageOut(NaN,sprintf('Loading sediment data from mat-file: %s',fpath_mat));
    load(fpath_mat,'dk');
    return
end
if ~isfield(simdef.file,'sed') || isempty(simdef.file.sed)
    return
end
dk=D3D_read_sed(simdef.file.sed);
save_check(fpath_mat,'dk');

end %function