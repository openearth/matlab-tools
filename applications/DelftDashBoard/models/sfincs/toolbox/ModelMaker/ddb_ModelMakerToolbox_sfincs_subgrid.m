function ddb_ModelMakerToolbox_sfincs_subgrid(varargin)
%DDB_MODELMAKERTOOLBOX_BATHYMETRY master function for bathy in DDB
%
%   When generateBathymetry is used first handles are loaded
%   1) A specific 'bathy generate' per model is applied
%   2) All these functions came back to ddb_ModelMakerToolbox_generateBathymetry
%   3) Bathys in the order presented and interpolation to model grid
%   4) End with diffusion and model offset

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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_ModelMakerToolbox_bathymetry.m 18438 2022-10-12 16:23:14Z ormondt $
% $Date: 2022-10-12 12:23:14 -0400 (Wed, 12 Oct 2022) $
% $Author: ormondt $
% $Revision: 18438 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_bathymetry.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    ddb_refreshScreen;
    setHandles(handles);
    ddb_plotModelMaker('deactivate');

else
    
    %Options selected
    opt=lower(varargin{1});
    
    switch opt
        case{'generatesubgrid'}
            generate_subgrid;
    end
    
end

%% 
function generate_subgrid

handles=getHandles;

id=ad;

subgridfile='sfincs.sbg';

nbin=handles.toolbox.modelmaker.sfincs.subgrid.nbin;
refi=handles.toolbox.modelmaker.sfincs.subgrid.refi;
refj=refi;
uopt=[];
ndeep=handles.toolbox.modelmaker.sfincs.subgrid.manning_deep_value;
nlev=handles.toolbox.modelmaker.sfincs.subgrid.manning_deep_level;

maxdzdv=handles.toolbox.modelmaker.sfincs.subgrid.maxdzdv;

inp=handles.model.sfincs.domain(id).input;
msk=handles.model.sfincs.domain(id).mask;

for ii=1:handles.toolbox.modelmaker.sfincs.bathymetry.nrSelectedDatasets
    nr=handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(ii).number;
    bathy(ii).name=handles.bathymetry.datasets{nr};
    bathy(ii).zmin=handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(ii).zMin;
    bathy(ii).zmax=handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(ii).zMax;
    bathy(ii).verticaloffset=handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(ii).verticalLevel;
end

cs=handles.screenParameters.coordinateSystem;

manning_input=[0.02 0.04 1.0];

try
%     wb      = waitbox('Generating sub-grid file ...');
    subgrd=sfincs_make_subgrid_file([],[],bathy,manning_input,cs,nbin,refi,refj,uopt,maxdzdv,'input',inp,'mask',msk,'bathymetry_database',handles.bathymetry,'manning_deep_value',ndeep,'manning_deep_level',nlev);
    if ~isempty(subgrd)
        sfincs_write_binary_subgrid_tables(subgrd,msk,nbin,subgridfile,uopt);
        handles.model.sfincs.domain(id).input.sbgfile=subgridfile;
    end    
%     close(wb);
catch
%     close(wb);
    ddb_giveWarning('error','Sorry, an error occurred while generating the subgrid file!');
end
setHandles(handles);
