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
%Load data from measurements. 
%
%Example format:
% data.h.val_mean.tim_dnum %[1,nt]
% data.h.val_mean.s %[nx,1]
% data.h.val_mean.val %[nx,nt]

function data_out=gdm_load_measurements(fid_log,fpath_mea,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var','');
addOptional(parin,'stat','');
addOptional(parin,'do_rkm',0);
addOptional(parin,'tol',30);

parse(parin,varargin{:});

tim_dnum=parin.Results.tim;
var_nam=parin.Results.var;
stat=parin.Results.stat;
do_rkm=parin.Results.do_rkm;
tol=parin.Results.tol;

%% CALC

data_out=struct('x',[],'y',[]);

if ~isfile(fpath_mea)
    error('No file with measurements: %s',fpath_mea)
end
load(fpath_mea,'data');

if ~isstruct(data); return; end

fn=fieldnames(data);
var_nam_accepted=gdm_var_name_accepted(var_nam);
idx_var=find_str_in_cell(fn,var_nam_accepted);

if isnan(idx_var); return; end

fn2=fieldnames(data.(fn{idx_var}));

idx_stat=find_str_in_cell(fn2,{stat});

if isnan(idx_stat); return; end

struct_loc=data.(fn{idx_var}).(fn2{idx_stat});

tim_mea=struct_loc.tim_dnum;
[idx_min,~,flg_found]=absmintol(tim_mea,tim_dnum,'dnum',1,'tol',tol,'do_break',0);

if isnan(idx_min) || ~flg_found; return; end

% fprintf('index time match %03d \n',idx_min);

if do_rkm || ~isfield(struct_loc,'s')
    data_out.x=struct_loc.rkm;
else
    data_out.x=struct_loc.s;
end
data_out.y=struct_loc.val(:,idx_min);

end %function

function var_nam_accepted=gdm_var_name_accepted(var_name)

switch var_name
    case {'mesh2d_mor_bl','bl','DPS'}
        var_nam_accepted={'mesh2d_mor_bl','bl','DPS'};
    otherwise
        var_nam_accepted={var_name};

end

end %function