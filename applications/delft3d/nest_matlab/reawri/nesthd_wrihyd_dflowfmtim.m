function nesthd_wrihyd_dflowfmtim(filename,bnd,nfs_inf,bndval,add_inf)

% wrihyd_dflowfmtim : writes hydrodynamic bc to a DFLOWFM tim files
%                     first beta version
%
% Set some general parameters
%

no_pnt        = length(bnd.DATA);
no_times      = length(bndval);
kmax          = size(bndval(1).value,2)/2;
[path,~,~]    = fileparts(filename);

%
% cylce over boundary points
%

for i_pnt = 1: no_pnt
    fname       = [path filesep bnd.Name{i_pnt} '.tim'];

    % Comments

    SERIES.Comments{1} = '* COLUMNN=2';
    SERIES.Comments{2} = '* COLUMN1=Time (min) since itdate';

    if lower(bnd.DATA(i_pnt).bndtype) == 'z'
        SERIES.Comments{3} = '* COLUMN2=Waterlevel';
    elseif lower(bnd.DATA(i_pnt).bndtype) == 'c'
        SERIES.Comments{3} = '* COLUMN2=Perpendicular velocity';
    elseif lower(bnd.DATA(i_pnt).bndtype) == 'r'
        SERIES.Comments{3} = '* COLUMN2=Rieman invariant (D3D - flow definition)';
    elseif lower(bnd.DATA(i_pnt).bndtype) == 'p'
         SERIES.Comments{1} = '* COLUMNN=3';
         SERIES.Comments{3} = '* COLUMN2=Perpendicular velocity';
         SERIES.Comments{4} = '* COLUMN3=Tangential velocity';
    elseif lower(bnd.DATA(i_pnt).bndtype) == 'x'
         SERIES.Comments{1} = '* COLUMNN=3';
         SERIES.Comments{3} = '* COLUMN2=Rieman invariant';
         SERIES.Comments{4} = '* COLUMN3=Tangential velocity';
    end

    % Boundary values

    for i_time = 1: no_times

        if isfield(nfs_inf,'time')
        SERIES.Values(i_time,1) = nfs_inf.time(i_time);
        else
        SERIES.Values(i_time,1) = nfs_inf.tstart + (i_time - 1)*nfs_inf.dtmin;
        end

        SERIES.Values(i_time,2) = bndval(i_time).value(i_pnt,1,1);
        if lower(bnd.DATA(i_pnt).bndtype) == 'p' || lower(bnd.DATA(i_pnt).bndtype) == 'x'
            SERIES.Values(i_time,3) = bndval(i_time).value(i_pnt,2,1);
        end
    end

    % Write the series

    SERIES.Values = num2cell(SERIES.Values);
    dflowfm_io_series( 'write',fname,SERIES);

    clear SERIES
end
