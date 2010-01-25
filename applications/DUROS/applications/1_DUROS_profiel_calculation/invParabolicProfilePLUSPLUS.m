function dx = invParabolicProfile2(WL_t,Hsig_t,Tp_t,w,z)
%INVPARABOLICPROFILE  Calculates the exact x-position of a contour line for in the parabolic profile.
%
%   Based on the (inverse) formulation of a parabolic profile this function 
%   calculates the exact x-position (relative to x0) of a contour line.
%
%   Syntax:
%   dx = invParabolicProfile(WL_t,Hsig_t,Tp_t,w,z)
%
% Input:
%               WL_t      = Water level [m] ('Rekenpeil')
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               w         = fall velocity of the sediment in water
%               z         = vector (n x 1) with z coordinates
%
% Output:       
%       dx   = vector the same size as z with values of the relative 
%               x-position of the contours specified in z
%
%   See also invParabolicProfileMain getParabolicProfile getIerationBounderies getRcParabolicProfile
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

%% Switch method
Plus                                    = DuneErosionSettings('get','Plus');
[c_hs c_tp c_w c_1 c_2]                 = DuneErosionSettings('get','c_hs','c_tp','c_w','c_1','c_2');
[cp_hs cp_tp cp_w]                      = DuneErosionSettings('get','cp_hs','cp_tp','cp_w');
[dx,waveheightcmpt,waveperiodcmpt,fallvelocitycmpt] = deal([]);


%% -------------------------------------------------------------------------------------------- 
%-------------------------------------------DUROS---------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
if strcmp(Plus,'')
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)
    Tp_t = 12;
    c_tp = 12;
    cp_tp = 0;   %waveperiodcmpt = 1

%% -------------------------------------------------------------------------------------------- 
%----------------------------------------DUROS plus-------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
elseif strcmp(Plus,'-plus')
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)

%% --------------------------------------------------------------------------------------------
%--------------------------------------DUROS plusplus------------------------------------------
%----------------------------------------------------------------------------------------------
elseif strcmp(Plus,'-plusplus')
    %overrule c1, c2 and xref with D++ values
    %[c_1 c_2 xref] = DuneErosionSettings('get','c_1plusplus','c_2plusplus','xrefplusplus');
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation for DUROS and D+; by using this expression, the profile will exactly cross (x0,0)
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''')
end

%% Calculate dx step from inverted function
waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;
waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
fallvelocitycmpt = (w/c_w)^cp_w;
dx    = (((-(z-WL_t).*(c_hs/Hsig_t)+two)/c_1).^2-c_2) / (waveheightcmpt*waveperiodcmpt*fallvelocitycmpt);