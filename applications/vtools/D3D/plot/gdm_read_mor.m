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
%GDM_READ_MOR reads morphodynamic data from D3D morphodynamic files

function mor=gdm_read_mor(simdef)

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,'mor.mat');
if exist(fpath_mat,'file')==2
    messageOut(NaN,sprintf('Loading sediment data from mat-file: %s',fpath_mat));
    load(fpath_mat,'mor');
    return
end
if ~isfield(simdef.file,'mor') || isempty(simdef.file.mor)
    return
end
mor=D3D_io_input('read',simdef.file.mor);
save_check(fpath_mat,'mor');

end %function