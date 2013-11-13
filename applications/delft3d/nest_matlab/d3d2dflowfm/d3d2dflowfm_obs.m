function mdu = d3d2dflowfm_obs(mdf,mdu, name_mdu)

% d3d2dflowfm_obs : Writes station informations to D-Flow FM input files

if simona2mdf_fieldandvalue(mdf,'filsta')

    LINE   = [];

    % Open and read the D3D Files
    grid  = delft3d_io_grd('read',[mdf.pathd3d filesep mdf.filcco]);
    xcoor = grid.cend.x';
    ycoor = grid.cend.y';

    sta   = delft3d_io_obs('read',[mdf.pathd3d filesep mdf.filsta]);

    %
    % Fill LINE struct for writing to unstruc file
    %

    for ista = 1: sta.NTables
        LINE.DATA{ista,1} = xcoor(sta.m(ista),sta.n(ista));
        LINE.DATA{ista,2} = ycoor(sta.m(ista),sta.n(ista));
        LINE.DATA{ista,3} = strtrim(sta.namst(ista,:));
    end

    % finally write to the unstruc thd file and fill in the name of the thd filw in the mdu_struct

    mdu.output.ObsFile = [name_mdu '.xyn'];
    dflowfm_io_xydata('write',mdu.output.ObsFile,LINE);
    mdu.output.ObsFile = simona2mdf_rmpath(mdu.output.ObsFile);
end
