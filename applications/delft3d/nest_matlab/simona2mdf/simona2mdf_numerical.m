function mdf = simona2mdf_numerical(S,mdf,name_mdf)

% siminp2mdf_bathy : Gets numerical parameters out of the parsed siminp file

nesthd_dir   = getenv('nesthd_path');
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BATHYMETRY'});
global_vars  = siminp_struc.ParsedTree.MESH.BATHYMETRY.GLOBAL;

%
% The depth definition
%

global_vars = siminp_struc.ParsedTree.MESH.BATHYMETRY.GLOBAL;

if isempty(global_vars.DPS_GIVEN)

    %
    % Depths specifief in depth(corner) points
    %

    mdf.dpsopt = 'MAX';
    mdf.dpuopt = 'MEAN';
    if isfield (global_vars,'METH_DPS')
        if strcmpi(global_vars.METH_DPS,'MEAN_DPD')
            mdf.dpsopt = 'MEAN';
        elseif strcmpi(global_vars.METH_DPS,'MAX_DPD') || strcmpi(global_vars.METH_DPS,'MAX_DPUV')
            mdf.dpsopt = 'MAX';
        elseif strcmpi(global_vars.METH_DPS,'MIN_DPUV')
           mdf.dpsopt = 'MIN';
        end
    end
else
    mdf.dpsopt = 'DP';
    mdf.dpuopt = 'MIN';
end

if ~isempty(global_vars.METH_DPUV)
    dryfl_max = strfind(lower(global_vars.METH_DPUV),'max');
    if ~isempty(dryfl_max)
        mdf.dpuopt = 'MAX';
    end
    dryfl_min = strfind(lower(global_vars.METH_DPUV),'min');
    if ~isempty(dryfl_min)
        mdf.dpuopt = 'MIN';
    end
end

%
% drying flooding criterion
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM'});
drying = siminp_struc.ParsedTree.FLOW.PROBLEM.DRYING;

if isempty (drying)
    mdf.dryflc = 0.3; % Simona default value
elseif ~isempty(drying.DEPCRIT)
    mdf.dryflc = drying.DEPCRIT;
elseif ~isempty(drying.THRES_UV_FLOODING)
    mdf.dryflc = drying.THRES_UV_FLOODING;
end

%
% Reset default furuv (does not exist in SIMONA, not a good plan to start with anyway)
%

mdf.forfuv = 'N';
