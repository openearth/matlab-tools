function [udtx, udty, wavetime] = MakeWaveVeloSignal(ubwfor, ubwback, tfor, tback, Tp, Hdirto)
%Makes wave velocity signal based on Van Rijn (2004, 2007)
%
%   Syntax:
%   [udtx, udty] = MakeWaveVeloSignal(ubwfor, ubwback, tfor, tback, Tp, Hdirto)
%
%   Input:
%       ubwfor  = forward peak orbital velocity [m/s]
%       ubwback  = backward peak orbital velocity [m/s]
%       tfor  = forward wave period [s]
%       tfor  = backward wave period [s]
%       Tp = wave spectrum peak period [s]
%       Hdirto = direction where wave go to [degrees]
%
%   Output:
%   udtx = velocity time series in x direction [m/s]
%   udty = velocity time series in y direction [m/s]
%
%   Example
%   [udtx, udty] = MakeWaveVeloSignal(ubwfor, ubwback, tfor, tback, Tp, Hdirto)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       grasmeij
%
%       bart.grasmeijer@deltares.nl
%
%       P.O.Box 177, 2600 MH Delft, The Netherlands
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
% Created: 27 Oct 2017
% Created with Matlab version: 9.2.0.538062 (R2017a)

% $Id: MakeWaveVeloSignal_fast02.m 121 2018-04-23 10:57:50Z grasmeij $
% $Date: 2018-04-23 12:57:50 +0200 (ma, 23 apr 2018) $
% $Author: grasmeij $
% $Revision: 121 $
% $HeadURL: https://repos.deltares.nl/repos/MCS-AMO/trunk/matlab/projects/P1220339-kustgenese-diepe-vooroever/MakeWaveVeloSignal_fast02.m $
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

ntime=200;
nnn = 1:ntime;
dtt=Tp./(ntime);
wavetime = [0 nnn.*dtt];

Pangle=0;
plead1=cos(Pangle/180.*pi);
plead2=sin(Pangle/180.*pi);

itwfor = wavetime<tfor;
udt(itwfor)=ubwfor.*sin(pi.*wavetime(itwfor)/tfor);
udt2(itwfor)=ubwfor.*sin(pi.*(wavetime(itwfor)+dtt)./tfor);
udt1(itwfor)=ubwfor.*sin(pi.*(wavetime(itwfor)-dtt)./tfor);
dudt(itwfor)=Tp./(2.*pi)*(udt2(itwfor)-udt1(itwfor))/(2.*dtt);
udt(itwfor)=plead1*udt(itwfor)+dudt(itwfor)*plead2;
    
itwback = wavetime>=tfor;
udt(itwback)=-ubwback.*sin(pi.*(wavetime(itwback)-tfor)./tback);
udt2(itwback)=-ubwback.*sin(pi.*(wavetime(itwback)+dtt-tfor)./tback);
udt1(itwback)=-ubwback.*sin(pi.*(wavetime(itwback)-dtt-tfor)./tback);
dudt(itwback)=Tp./(2.*pi).*(udt2(itwback)-udt1(itwback))./(2.*dtt);
udt(itwback)=plead1*udt(itwback)+dudt(itwback).*plead2;

udtx=udt*sind(Hdirto);
udty=udt*cosd(Hdirto);



