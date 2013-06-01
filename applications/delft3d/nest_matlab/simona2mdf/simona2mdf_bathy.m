




function mdf = simona2mdf_bathy(S,mdf,name_mdf)

% siminp2mdf_bathy : Gets bathymetry data out of the parsed siminp file

nesthd_dir = getenv('nesthd_path');

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'DEPTH_CONTROL'});

%
% positive upward or downward
%

sign = 1.0;

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.DEPTH_CONTROL.ORIENTATION')
    upward = strfind(siminp_struc.ParsedTree.DEPTH_CONTROL.ORIENTATION,'upwards');
    if ~isempty(upward)
        sign = -1.0;
    end
end

%
% Get bethymetry related information
%

depth(1:mdf.mnkmax(1),1:mdf.mnkmax(2)) = 0.;
siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BATHYMETRY'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BATHYMETRY.GLOBAL')
    global_vars = siminp_struc.ParsedTree.MESH.BATHYMETRY.GLOBAL;

    %
    % get bathymetry values
    %

    depth = simona2mdf_getglobaldata(global_vars,depth);
end

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BATHYMETRY.LOCAL.BOX')
    depth = simona2mdf_getboxdata(siminp_struc.ParsedTree.MESH.BATHYMETRY.LOCAL.BOX,depth);
end

mdf        = rmfield(mdf,'depuni');
mdf.fildep = [name_mdf '.dep'];
wldep('write',mdf.fildep,depth,'quit');
mdf.fildep = simona2mdf_rmpath(mdf.fildep);
