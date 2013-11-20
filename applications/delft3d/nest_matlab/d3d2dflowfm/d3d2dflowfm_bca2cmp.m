function mdu = d3d2dflow_bca2cmp(mdf,mdu,name_mdu)

ext_force = dflowfm_io_extfile('read',[mdu.pathmdu filesep mdu.external_forcing.ExtForceFile]);

i_bnd = 0;

%% Find the open hydrodynamic boundaries
for i_force = 1: length(ext_force)
    if ~isempty(strfind(ext_force(i_force).quantity,'bnd')) &&  ...
        isempty(strfind(ext_force(i_force).quantity,'salinity'))
        i_bnd = i_bnd + 1;
        index(i_bnd) = i_force;
    end
end
no_bnd = length(index);

%%Find the type of boundary
for i_bnd = 1: no_bnd
    if ~isempty(strfind(ext_force(index(i_bnd)).quantity,'waterlevel'))
        bnd(i_bnd).type = 'Z';
    elseif ~isempty(strfind(ext_force(index(i_bnd)).quantity,'velocity'))
        bnd(i_bnd).type = 'C';
    elseif ~isempty(strfind(ext_force(index(i_bnd)).quantity,'neumann'))
        bnd(i_bnd).type = 'N';
    elseif ~isempty(strfind(ext_force(index(i_bnd)).quantity,'dischargepergridcell'))
        bnd(i_bnd).type = 'Q';
    elseif ~isempty(strfind(ext_force(index(i_bnd)).quantity,'dischargebnd'))
        bnd(i_bnd).type = 'T';
     elseif ~isempty(strfind(ext_force(index(i_bnd)).quantity,'riemann'))
        bnd(i_bnd).type = 'R';
    end
end

%% Determine the type of forcing (temporarly use additional information out of the pli file)
for i_bnd = 1: no_bnd
    LINE = dflowfm_io_xydata('read',[mdu.pathmdu filesep ext_force(index(i_bnd)).filename]);


end










