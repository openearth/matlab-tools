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

fdir_mat=simdef.file.fdir_mat;
fpath_mat=fullfile(fdir_mat,'mor.mat');
if exist(fpath_mat,'file')==2
    messageOut(NaN,sprintf('Loading sediment data from mat-file: %s',fpath_mat));
    load(fpath_mat,'mor');
    return
end
if ~isfield(simdef.file,'mor') || isempty(simdef.file.mor)
    return
end
if iscell(simdef.file.mor)
    %We assume it is an SMT simulation and the same morphodynamic file is used for all simulations. We take the first one.
    fpath_mor=simdef.file.mor{1,1};
else
    fpath_mor=simdef.file.mor;
end
mor=D3D_io_input('read',fpath_mor);
save_check(fpath_mat,'mor');

end %function