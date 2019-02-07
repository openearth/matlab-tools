function nesthd_wrihyd_dflowfmtim(fileOut,bnd,nfs_inf,bndval,add_inf)

% wrihyd_dflowfmbc  : writes hydrodynamic bc to a DFLOWFM bc file
%                     first beta version
%                     for now, only water level boundaries
%
%% Set some general parameters
no_pnt        = length(bnd.DATA);
no_times      = length(bndval);
kmax          = size(bndval(1).value,2)/2;

%% cycle over boundary points
for i_pnt = 1: no_pnt
    %% Type of boundary
    if strcmpi(bnd.DATA(i_pnt).bndtype,'z')  quantity = 'waterlevel'; end

    %% Header information
    ext_force(i_pnt).Chapter          = 'Forcing';
    ext_force(i_pnt).Keyword.Name {1} = 'Name';
    ext_force(i_pnt).Keyword.Value{1} = bnd.Name{i_pnt};
    ext_force(i_pnt).Keyword.Name {2} = 'Function';
    ext_force(i_pnt).Keyword.Value{2} = 'timeseries';
    ext_force(i_pnt).Keyword.Name {3} = 'Time-interpolation';
    ext_force(i_pnt).Keyword.Value{3} = 'linear';
    ext_force(i_pnt).Keyword.Name {4} = 'Quantity';
    ext_force(i_pnt).Keyword.Value{4} = 'time';
    ext_force(i_pnt).Keyword.Name {5} = 'Unit';
    ext_force(i_pnt).Keyword.Value{5} = ['minutes since ' num2str(nfs_inf.itdate,'%8.8i') '  00:00:00'];
    ext_force(i_pnt).Keyword.Name {6} = 'Quantity';
    ext_force(i_pnt).Keyword.Value{6} = [quantity 'bnd'];
    ext_force(i_pnt).Keyword.Name {7} = 'Unit';
    ext_force(i_pnt).Keyword.Value{7} = 'm';

    %% Series information
    for i_time = 1: no_times
        if isfield(nfs_inf,'time')
            ext_force(i_pnt).values{i_time,1} = nfs_inf.time(i_time)/60 + add_inf.timeZone*60.;    % minutes!
        else
            ext_force(i_pnt).values{i_time,1} = nfs_inf.tstart + (i_time - 1)*nfs_inf.dtmin + add_inf.timeZone*60.;
        end

        ext_force(i_pnt).values(i_time,2) = {bndval(i_time).value(i_pnt,1,1)};
        if lower(bnd.DATA(i_pnt).bndtype) == 'p' || lower(bnd.DATA(i_pnt).bndtype) == 'x'
            ext_force(i_pnt).Values{i_time,3} = {bndval(i_time).value(i_pnt,2,1)};
        end
    end
end

%% Write the series
dflowfm_io_extfile('write',fileOut,'ext_force',ext_force,'type','ini');
