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
addOptional(parin,'simdef',NaN);

parse(parin,varargin{:});

do_load=parin.Results.do_load;
dim=parin.Results.dim;
fpath_grd=parin.Results.fpath_grd;
simdef=parin.Results.simdef;

%% check dimensions

if isempty(fpath_map) %grid file must already exist
    if exist(fpath_grd,'file')~=2
        error('If there is no input to <fpath_map>, <fpath_grd> must already exist: %s',fpath_grd)
    end
    load(fpath_grd,'gridInfo')
    if isfield(gridInfo,'branch')
        is1d=true;
    else
        is1d=false;
    end
else    
    [~,is1d,~,~]=D3D_is(fpath_map);
end

if is1d==1 && dim==2
    dim=1;
    messageOut(fid_log,'The grid seems to be 1D. I read it as such')
elseif is1d==3 && dim==2
    dim=1;
    messageOut(fid_log,'The grid seems to be 1D Sobek 3. I read it as such')
elseif is1d==0 && dim==1
    dim=2;
    messageOut(fid_log,'The grid seems to be 2D. I read it as such')
end

%% LOAD 

if exist(fpath_grd,'file')==2
    if do_load
        messageOut(fid_log,'Grid mat-file exist. Loading.')
        load(fpath_grd,'gridInfo')
    else
        messageOut(fid_log,'Grid mat-file exist.')
    end
    return
end

%% READ

messageOut(fid_log,'Grid mat-file does not exist. Reading.')

if iscell(fpath_map) %SMT-D3D4
    gridInfo=D3D_read_grid_SMTD3D4(fpath_map);   
else
    switch dim
        case 1
            if is1d==3
                gridInfo=NC_read_grid_S3(fpath_map,simdef);
            else
                gridInfo=NC_read_grid_1D(fpath_map);
            end
        case 2
            gridInfo=EHY_getGridInfo(fpath_map,{'face_nodes_xy','XYcen','XYcor','no_layers','grid','edge_nodes','XYuv'},'mergePartitions',1);   
    end    

end

save_check(fpath_grd,'gridInfo'); 

end %function