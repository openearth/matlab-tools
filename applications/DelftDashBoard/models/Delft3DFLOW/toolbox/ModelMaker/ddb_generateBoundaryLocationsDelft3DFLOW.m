function handles = ddb_generateBoundaryLocationsDelft3DFLOW(handles, id, filename)
%DDB_GENERATEBOUNDARYLOCATIONSDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateBoundaryLocationsDelft3DFLOW(handles, id, varargin)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_generateBoundaryLocationsDelft3DFLOW
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

if ~isempty(handles.Model(md).Input(id).grdFile)
    if ~isempty(handles.Model(md).Input(id).depFile)

        % Clear existing boundaries
        handles.Model(md).Input(id).openBoundaries=[];
        handles.Model(md).Input(id).openBoundaries(1).name='';
        handles.Model(md).Input(id).openBoundaries(1).M1=[];
        handles.Model(md).Input(id).openBoundaries(1).M2=[];
        handles.Model(md).Input(id).openBoundaries(1).N1=[];
        handles.Model(md).Input(id).openBoundaries(1).N2=[];        
        handles.Model(md).Input(id).openBoundaries(1).alpha=0.0;
        handles.Model(md).Input(id).openBoundaries(1).compA='unnamed';
        handles.Model(md).Input(id).openBoundaries(1).compB='unnamed';
        handles.Model(md).Input(id).openBoundaries(1).type='Z';
        handles.Model(md).Input(id).openBoundaries(1).forcing='A';
        handles.Model(md).Input(id).openBoundaries(1).profile='Uniform';
        handles.Model(md).Input(id).openBoundaryNames={''};
        handles.Model(md).Input(id).nrOpenBoundaries=0;        
        handles.Model(md).Input(id).activeOpenBoundary=1;        
        handles.Model(md).Input(id).activeOpenBoundaries=1;        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','openboundaries');
        
        d=handles.Toolbox(tb).Input.sectionLength;
        zmax=handles.Toolbox(tb).Input.zMax;
        
        attName=filename(1:end-4);
        
        handles.Model(md).Input(id).bndFile=[attName '.bnd'];
        
        x=handles.Model(md).Input(id).gridX;
        y=handles.Model(md).Input(id).gridY;
        z=handles.Model(md).Input(id).depth;
        
        % Boundary locations
        handles.Model(md).Input(id).openBoundaries=findBoundarySectionsOnStructuredGrid(handles.Model(md).Input(id).openBoundaries,z,zmax,d);

        nb=length(handles.Model(md).Input(id).openBoundaries);
        handles.Model(md).Input(id).nrOpenBoundaries=nb;
                
        % Initialize boundaries
        t0=handles.Model(md).Input(id).startTime;
        t1=handles.Model(md).Input(id).stopTime;
        nrsed=handles.Model(md).Input(id).nrSediments;
        nrtrac=handles.Model(md).Input(id).nrTracers;
        nrharmo=handles.Model(md).Input(id).nrHarmonicComponents;
        depthZ=handles.Model(md).Input(id).depthZ;
        kcs=handles.Model(md).Input(id).kcs;

        for ib=1:nb
            % Initialize
            handles.Model(md).Input(id).openBoundaries=delft3dflow_initializeOpenBoundary(handles.Model(md).Input(id).openBoundaries,ib, ...
                t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs);
            % Set boundary name in one cell array
            handles.Model(md).Input(ad).openBoundaryNames{ib}=handles.Model(md).Input(id).openBoundaries(ib).name;
        end
        
        handles=ddb_countOpenBoundaries(handles,id);
        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries','visible',1,'active',0);
        
        ddb_saveBndFile(handles.Model(md).Input(id).openBoundaries,handles.Model(md).Input(id).bndFile);
        
    else
        ddb_giveWarning('Warning','First generate or load a bathymetry');
    end
else
    ddb_giveWarning('Warning','First generate or load a grid');
end
