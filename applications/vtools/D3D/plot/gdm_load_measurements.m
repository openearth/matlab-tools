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
%Load data from measurements. One either request all locations for a single
%time (provide as input `time`) or all times for a single location (provide
%as input `x`). 
%
%Example format:
% data.h.val_mean.tim_dnum %[1,nt]
% data.h.val_mean.s %[nx,1]
% data.h.val_mean.val %[nx,nt]

function data_out=gdm_load_measurements(fid_log,fpath_mea,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'x',[]);
addOptional(parin,'var','');
addOptional(parin,'stat','');
addOptional(parin,'do_rkm',0);
addOptional(parin,'tol',30);

parse(parin,varargin{:});

tim=parin.Results.tim;
input_variable_name=parin.Results.var;
stat=parin.Results.stat;
do_rkm=parin.Results.do_rkm;
tol=parin.Results.tol;

if ~isempty(tim)
    do_time=true;
    obj=parin.Results.tim;
else
    do_time=false;
    obj=parin.Results.x;
end

%% CALC

data_out=struct('x',[],'y',[]);

if ~isfile(fpath_mea)
    messageOut(fid_log,sprintf('No file with measurements: %s',fpath_mea));
    return;
end
messageOut(fid_log,sprintf('Loading measurements from file: %s',fpath_mea));
load(fpath_mea,'data');

if ~isstruct(data);
    messageOut(fid_log,sprintf('No data struct found in file: %s',fpath_mea));
    return;
end

variables_in_measurements=fieldnames(data);
accepted_variable_name=gdm_var_name_accepted(input_variable_name);
idx_var=find_str_in_cell(variables_in_measurements,accepted_variable_name);

if isnan(idx_var)
    messageOut(fid_log,sprintf('No variable found in measurements: %s',input_variable_name));
    return;
end

statistics_in_measurements=fieldnames(data.(variables_in_measurements{idx_var})); %

accepted_statistics_name=gdm_stat_name_accepted(stat);
idx_stat=find_str_in_cell(statistics_in_measurements,accepted_statistics_name);
idx_stat=gdm_stat_idx_accepted(statistics_in_measurements,idx_stat,stat);

if isnan(idx_stat)
    messageOut(fid_log,sprintf('No statistic found for variable %s: %s',variables_in_measurements{idx_var},stat));
    return;
end
messageOut(fid_log,sprintf('Statistic found for variable %s: %s',variables_in_measurements{idx_var},statistics_in_measurements{idx_stat}));

struct_loc=data.(variables_in_measurements{idx_var}).(statistics_in_measurements{idx_stat});

if do_time
    vec=struct_loc.tim_dnum;
else
    if do_rkm || ~isfield(struct_loc,'s')
        vec=struct_loc.rkm;
    else
        vec=struct_loc.s;
    end
end

if do_time
    [idx_min,~,flg_found]=absmintol(vec,obj,'dnum',1,'tol',tol,'do_break',0,'do_disp_list',0);
else
    [idx_min,~,flg_found]=absmintol(vec,obj,'dnum',0,'tol',tol,'do_break',0,'do_disp_list',0);
end

if isnan(idx_min) || ~flg_found; return; end

messageOut(fid_log,sprintf('Measurement found %s for variable %s at index %d',statistics_in_measurements{idx_stat},variables_in_measurements{idx_var},idx_min));

if do_time
    if do_rkm || ~isfield(struct_loc,'s')
        data_out.x=struct_loc.rkm;
    else
        data_out.x=struct_loc.s;
    end
    data_out.y=struct_loc.val(:,idx_min);
else
    data_out.x=struct_loc.tim_dnum;
    data_out.y=struct_loc.val(idx_min,:);
end


end %function

function var_nam_accepted=gdm_var_name_accepted(var_name)

switch var_name
    case {'mesh2d_mor_bl','bl','DPS'}
        var_nam_accepted={'mesh2d_mor_bl','bl','DPS'};
    otherwise
        var_nam_accepted={var_name};

end

end %function

function stat_nam_accepted=gdm_stat_name_accepted(stat_name)

switch stat_name
    case {'val_mean','val_mean_weighted'}
        stat_nam_accepted={'val_mean','val_mean_weighted'};
    otherwise
        stat_nam_accepted={stat_name};

end

end %function

function idx_stat_out=gdm_stat_idx_accepted(statistics_in_measurements,idx_stat_in,stat_name)

idx_stat_out=idx_stat_in;

if isnan(idx_stat_in)
    return;
end

switch stat_name
    case {'val_mean','val_mean_weighted'}
        idx_val_mean=find(strcmp(statistics_in_measurements,'val_mean'));
        if ~isempty(idx_val_mean)
            idx_stat_out=idx_val_mean(1);
        end
end

end %function