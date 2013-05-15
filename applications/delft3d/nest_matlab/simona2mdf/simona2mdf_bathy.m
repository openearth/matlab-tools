function mdf = simona2mdf_bathy(S,mdf,name_mdf)

% siminp2mdf_bathy : Gets bathymetry data out of the parsed siminp file

nesthd_dir = getenv('nesthd_path');

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'DEPTH_CONTROL'});

%
% positive upward or downward
%

sign = 1.0;

if isfield(siminp_struc.ParsedTree,'DEPTH_CONTROL.ORIENTATION')
    upward = strfind(siminp_struc.ParsedTree.DEPTH_CONTROL.ORIENTATION,'upwards');
    if ~isempty(upward)
        sign = -1.0;
    end
end

%
% Get bethymetry related information
%

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BATHYMETRY'});

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
% get bathymetry values
%

depth(1:mdf.mnkmax(1),1:mdf.mnkmax(2)) = 0.;

if ~isempty(global_vars.CONST_VALUES)
    depth(1:mdf.mnkmax(1),1:mdf.mnkmax(2)) = global_vars.CONST_VALUES;
end

if ~isempty(global_vars.VARIABLE_VAL)
    simona2mdf_warning('GLOBAL\VARIABLE_VAL (depth) not yet implemented');
end

if isfield(siminp_struc.ParsedTree.MESH.BATHYMETRY,'LOCAL')
   if isfield(siminp_struc.ParsedTree.MESH.BATHYMETRY.LOCAL,'BOX')
      depth = simona2mdf_getboxdata(siminp_struc.ParsedTree.MESH.BATHYMETRY.LOCAL.BOX,depth);
   end
end

mdf        = rmfield(mdf,'depuni');
mdf.fildep = [name_mdf '.dep'];
wldep('write',mdf.fildep,depth,'quit');
