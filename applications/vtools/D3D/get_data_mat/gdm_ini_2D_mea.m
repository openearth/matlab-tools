%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20146 $
%$Date: 2025-05-13 09:50:14 +0200 (Tue, 13 May 2025) $
%$Author: chavarri $
%$Id: D3D_gdm.m 20146 2025-05-13 07:50:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Initialize 2D measurements

function flg_loc=gdm_ini_2D_mea(flg_loc)

%% PARSE

flg_loc=isfield_default(flg_loc,'measurements','');

%% SKIP

if isempty(flg_loc.measurements)
    flg_loc.measurements_structure=struct();
    return
end

%% CALC

[~,~,fext]=fileparts(flg_loc.measurements);

switch fext
    case '.csv'
        measurements_structure=gdm_ini_2D_mea_csv(flg_loc.measurements);
    otherwise
        error('No reader for extension %s',fext)
end

flg_loc.measurements_structure=measurements_structure;

end %function

%%
%% FUNCTIONS
%%

%Reads the index and provides a structure with information for each tile
%with data. 
%
%2DO: Currently, we get the coordinates as they are in the file and we do
%not read the coordinate system. For correct plotting we rely on the model
%being in the same coordinate system. 
function measurements_structure=gdm_ini_2D_mea_csv(fpath_csv)

% time, file, factor
% 1995-01-01T00:00:00+01:00, p:\archivedprojects\11206792-kpp-rivierkunde-2021\003_maas\04_input_generation\14_export_jmp_to_tif\1995.tif , 0.01

data_index=readtable(fpath_csv,'Delimiter',',');
var_names=data_index.Properties.VariableNames;
if ~any(contains(var_names,{'time'}))
    error('`time` could not be read from file: %s',fpath_csv)
end
if ~any(contains(var_names,{'file'}))
    error('`file` could not be read from file: %s',fpath_csv)
end
if ~any(contains(var_names,{'factor'}))
    error('`factor` could not be read from file: %s',fpath_csv)
end
if numel(var_names)~=3
    error('There seem to be more or less than 3 variables in file: %s',fpath_csv)
end
time_vector=data_index.time;
if iscell(time_vector) %it has not been read as a datetime
    time_datetime=cellfun(@(X)time2datetime(X),time_vector);
    data_index.time=time_datetime;
end

%This structure must be the same as given by `VRT_bounding_boxes` (or
%other) plus:
% `Time`
% `Factor`

measurements_structure=struct('Filename', {}, 'MinX', {}, 'MaxX', {}, 'MinY', {}, 'MaxY', {},'Time',{},'Factor',{});

nf=size(data_index,1);

for kf=1:nf
    fpath_file=data_index.file{kf};
    [fdir_file,~,fext]=fileparts(fpath_file);
    switch fext
        case '.vrt'
            bounding_box=VRT_bounding_boxes(fpath_file);
            %change the local filename to fullpath. 
            %ATTENTION! I am assuming the path given is always relative. It could
            %be checked somehow.
            fpath_rel_cell={bounding_box.Filename};
            fpath_full_cell=cellfun(@(X)fullfile(fdir_file,X),fpath_rel_cell,'UniformOutput',false);
            bounding_box=struct_assign_val(bounding_box,'Filename',fpath_full_cell);
        case '.tif'
            bounding_box=TIF_bounding_boxes(fpath_file);
        case '.shp'
            bounding_box=SHP_bounding_boxes(fpath_file);
        otherwise
            error('No reader for extension %s',fext)
    end
    %assign to all files in a VRT, or a single tif-file
        %time
    bounding_box=struct_assign_val(bounding_box,'Time',data_index.time(kf));
        %factor
    bounding_box=struct_assign_val(bounding_box,'Factor',data_index.factor(kf));

    %join
    measurements_structure=[measurements_structure,bounding_box];
end %kf

end %function

%%
