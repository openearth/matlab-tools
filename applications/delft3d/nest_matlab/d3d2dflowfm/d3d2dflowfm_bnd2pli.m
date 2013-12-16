function varargout = d3d2dflowfm_bnd2pli(filgrd,filbnd,filpli,varargin)

% d3d2dflowfm_bnd2pli: genarates pli file for D-Flow FM out of a D3D bnd file

% initialisation
OPT.Salinity          = false;
OPT                   = setproperty(OPT,varargin);
[path_pli,name_pli,~] = fileparts(filpli);

% Read the grid: OET-style
G           = delft3d_io_grd('read',filgrd);
xc          = G.cend.x';
yc          = G.cend.y';
mmax        = size(xc,1);
nmax        = size(xc,2);
nr_harm     = 0;

% Read the boundary file
D           = delft3d_io_bnd('read',filbnd);
mbnd        = D.m;
nbnd        = D.n;
no_bnd      = size(mbnd,1);

% Determine (x,y)-values of boundary points
for ibnd=1:no_bnd
    for iside=1:2
        xb(ibnd,iside) = xc(mbnd(ibnd,iside),nbnd(ibnd,iside));
        yb(ibnd,iside) = yc(mbnd(ibnd,iside),nbnd(ibnd,iside));
    end
end

% Reshape the boundary locations into polylines
irow         = 1;                     % is number of points in the polyline
iline        = 1;                     % is number of polylines

% Set initial boundary orientation
dir_old = 'n';
if mbnd(1,1) == mbnd(1,2);
    dir_old = 'm';
end

for ibnd = 1 : no_bnd;

    % Change in orientation or jump of more than 1 cell ==> new polyline
    if ibnd > 1;
        if mbnd(ibnd,1) == mbnd(ibnd,2)
            dir       = 'm';
            diff      = abs(mbnd(ibnd,1) - mbnd(ibnd-1,2));
        else
            dir       = 'n';
            diff      = abs(nbnd(ibnd,1) - nbnd(ibnd-1,2));
        end
        if ~strcmp(dir,dir_old) || diff > 1
            dir_old   = dir;
            iline     = iline + 1;
            irow      = 1;
        end
    end

    % Astronomical boundary conditions?
    astronomical = false;
    timeseries   = false;
    harmonic     = false;
    if strcmpi(D.DATA(ibnd).datatype,'a');
        astronomical  = true;
    end
    if strcmpi(D.DATA(ibnd).datatype,'t');
        timeseries    = true;
    end
    if strcmpi(D.DATA(ibnd).datatype,'h');
        harmonic      = true;
    end

    % Fill LINE struct for side A
    LINE(iline).DATA{irow,1} = xb(ibnd,1);
    LINE(iline).DATA{irow,2} = yb(ibnd,1);
    string = sprintf(' %1s %1s ',D.DATA(ibnd).bndtype,D.DATA(ibnd).datatype);
    if astronomical && ~OPT.Salinity;
        string = [string D.DATA(ibnd).labelA];
    end
    if timeseries   ||  OPT.Salinity;
        bcname                = D.DATA(ibnd).name;
        bcname(bcname==' ')   = [];
        string = [string bcname 'sideA'];
    end
    if harmonic     && ~OPT.Salinity;
        nr_harm = nr_harm + 1;
        string  = [string num2str(nr_harm,'%04i') 'sideA'];
    end
    LINE(iline).DATA{irow,3} = string;

    % Fill LINE struct for side B (avoid double points by checking if it is not first point of next boundary segment)

    if ~(xb(ibnd,2) == xb(min(ibnd + 1,no_bnd),1) && yb(ibnd,2) == yb(min(ibnd +1,no_bnd),1))
       irow = irow + 1;
       LINE(iline).DATA{irow,1} = xb(ibnd,2);
       LINE(iline).DATA{irow,2} = yb(ibnd,2);
       string = sprintf(' %1s %1s ',D.DATA(ibnd).bndtype,D.DATA(ibnd).datatype);
       if astronomical && ~OPT.Salinity;
           string = [string D.DATA(ibnd).labelB];
       end
       if timeseries   || OPT.Salinity;
           bcname                = D.DATA(ibnd).name;
           bcname(bcname==' ')   = [];
           string = [string bcname 'sideB'];
       end
       if harmonic     && ~OPT.Salinity;
           string  = [string num2str(nr_harm,'%04i') 'sideB'];
       end
       LINE(iline).DATA{irow,3} = string;
    end
    irow = irow + 1;
end

% Write the pli-files for the separate polygons

for ipol = 1: length(LINE)

    %
    % Blockname = name of the file
    %

    if ~OPT.Salinity
       LINE(ipol).Blckname=[name_pli '_' num2str(ipol,'%3.3i')];
       dflowfm_io_xydata ('write',[filpli '_' num2str(ipol,'%3.3i') '.pli'],LINE(ipol));
    else
       LINE(ipol).Blckname=[name_pli '_' num2str(ipol,'%3.3i') '_sal'];
       dflowfm_io_xydata ('write',[filpli '_' num2str(ipol,'%3.3i') '_sal.pli'],LINE(ipol));
    end

    %
    % Fil varargout for later wriing of the file names to the external forcing file
    %

    if nargout > 0;
        filext{ipol} = [LINE(ipol).Blckname '.pli'];
    end
end

% now, write all polylines (only for hydrodynamic bc)

if ~OPT.Salinity
   dflowfm_io_xydata ('write',[filpli '_all.pli'],LINE);
end

varargout = {filext};
