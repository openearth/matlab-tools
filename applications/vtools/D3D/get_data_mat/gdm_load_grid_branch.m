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

function gridInfo=gdm_load_grid_branch(fid_log,flg_loc,fdir_mat,gridInfo_all,branch,branch_name,varargin)

%%

parin=inputParser;

addOptional(parin,'do_load',1);

parse(parin,varargin{:});

do_load=parin.Results.do_load;

%%

do_rkm=0;
if isfield(flg_loc,'fpath_rkm')
    do_rkm=1;
end
   
if isfield(flg_loc,'rkm_tol')==0
    flg_loc.rkm_tol=500;
end

if ~ischar(branch_name)
    error('<branch_name{kbr,1}> should be a string')
end

%%

fpath_grd=fullfile(fdir_mat,sprintf('grd_%s.mat',branch_name));

if exist(fpath_grd,'file')==2
    if do_load
        messageOut(fid_log,'Grid mat-file exist. Loading.')
        load(fpath_grd,'gridInfo')
    else
        messageOut(fid_log,'Grid mat-file exist.')
    end
    return
end

messageOut(fid_log,'Grid mat-file does not exist. Reading.')

gridInfo=gdm_grd_branch(gridInfo_all,branch);

%convert to river km
if do_rkm
    rkm_br=convert2rkm(flg_loc.fpath_rkm,gridInfo.xy,'TolMinDist',flg_loc.rkm_tol);
    gridInfo.rkm=rkm_br;
    
    rkm_br=convert2rkm(flg_loc.fpath_rkm,gridInfo.xy_edge,'TolMinDist',flg_loc.rkm_tol);
    gridInfo.rkm_edge=rkm_br;
else
    gridInfo.rkm=NaN;
    gridInfo.rkm_edge=NaN;
end

save_check(fpath_grd,'gridInfo'); 

end %function