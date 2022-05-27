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

function data_out=gdm_load_measurements(fid_log,fpath_mea,varargin)

%% PARSE

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var','');
addOptional(parin,'stat','');

parse(parin,varargin{:});

tim_dnum=parin.Results.tim;
var_nam=parin.Results.var;
stat=parin.Results.stat;

%% CALC

load(fpath_mea);

if ~isstruct(data); data_out=NaN; return; end

fn=fieldnames(data);
var_nam_accepted=gdm_var_name_accepted(var_nam);
idx_var=find_str_in_cell(fn,var_nam_accepted);

if isnan(idx_var); data_out=NaN; return; end

fn2=fieldnames(data.(fn{idx_var}));

idx_stat=find_str_in_cell(fn2,{stat});

if isnan(idx_stat); data_out=NaN; return; end

struct_loc=data.(fn{idx_var}).(fn2{idx_stat});

tim_mea=struct_loc.tim_dnum;
idx_min=absmintol(tim_mea,tim_dnum,'dnum',1,'tol',30,'do_break',0);

if isnan(idx_min); data_out=NaN; return; end

data_out.x=struct_loc.rkm;
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