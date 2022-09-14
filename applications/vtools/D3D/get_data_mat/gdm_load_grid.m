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

function gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map,varargin)

%%

parin=inputParser;

addOptional(parin,'do_load',1);
addOptional(parin,'dim',2);
addOptional(parin,'fpath_grd',fullfile(fdir_mat,'grd.mat'));

parse(parin,varargin{:});

do_load=parin.Results.do_load;
dim=parin.Results.dim;
fpath_grd=parin.Results.fpath_grd;

%%

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

switch dim
    case 1
        gridInfo=NC_read_grid_1D(fpath_map);
    case 2
        gridInfo=EHY_getGridInfo(fpath_map,{'face_nodes_xy','XYcen','XYcor','no_layers','grid'},'mergePartitions',1); %#ok
        save_check(fpath_grd,'gridInfo'); 
end    

end %function