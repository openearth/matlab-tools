function [XB calcdir] = xb_generate_model_2D(X, Y, Z, varargin)
% XB_GENERATE_MODEL_2D  place tag of selected object in editable textbox 
%
%See also: xbeach

% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section 
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

%% optional: draw points thinned out to allow for quick dataselection (reduce number of points)

% first draw the data by scattering the datapoints
figure; 

if length(X)<=10000 % when there are less than 10000 datapoints show all ...
    scatter(X, Y, 5, Z, 'filled');
else % ... otherwise randomly draw 10000 datapoints and show them
    rd_ids = randi(length(X),10000,1);
    scatter(X(rd_ids), Y(rd_ids), 5, Z(rd_ids), 'filled'); hold on
    
    % when the thinned out option is selected draw the convex hull as well to give an idea of the coverage of the randomly selected points
    ids = convhull(X, Y);
    lh = line(X(ids),Y(ids),Z(ids));
    set(lh,'color','r')
end
axis equal

% next select the area of focus by applying the crosshair (right-click to close)
ginp    = polydraw;
polygon = [ginp.x; ginp.y]';
ids     = inpolygon(X, Y, polygon(:,1), polygon(:,2));
X       = X(ids);
Y       = Y(ids);
Z       = Z(ids);

%% take the data through the XBeach grid orientor
% - first click the most seaward point of left boundary (viewed seaward from the beach)
% - next click the most landward point of the left boundary
% - finally click the alongshore extent

[X_xb Y_xb Z_xb alfa propertyCell] = XBeach_GridOrientation(X, Y, Z,...
    'manual', true);

%% select within the newly oriented grid the outline of the xb grid
% make sure to select the grid inside of the available selected data
XB = XBeach_selectgrid(X_xb, Y_xb, Z_xb,...
    'manual', true,...
    CreateEmptyXBeachVar,...
    propertyCell{:},...
    'alfa', alfa,...
    'posdwn', -1);

%% create input
OPT.calcdir = uigetdir(mfilename('fullpath'), 'Select XBeach calculation directory');
OPT.Hsig_t  = 1.5; % m
OPT.Tp_t    = 8;   % s

%% write spectrum file
[spectrumfilename, ext, XB] = XBeach_write_jonswap(...
    'Hm0', OPT.Hsig_t,...
    'XB', XB,...
    'fp', 1/OPT.Tp_t,...
    'gammajsp', 3.3,...
    's', 5,...
    'mainang', 270,...
    'fnyq', 1,...
    'dfj', [],...
    'calcdir', OPT.calcdir);

% clear variables which are not applicable as such anymore
XB.settings.Waves.dir0      = [];
XB.settings.Flow.epsi       = [];
XB.settings.SedInput.dico   = [];
XB.settings.SedInput.A      = [];

%% write input file
XBeach_Write_Inp(OPT.calcdir, XB,...
    'xfile',     'x.grd', ...
    'yfile',     'y.grd', ...
    'depfile', 'bed.dep');

%% generate output
calcdir = OPT.calcdir;
