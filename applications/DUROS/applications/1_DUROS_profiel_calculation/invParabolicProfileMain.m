function dx = invParabolicProfileMain(WL_t,Hsig_t,Tp_t,w,z)
%INVPARABOLICPROFILEMAIN  Diverts to the correct function that calculates the relative x-position.
%
%   This main function diverts calculation of the x-position of a contour 
%   line (relative to x0) based on the inverse of the parabolic profile
%   to the function specified in DuneErosionSettings
%
% Syntax:
%       dx = invParabolicProfile(WL_t,Hsig_t,Tp_t,w,z)
%
% Input:
%       WL_t      = Water level [m] ('Rekenpeil')
%       Hsig_t    = wave height [m]
%       Tp_t      = peak wave period [s]
%       w         = fall velocity of the sediment in water
%       z         = vector (n x 1) with z coordinates
%
% Output:       
%       dx        = vector the same size as z with values of the relative 
%                       x-position of the contours specified in z
%
%   See also invParabolicProfile getIerationBounderies DuneErosionSettings
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Retrieve settings

fcnHandle = DuneErosionSettings('invParabolicProfileFcn');
invprofileArgs = DuneErosionSettings('invParabolicProfileFcnInput');

invprofileArgs(strcmp(invprofileArgs,'#PARHS_T')) = {Hsig_t};
invprofileArgs(strcmp(invprofileArgs,'#PARTP_T')) = {Tp_t};
invprofileArgs(strcmp(invprofileArgs,'#PARW')) = {w};
invprofileArgs(strcmp(invprofileArgs,'#PARZ')) = {z};
invprofileArgs(strcmp(invprofileArgs,'#PARWL_T')) = {WL_t};
invprofileArgs(strcmp(invprofileArgs,'#PARD')) = {DuneErosionSettings('get','d')};

%% Calculate rc of parabolic profile
dx = feval(fcnHandle,invprofileArgs{:});
