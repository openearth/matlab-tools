function data = velocityprofileVanRijn(Ur, Vr, d, RC, RA, DELm, aR, nrofsigmalevels)
%VELOCITYPROFILEVANRIJN computes the velocity distribution over the
% vertical
%
%   Syntax:
%   data = velocityprofileVanRijn(Ur, Vr, d, RC, RA, DELm, aR, nrofsigmalevels)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 <COMPANY>
%       grasmeij
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 07 Nov 2018
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: velocityprofileVanRijn.m 313 2018-11-07 15:06:28Z grasmeij $
% $Date: 2018-11-07 16:06:28 +0100 (wo, 07 nov 2018) $
% $Author: grasmeij $
% $Revision: 313 $
% $HeadURL: https://repos.deltares.nl/repos/MCS-AMO/trunk/matlab/projects/P1220339-kustgenese-diepe-vooroever/velocityprofileVanRijn.m $
% $Keywords: $

%%
% OPT.keyword=value;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);
%% code


alf1 = 0.5;
alf2 = 1;
zaa = RA/30;
c10 = -1.+log(d./zaa);
c20 = log(alf1.*d./zaa);
c30 = -alf1+alf1*log(alf1.*d./zaa);
if(abs(alf1-1.) < 1.e-6 && abs(alf2-1.) < 1.e-6)
    fac1=1;
end
if(alf1<1)
    fac1 = c10/(c30+0.375*c20);
end
% ur1 is velocity at mid depth in wave direction
ur1 = c20./c10.*Ur.*fac1;
zz = NaN(nrofsigmalevels,1);
zz(1) = aR;
iz = 1:1:nrofsigmalevels;   % Sigma levels
zz(2:end) = aR.*(d./aR).^(iz(1:end-1)./(length(iz)-1));

for i = 1:nrofsigmalevels
    z=zz(i);
    HULP30=-1.+log(30.*d./RA);
    UDELc=Vr*log(30.*DELm/RA)/HULP30;
    UDELw=Ur*log(30.*DELm/RA)/HULP30;
    if DELm>0 && z < DELm
        UC=UDELc*log(30.*z/RC)./log(30.*DELm/RC);
        UCw=fac1*UDELw*log(30.*z/RC)./log(30.*DELm/RC);
    else
        if(z > DELm)
            UC=Vr*log(30.*z/RA)/HULP30;
        end
        if(z >= DELm)
            UCw=fac1*Ur*log(30.*z/RA)/HULP30;
        end
    end
    if(z <= RC/30)
        UC=0.
        UCw=0.
    end
    UCa(i)=UC;
    UCwa(i)=UCw;
    if(z>alf1*d)
        UCw=ur1.*(1.-((z-alf1.*d)./((alf2-alf1).*d)).^3);
    end
    if(z > alf2*d)
        UCw=0;
    end
    UCwa(i)=UCw;
end
data.z = zz;
data.ur1 = ur1;
data.UCa = UCa;
data.UCwa = UCwa;