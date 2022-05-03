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
%

function [bol_grd,pol_name]=gdm_pol_bol_grd(fid_log,flg_loc,simdef,fpath_pol)
    
%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end

%% CALC

fdir_mat=simdef.file.mat.dir;

pol=D3D_io_input('read',fpath_pol);
pol_name=strrep(pol.name{1,1},' ','');
fpath_bol=mat_tmp_name(fdir_mat,'bol_grd','pol',pol_name);
if exist(fpath_bol,'file')==2 && ~flg_loc.overwrite
    messageOut(fid_log,sprintf('Polygon grd-boolean exists: %s',fpath_bol));
    load(fpath_bol,'bol_grd')
else
    messageOut(fid_log,sprintf('Doing inpolygon for: %s',fpath_pol));
    if numel(pol.val)>1
        error('Only one polygon per input file accepted: %s',fpath_pol);
    end
    create_mat_grd(fid_log,flg_loc,simdef)
    load(simdef.file.mat.grd,'gridInfo')
    bol_grd=inpolygon(gridInfo.Xcen,gridInfo.Ycen,pol.val{1,1}(:,1),pol.val{1,1}(:,2)); 
    save_check(fpath_bol,'bol_grd');
end

end %function