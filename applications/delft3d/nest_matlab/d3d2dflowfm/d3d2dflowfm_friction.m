function mdu = d3d2dflowfm_friction(mdf,mdu, name_mdu)

% d3d2dflwfm_friction: Writes friction information to D-Flow FM input files

[~,nameshort,~] = fileparts(name_mdu);
mdu.Filrgh      = '';

%% Determine friction type
if strcmpi(mdf.roumet,'c') mdu.physics.UnifFrictType = 0;end
if strcmpi(mdf.roumet,'m') mdu.physics.UnifFrictType = 1;end
if strcmpi(mdf.roumet,'w') mdu.physics.UnifFrictType = 2;end
if strcmpi(mdf.roumet,'z') mdu.physics.UnifFrictType = 3;end

%% Reads roughness values from file
filgrd = [mdf.pathd3d filesep mdf.filcco];
filrgh = [mdf.pathd3d filesep mdf.filrgh];
if ~isempty(filrgh)
    mdu.physics.UnifFrictCoef = -999.999;
    mdu.Filrgh               = [nameshort '_rgh.xyz'];

    d3d2dflowdm_friction_xyz(filgrd,filrgh,[name_mdu '_rgh.xyz']);
else

    % Constant values from mdf file
    mdu.physics.UnifFrictCoef = 0.5*(mdf.ccofu + mdf.ccofv);
end
