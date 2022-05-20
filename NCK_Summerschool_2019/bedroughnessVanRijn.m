function [data] = bedroughnessVanRijn(RMob, D50, D90, d, varargin)
%BEDROUGHNESSVANRIJN computes the bed roughness according to the 
% Van Rijn (2007) formulations
%
%   Syntax:
%   [data] = bedroughnessVanRijn(RMob, d)
%
%   Input:
%   RMob  = mobility parameter
%   D50 = median grain diameter [m]
%   D90 = grain diameter intercept for 90% of the cumulative mass [m]
%   d =  water depth [m]
%
%   Output:
%   data.RCr = current-related roughness due to ripples [m]
%   data.RCmr = computing current-related roughness due to megaripples [m]
%   data.RWr = wave-related roughness due to ripples [m]
%   data.RW = wave-related roughness [m]
%   data.RC = current-related roughness [m]
%   data.aR = reference height [m]
%
%   Example
%   Untitled
%
%   See also tsandv07

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       grasmeij
%
%       bart.grasmeijer@deltares.nl
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
% Created: 06 Nov 2018
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: bedroughnessVanRijn.m 313 2018-11-07 15:06:28Z grasmeij $
% $Date: 2018-11-07 16:06:28 +0100 (wo, 07 nov 2018) $
% $Author: grasmeij $
% $Revision: 313 $
% $HeadURL: https://repos.deltares.nl/repos/MCS-AMO/trunk/matlab/projects/P1220339-kustgenese-diepe-vooroever/bedroughnessVanRijn.m $
% $Keywords: $

%%
OPT.dclay=0.000008;
OPT.dsilt=0.000032;
OPT.dsand=0.000062;
OPT.dgravel=0.002;

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

fcoarse = (0.25.*OPT.dgravel./D50).^1.5;
fcoarse(fcoarse >= 1)=1;

fch2 = D50./(1.5.*OPT.dsand);
if fch2 >= 1
    fch2=1;
end
if fch2< 0.3
    fch2=0.3;
end

disp('computing current-related roughness due to ripples...')
% current-related roughness due to ripples
RCr = zeros(size(RMob));
i_50 = RMob<=50;
i_50_250 = RMob > 50 & RMob <= 250;
i_250 = RMob > 250;
RCr(i_50)=150.*fcoarse.*D50;
RCr(i_50_250)=(-0.65.*RMob(i_50_250)+182.5).*fcoarse.*D50;
RCr(i_250) = 20.*fcoarse.*D50;
if D50 <= OPT.dsilt
    RCr=20.*OPT.dsilt.*ones(size(RMob));
end
RCr(RCr<=D90)=D90;
RCr(RCr>=0.1)=0.1;

disp('computing current-related roughness due to megaripples...')
% current-related roughness due to megaripples in rivers,
% estuaries and coastal seas and represents the larger
% scale bed roughness
RCmr = zeros(size(RMob));
i_50 = RMob<=50;
i_50_550 = RMob > 50 & RMob <= 550;
i_550 = RMob > 550;
RCmr(i_50) = 0.0002.*fch2.*RMob(i_50).*d(i_50);
RCmr(i_50_550) = fch2.*(-0.00002.*RMob(i_50_550)+0.011).*d(i_50_550);
RCmr(i_550)=0.0;
RCmr(RCmr>0.2) = 0.2;
RCmr(RCmr < 0.02 & D50 >= 1.5.*OPT.dsand) = 0.02;
RCmr(RCmr < 0.02 & D50 < 1.5*OPT.dsand) = 200.*(D50./(1.5.*OPT.dsand)).*D50;
if D50 < 1.5*OPT.dsand
    RCmr = 200.*(D50/(1.5*OPT.dsand))*D50.*ones(size(RMob));
end
if D50 <= OPT.dsilt
    RCmr = 0.*ones(size(RMob));
end

% current-related roughness due to dunes in rivers not implemented!!
RCd = zeros(size(RMob));

disp('computing wave-related roughness due to ripples...')
% wave-related roughness due to ripples
i_50 = RMob<=50;
i_50_250 = RMob > 50 & RMob <= 250;
i_250 = RMob > 250;
RWr = zeros(size(RMob));
RWr(i_50) = 150*fcoarse*D50;
RWr(i_50_250)=(-0.65.*RMob(i_50_250)+182.5)*fcoarse*D50;
RWr(i_250) = 20*fcoarse*D50;
if D50 <= OPT.dsilt
    RWr = 20*OPT.dsilt.*ones(size(RMob));
end
RWr(RWr>=0.1)= 0.1;

% sum all roughness values
RC = (RCr.^2 + RCmr.^2 + RCd.^2).^0.5;
RW = RWr;
RC(RC<0.001) = 0.001;

% Van Rijn (2007) reference height aR
aa1 = 0.5*RCr;
aa2 = 0.5*RWr;
aR = max(aa1,aa2);
aR(aR <= 0.01) = 0.01;
aR(aR <= RC/30) = RC(aR <= RC/30)./30 + max(aa1(aR <= RC/30),aa2(aR <= RC/30));


% put all output in a data struct
data.RCr = RCr;
data.RCmr = RCmr;
data.RWr = RWr;
data.RW = RW;
data.RC = RC;
data.aR = aR;