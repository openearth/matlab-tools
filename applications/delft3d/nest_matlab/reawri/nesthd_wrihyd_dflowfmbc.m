function nesthd_wrihyd_dflowfmbc(fileOut,bnd,nfs_inf,bndval,add_inf)

% wrihyd_dflowfmbc  : writes hydrodynamic bc to a DFLOWFM bc file
%                     first beta version
%                     for now, only water level boundaries
%
%% Set some general parameters
no_pnt        = length(bnd.DATA);
no_times      = length(bndval);
kmax          = size(bndval(1).value,2)/2;
itdate        = num2str(nfs_inf.itdate,'%8.8i');
itdate        = [itdate(1:4) '-' itdate(5:6) '-' itdate(7:8)];
[path,~,~]    = fileparts(fileOut);

%% cycle over boundary points
for i_pnt = 1: no_pnt
    %% Type of boundary
    if strcmpi(bnd.DATA(i_pnt).bndtype,'z')  quantity = 'waterlevel'; end

    %% Header information
    ext_force.Chapter          = 'forcing';
    ext_force.Keyword.Name {1} = 'Name';
    ext_force.Keyword.Value{1} = bnd.Name{i_pnt};
    ext_force.Keyword.Name {2} = 'Function';
    ext_force.Keyword.Value{2} = 'timeseries';
    ext_force.Keyword.Name {3} = 'Time-interpolation';
    ext_force.Keyword.Value{3} = 'linear';
    ext_force.Keyword.Name {4} = 'Quantity';
    ext_force.Keyword.Value{4} = 'time';
    ext_force.Keyword.Name {5} = 'Unit';
    ext_force.Keyword.Value{5} = ['minutes since ' itdate '  00:00:00'];
    ext_force.Keyword.Name {6} = 'Quantity';
    ext_force.Keyword.Value{6} = [quantity 'bnd'];
    ext_force.Keyword.Name {7} = 'Unit';
    ext_force.Keyword.Value{7} = 'm';

    %% Series information
    for i_time = 1: no_times
        if isfield(nfs_inf,'time')
            ext_force.values{i_time,1} = nfs_inf.time(i_time)/60 + add_inf.timeZone*60.;    % minutes!
        else
            ext_force.values{i_time,1} = nfs_inf.tstart + (i_time - 1)*nfs_inf.dtmin + add_inf.timeZone*60.;
        end

        ext_force.values(i_time,2) = {bndval(i_time).value(i_pnt,1,1)};
        if lower(bnd.DATA(i_pnt).bndtype) == 'p' || lower(bnd.DATA(i_pnt).bndtype) == 'x'
            ext_force.Values{i_time,3} = {bndval(i_time).value(i_pnt,2,1)};
        end
    end
    
    %% Write the series for induvidual support point
    fileTmp = [path filesep 'tmp_' num2str(i_pnt,'%4.4i') '.bc'];
    dflowfm_io_extfile('write',fileTmp,'ext_force',ext_force,'type','ini');
end

%% Merge individual files
command    = 'copy ';
for i_pnt = 1: no_pnt
    tmp_series = [path filesep 'tmp_' num2str(i_pnt,'%4.4i') '.bc'];
    command    = [ command  tmp_series ' + '];
end
command =[command(1:end-2) fileOut];
system (command);
delete([path filesep 'tmp_*.bc']);   
