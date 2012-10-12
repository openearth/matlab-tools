function [b_DPs b_other u_DPs u_other z_DPs z_other iii] = prob_ars_design_point_detection(b, u, z, varargin)
%PROB_ARS_DESIGN_POINT_DETECTION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_design_point_detection(varargin)
%
%   Input: For <keyword,value> pairs call prob_ars_design_point_detection() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_design_point_detection
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 05 Oct 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings

OPT = struct(...
    'ARS', [], ...
    'epsZ',             1e-2,                   ...                         % Precision for Z=0
    'dist_betamin',     0.5                     ...                         % Distance criterium for detecting separate design points           
);

OPT = setproperty(OPT, varargin{:});

%% Detect design points

i       = abs(z)<OPT.epsZ;                                                  % Determine which points have Z=0
iii     = 0;

b_DPs   = b(i);                                                             % Saves corresponding betas
u_DPs   = u(i,:);
z_DPs   = z(i);

b_other = b(~i,:);
u_other = u(~i,:);
z_other = z(~i);

ii      = isort(b_DPs);

betamin = b_DPs(ii(1));                                                     % Find smallest beta for Z=0 points

ii      = b_DPs<(betamin*(1+max([OPT.ARS.dbeta])));                             % Find other points with close to the same beta

b_other = [b_other; b_DPs(~ii,:)];                                          % Points that are not design points
u_other = [u_other; u_DPs(~ii,:)];                                          
z_other = [z_other; z_DPs(~ii)];

b_DPs   = b_DPs(ii,:);                                                      % Design points
u_DPs   = u_DPs(ii,:);                                                      
z_DPs   = z_DPs(ii);

distances   = pointdistance_pairs(u_DPs,u_DPs);                             % Calculate distances between design points
distances   = triu(distances);                                              % Remove duplicate distances

[im in] = find(distances < (OPT.dist_betamin)^(1/(size(u_DPs,2)-1)) ...     % Check distances between design points are large enough for them to be treated as 
    & distances > 0);                                                       % separate points

io = false(size(b_DPs));

if size(im,1)>0
    for i = 1:size(im,1)
        io = b_DPs == max(b_DPs(im(i)),b_DPs(in(i))) | io;                  % If two points are too close together, discard the one with the larger beta
    end
    
    b_other = [b_other; b_DPs(io,:)];                                       % Add it to the 'other' points
    u_other = [u_other; u_DPs(io,:)];
    z_other = [z_other; z_DPs(io)];
    
    b_DPs   = b_DPs(~io,:);                                                 % Remove it from the design points
    u_DPs   = u_DPs(~io,:);
    z_DPs   = z_DPs(~io);
end

%% Cluster points to DP

if size(z_DPs,1)>1
    distances = pointdistance_pairs(u_DPs,u_other);                         % calculate distances from other points to design points
    [d iii] = min(distances);                                               % Locate closest Design Point for each other point
end