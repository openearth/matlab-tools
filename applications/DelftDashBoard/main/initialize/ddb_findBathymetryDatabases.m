function ddb_findBathymetryDatabases
%DDB_FINDBATHYMETRYDATABASES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_findBathymetryDatabases
%
%   Input:

%
%
%
%
%   Example
%   ddb_findBathymetryDatabases
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

handles=ddb_readTiledBathymetries(handles);

for i=1:handles.bathymetry.nrDatasets
    handles.bathymetry.dataset(i).isAvailable=1;
    switch lower(handles.bathymetry.dataset(i).type)
        case{'netcdftiles'}
            localdir = [handles.bathyDir handles.bathymetry.dataset(i).name filesep];
            % Check if data needs to be updated, because there is a new
            % version, or because the metadata file does not exist
            if handles.bathymetry.dataset(i).update || ~exist([localdir handles.bathymetry.dataset(i).name '.nc'],'file')
                % Data sits on OPeNDAP server
                if strcmpi(handles.bathymetry.dataset(i).URL(1:4),'http')
                    % OpenDAP
                    fname=[handles.bathymetry.dataset(i).URL '/' handles.bathymetry.dataset(i).name '.nc'];
                    if handles.bathymetry.dataset(i).useCache
                        % First copy meta data file to local cache
                        % Try to delete old crap
                        if exist([localdir 'temp.nc'],'file')
                            try
                                delete([localdir 'temp.nc']);
                            end
                        end
                        try
                            if ~exist(localdir,'dir')
                                mkdir(localdir);
                            end
                            % Try to copy nc meta file
                            ddb_urlwrite(fname,[localdir 'temp.nc']);
                            if exist([localdir 'temp.nc'],'file')
                                % Try reading the local file. Sometimes it gets
                                % messed up when you're connected to a network
                                % without internet connection!
                                x0=nc_varget([localdir 'temp.nc'],'x0');
                                movefile([localdir 'temp.nc'],[localdir handles.bathymetry.dataset(i).name '.nc']);
                            end
                            fname = [handles.bathyDir handles.bathymetry.dataset(i).name filesep handles.bathymetry.dataset(i).name '.nc'];
                        catch
                            % If no access to openDAP server possible, check
                            % whether meta data file is already available in
                            % cache
                            if exist([localdir 'temp.nc'],'file')
                                try
                                    delete([localdir 'temp.nc']);
                                end
                            end
                            err=lasterror;
                            disp(err.message);
                            disp(err.identifier);
                            ns=length(err.stack);
                            for ie=1:ns
                                disp(['file : ' err.stack(ie).file]);
                                disp(['name : ' err.stack(ie).name]);
                                disp(['line : ' num2str(err.stack(ie).line)]);
                            end

                            disp(['Connection to OpenDAP server could not be made for bathymetry dataset ' handles.bathymetry.dataset(i).longName ' - try using cached data instead']);
                            fname = [handles.bathyDir handles.bathymetry.dataset(i).name filesep handles.bathymetry.dataset(i).name '.nc'];
                            if exist(fname,'file')
                                % File already exists, continue
                            else
                                % File does not exist, this should produce a
                                % warning
                                disp(['Bathymetry dataset ' handles.bathymetry.dataset(i).longName ' not available!']);
                                handles.bathymetry.dataset(i).isAvailable=0;
                            end
                        end
                    else
                        % Read meta data from openDAP server
                    end
                else
                    % Local
                    fname=[handles.bathymetry.dataset(i).URL filesep handles.bathymetry.dataset(i).name '.nc'];
                    if exist(fname,'file')
                        % File already exists, continue
                    else
                        % File does not exist, this should produce a
                        % warning
                        disp(['Bathymetry dataset ' handles.bathymetry.dataset(i).longName ' not available!']);
                        handles.bathymetry.dataset(i).isAvailable=0;
                    end
                end
            else
              fname = [handles.bathyDir handles.bathymetry.dataset(i).name filesep handles.bathymetry.dataset(i).name '.nc'];
            end
            
            if handles.bathymetry.dataset(i).isAvailable
                
                x0=nc_varget(fname,'x0');
                y0=nc_varget(fname,'y0');
                nx=nc_varget(fname,'nx');
                ny=nc_varget(fname,'ny');
                ntilesx=nc_varget(fname,'ntilesx');
                ntilesy=nc_varget(fname,'ntilesy');
                dx=nc_varget(fname,'grid_size_x');
                dy=nc_varget(fname,'grid_size_y');
                for k=1:length(x0)
                    iav{k}=nc_varget(fname,['iavailable' num2str(k)]);
                    jav{k}=nc_varget(fname,['javailable' num2str(k)]);
                end
                
                handles.bathymetry.dataset(i).horizontalCoordinateSystem.name=nc_attget(fname,'crs','coord_ref_sys_name');
                tp=nc_attget(fname,'crs','coord_ref_sys_kind');
                switch lower(tp)
                    case{'projected','proj','projection','xy','cartesian','cart'}
                        handles.bathymetry.dataset(i).horizontalCoordinateSystem.type='Cartesian';
                    case{'geographic','geographic 2d','geographic 3d','latlon','spherical'}
                        handles.bathymetry.dataset(i).horizontalCoordinateSystem.type='Geographic';
                end
                
                try
                    handles.bathymetry.dataset(i).verticalCoordinateSystem.name=nc_attget(fname,'crs','vertical_reference_level');
                catch
                    handles.bathymetry.dataset(i).verticalCoordinateSystem.name='unknown';
                end
                
                try
                    handles.bathymetry.dataset(i).verticalCoordinateSystem.level=nc_attget(fname,'crs','difference_with_msl');
                catch
                    handles.bathymetry.dataset(i).verticalCoordinateSystem.level=0;
                end

                try
                    handles.bathymetry.dataset(i).verticalCoordinateSystem.units=nc_attget(fname,'crs','vertical_units');
                catch
                    handles.bathymetry.dataset(i).verticalCoordinateSystem.units='m';
                end

                if length(dx)>1
                    handles.bathymetry.dataset(i).refinementFactor=round(double(dx(2))/double(dx(1)));
                else
                    handles.bathymetry.dataset(i).refinementFactor=1;
                end
                
                handles.bathymetry.dataset(i).nrZoomLevels=length(x0);
                for k=1:handles.bathymetry.dataset(i).nrZoomLevels
                    handles.bathymetry.dataset(i).zoomLevel(k).x0=double(x0(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).y0=double(y0(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).nx=double(nx(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).ny=double(ny(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).ntilesx=double(ntilesx(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).ntilesy=double(ntilesy(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).dx=double(dx(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).dy=double(dy(k));
                    handles.bathymetry.dataset(i).zoomLevel(k).iAvailable=double(iav{k});
                    handles.bathymetry.dataset(i).zoomLevel(k).jAvailable=double(jav{k});
                end
                
                
            end
        case{'kaartblad'}
            try
                pth=fileparts(handles.bathymetry.dataset(i).URL);
                firstfile=nc_varget(handles.bathymetry.dataset(i).URL,'urlPath');
                firstfile=squeeze(firstfile(1,:));
                firstfile=[pth '/' firstfile];
%                epsgcode=nc_varget(handles.bathymetry.dataset(i).URL,'projectionEPSGcode',[0 0],[1 1]);
                epsgcode=nc_attget(firstfile,'EPSG','epsg');
                ii=find(handles.EPSG.coordinate_reference_system.coord_ref_sys_code==epsgcode);
                name=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{ii};
                tp=handles.EPSG.coordinate_reference_system.coord_ref_sys_kind{ii};
                switch lower(tp)
                    case{'geographic 2d'}
                        tp='geographic';
                end
                handles.bathymetry.dataset(i).horizontalCoordinateSystem.name=name;
                handles.bathymetry.dataset(i).horizontalCoordinateSystem.type=tp;
            catch
                disp(['Bathymetry dataset ' handles.bathymetry.dataset(i).longName ' not available!']);
                handles.bathymetry.dataset(i).isAvailable=0;
            end
    end
    if ~isfield(handles.bathymetry.dataset(i),'source')
        handles.bathymetry.dataset(i).source=[];
    end
end

disp([num2str(handles.bathymetry.nrDatasets) ' bathymetry datasets found!']);

setHandles(handles);

