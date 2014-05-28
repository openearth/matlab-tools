function mdu = d3d2dflow_bndforcing(mdf,mdu,name_mdu)

ext_force = dflowfm_io_extfile('read',[mdu.pathmdu filesep mdu.external_forcing.ExtForceFile]);

no_bnd  = 0;
filpli = [];

%% Find the open hydrodynamic boundaries
for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
        isempty(strfind(ext_force(i_force).quantity,'salinity'))
        no_bnd = no_bnd + 1;
        index(no_bnd) = i_force;
    end
end


%% Make the list of pli files
for i_bnd = 1: no_bnd
    filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
end

%% Convert hydrodynamic boundary conditions, start with astronomical bc

if simona2mdf_fieldandvalue(mdf,'filana')
    if simona2mdf_fieldandvalue(mdf,'filcor') && ~isempty(mdf.filcor)

        %% with correction file
        d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filana],filpli,mdu.pathmdu,'Astronomical',true,'Correction',[mdf.pathd3d filesep mdf.filcor]);
    else

        %% without correction file
        d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filana],filpli,mdu.pathmdu,'Astronomical',true);
    end
end
if simona2mdf_fieldandvalue(mdf,'filbch')

    %% Harmonical bc
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbch],filpli,mdu.pathmdu,'Harmonic'    ,true);
end
if simona2mdf_fieldandvalue(mdf,'filbct')

    %% Time series bc
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbct],filpli,mdu.pathmdu,'Series'      ,true);
end

%% Same story, this time for the salinity boundaries boundaries
no_bnd  = 0;
filpli  = [];

for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
       ~isempty(strfind(ext_force(i_force).quantity,'salinity'))
        no_bnd = no_bnd + 1;
        index(no_bnd) = i_force;
    end
end

%% Make the list of pli files
for i_bnd = 1: no_bnd
    filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
end

%% Convert salinity boundary conditions
if simona2mdf_fieldandvalue(mdf,'filbcc') && ~isempty(filpli)
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbcc],filpli,mdu.pathmdu,'Salinity',true);
end

%% Same story, this time for the temperature boundaries boundaries
no_bnd  = 0;
filpli  = [];

for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
       ~isempty(strfind(ext_force(i_force).quantity,'temperature'))
        no_bnd = no_bnd + 1;
        index(no_bnd) = i_force;
    end
end

%% Make the list of pli files
for i_bnd = 1: no_bnd
    filpli{i_bnd} = [mdu.pathmdu filesep ext_force(index(i_bnd)).filename];
end

%% Convert salinity temperature boundary conditions
if simona2mdf_fieldandvalue(mdf,'filbcc') && ~isempty(filpli)
    d3d2dflowfm_convertbc ([mdf.pathd3d filesep mdf.filbcc],filpli,mdu.pathmdu,'Temperature',true);
end
