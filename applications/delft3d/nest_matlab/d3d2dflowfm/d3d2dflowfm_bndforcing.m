function mdu = d3d2dflow_bndforcing(mdf,mdu,name_mdu)

ext_force = dflowfm_io_extfile('read',[mdu.pathmdu filesep mdu.external_forcing.ExtForceFile]);

i_bnd  = 0;
filpli = [];

%% Find the open hydrodynamic boundaries
for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
        isempty(strfind(ext_force(i_force).quantity,'salinity'))
        i_bnd = i_bnd + 1;
        index(i_bnd) = i_force;
    end
end
no_bnd = length(index);


%% Make the list of pli files
for i_bnd = 1: no_bnd
    filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
end

%% Convert hydrodynamic boundary conditions
d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filana],filpli,mdu.pathmdu);
d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbch],filpli,mdu.pathmdu);
d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbct],filpli,mdu.pathmdu);

%% Same story, this time for the salinity boundaries

i_bnd  = 0;
filpli = [];

for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
       ~isempty(strfind(ext_force(i_force).quantity,'salinity'))
        i_bnd = i_bnd + 1;
        index(i_bnd) = i_force;
    end
end
no_bnd = length(index);


%% Make the list of pli files
for i_bnd = 1: no_bnd
    filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
end

%% Convert salinity boundary conditions
d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbcc],filpli,mdu.pathmdu);

