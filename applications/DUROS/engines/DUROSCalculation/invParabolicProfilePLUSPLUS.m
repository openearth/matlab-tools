function dx = invParabolicProfile(WL_t,Hsig_t,Tp_t,w,z)
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
Plus = DuneErosionSettings('get','Plus');

if strcmp(Plus,'') | strcmp(Plus,'-plus')
    if strcmp(Plus,'') && Tp_t~=12
        Tp_t = 12;
    end

    %% Retrieve settings
    [c_hs c_tp c_1 cp_hs cp_tp cp_w c_w] = DuneErosionSettings('get','c_hs','c_tp','c_1','cp_hs','cp_tp','cp_w','c_w');

    %% Calculate x position
    dx = (((-(z-WL_t).*(c_hs/Hsig_t)+c_1*sqrt(18))/c_1).^2-18) / (((c_hs/Hsig_t).^cp_hs)*((c_tp/Tp_t).^cp_tp)*((w/c_w).^cp_w));

elseif (strcmp(Plus,'-plusplus1') | strcmp(Plus,'-plusplus2') | strcmp(Plus,'-plusplus3') | strcmp(Plus,'-plusplus4') | strcmp(Plus,'-plusplus5'))
%---------------------------------------------------------------------------------------------- 
%---------------------------------DUROS plusplus (variant 1)-----------------------------------
%---------------------------------------------------------------------------------------------- 
    [c_hs c_tp c_1 c_2 cp_hs cp_tp cp_w c_w cp_d c_d d_t] = DuneErosionSettings('get','c_hs','c_tp','c_1','c_2','cp_hs','cp_tp','cp_w','c_w','cp_d','c_d','d');
    if strcmp(Plus,'-plusplus1')
        %option 1: only coeff. cfA&cfB
        A        = 0.4714;
        B        = 18.0000;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = -0.415038533300256; %A not influenced by Hs/d if cfA=0
        cfB      = -1.8656390445347; %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus2')
        %option 2: only coeff. cfA&cfB
        A        = 0.3193;
        B        = 17.2098;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = -1.234048201; %A not influenced by Hs/d if cfA=0
        cfB      = -2.989234623; %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus3')
        %option 3: only coeff. d
        A        = 0.4714;
        B        = 18.0000;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = -0.38;        %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus4')
        %option 4: only coeff. d
        A        = 0.4714;
        B        = 18.0000;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = -0.17;        %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus5')
        %option 5: only coeff. A&B
        A        = 1.2773;
        B        = 490.9486;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0
    end

    %including depth contribution into the 'constants' C1, C2 and 'two'
    c_1 = A*(Hsig_t/d_t)^cfA;
    c_2 = B*(Hsig_t/d_t)^cfB;
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation for DUROS and D+; by using this expression, the profile will exactly cross (x0,0)
    depthcmpt        = (d_t/refdepth)^d;
    fallvelocitycmpt = (w/c_w)^cp_w;
    waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
    waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;
    
    dx      = (((-(z-WL_t).*(c_hs/Hsig_t)+c_1*sqrt(c_2))/c_1).^2-c_2) / (waveheightcmpt*waveperiodcmpt*fallvelocitycmpt*depthcmpt);
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''')
end
