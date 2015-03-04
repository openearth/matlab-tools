function mdu = d3d2dflowfm_weirs(mdf,mdu, name_mdu)

% d3d2dflowfm_weirs : Writes weir information to D-Flow FM input file

if simona2mdf_fieldandvalue(mdf,'fil2dw') && ~isempty(mdf.fil2dw);
    mdu.geometry.ThindykeFile = [name_mdu '_2dw.pli'];
    d3d2dflowfm_weirs_xyz       ([mdf.pathd3d filesep mdf.filcco],[mdf.pathd3d filesep mdf.fil2dw], mdu.geometry.ThindykeFile);
    mdu.geometry.ThindykeFile = simona2mdf_rmpath( mdu.geometry.ThindykeFile);
end
