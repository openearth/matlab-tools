function [boundary, error] = ddb_ModelMakerToolbox_Delft3DFM_generateBoundaryConditions(handles, boundary)
%DDB_GENERATEBOUNDARYCONDITIONSDELFT3DFLOW  One line description goes here.
%
%   This will determine the amplitude and phases per location
%   a) Makes on row of x's and y's
%   b) Calculates ampltiudes and phases with readtidemodel
%   -> this includes a diffusion if there are NaNs
%   -> uses a linear interpolation to boundary locations
%   c) default is a water level type, can be changed in 'boundaries'
%
%   Syntax:
%   [handles err] = ddb_generateBoundaryConditionsDelft3DFLOW(handles, id, varargin)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%   err      =
%
%   Example
%   ddb_generateBoundaryConditionsDelft3DFLOW
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
error = 1;

try
    
    % Determine what to do: Riemmann, velocity or water level
    igetwl  = 1;
    igetvel = 0;
    
    switch boundary.type
        case{'riemanbnd'}
            igetwl              = 1;
            igetvel             = 1;
        case{'velocitybnd'}
            igetwl              = 0;
            igetvel             = 1;
        case{'uxuyadvectionvelocitybnd'}
            igetwl              = 0;
            igetvel             = 1;
        case{'waterlevelbnd'}
            igetwl              = 1;
            igetvel             = 0;
    end
    
    % Which tidal database?
    ii      = handles.toolbox.modelmaker.activeTideModelBC;
    name    = handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    % Get location, potentially with grid conversion
    cs.name ='WGS 84';
    cs.type ='Geographic';
    [xx yy] = ddb_coordConvert(boundary.x, boundary.y,handles.screenParameters.coordinateSystem,cs);
    
    % Get waterlevels
    if igetwl
        cnst      = nc_varget(tidefile,'tidal_constituents');
        handles.toolbox.tidedatabase.constituentList = cellstr(cnst);
        [lon,lat, gt, depth, conList] = readTideModel(tidefile,'type','h','x',xx,'y',yy,'constituent','all');
        ampz = squeeze(gt.amp)'; phasez = squeeze(gt.phi)';
    end
    
    % Get velocities
    if igetvel        
        % Standard values
        [lon,lat, gt, depth, conList] = readTideModel(tidefile,'type','q','x',xx,'y',yy,'constituent','all','includedepth');
        ampv = squeeze(gt(1).amp)';             phasev =  squeeze(gt(1).phi)';
        ampu = squeeze(gt(2).amp)';             phaseu =  squeeze(gt(2).phi)';
    end
    
    % Constituents
    NrCons=length(conList);
    for i=1:NrCons
        Constituents(i).name=conList{i};
    end
    
    % Set values - to do!!
    k=0; nb = length(boundary.nodes);                 boundary.type = 'waterlevelbnd';
    for n=1:nb
        if strcmpi(boundary.nodes(n).cmptype, 'astronomic')
            for i=1:NrCons
                
                % Set component
                boundary.nodes(n).astronomiccomponents(i).component = Constituents(:,i).name;
                
                switch boundary.type
                    case{'riemanbnd'}

                    
                    
                    
                    case{'velocitybnd'}
                        
                        
                        
                    case{'uxuyadvectionvelocitybnd'}

                        boundary.nodes(n).astronomiccomponents(i).amplitude = ampu(i,n);
                        boundary.nodes(n).astronomiccomponents(i).phase     = phaseu(i,n);
%                         boundary.nodes(n).astronomiccomponents(i).amplitude = ampv(i,n);
%                         boundary.nodes(n).astronomiccomponents(i).phase     = phasev(i,n);
                        
                        % Make values for the bc-file
                        boundary.nodes(n).bc.Function   = 'astronomic';
                        boundary.nodes(n).bc.Quantity1  = 'astronomic component';
                        boundary.nodes(n).bc.Unit1      = '-';
                        boundary.nodes(n).bc.Quantity2  = [boundary.type, ' amplitude'];
                        boundary.nodes(n).bc.Unit2      = 'm';
                        boundary.nodes(n).bc.Quantity3  = [boundary.type, ' phase'];
                        boundary.nodes(n).bc.Unit3      = 'deg';
%                         boundary.nodes(n).bc.Quantity4  = [boundary.type, ' amplitude'];
%                         boundary.nodes(n).bc.Unit4      = 'm';
%                         boundary.nodes(n).bc.Quantity5  = [boundary.type, ' phase'];
%                         boundary.nodes(n).bc.Unit5      = 'deg';
                        
                    case{'waterlevelbnd'}
                        
                        % Set values
                        boundary.nodes(n).astronomiccomponents(i).amplitude = ampz(i,n);
                        boundary.nodes(n).astronomiccomponents(i).phase     = phasez(i,n);
                        
                        % Make values for the bc-file
                        boundary.nodes(n).bc.Function   = 'astronomic';
                        boundary.nodes(n).bc.Quantity1  = 'astronomic component';
                        boundary.nodes(n).bc.Unit1      = '-';
                        boundary.nodes(n).bc.Quantity2  = [boundary.type, ' amplitude'];
                        boundary.nodes(n).bc.Unit2      = 'm';
                        boundary.nodes(n).bc.Quantity3  = [boundary.type, ' phase'];
                        boundary.nodes(n).bc.Unit3      = 'deg';
                end
            end
        end
    end
    error = 0;
catch
    error = 1;
end

