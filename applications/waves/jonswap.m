function varargout = jonswap(f,varargin)
%jonswap  jonswap spectrum
%
% jon = jonswap(f,'Hm0',Hm0,'Tp',Tp,<keyword,value>) 
%
% returns discretized JONSWAP spectrum at frequencies f, with energy Hm0 and peak
% period Tp. For other keywords, call jonswap(), e.g.
%
% [jon,<factor_normalize>] = jonswap(f,..,'gamma',gamma,'normalize',1)
%
%See also: swan, directional_spreading, waves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Van Oord; TU Delft
%       Gerben J de Boer <gerben.deboer@vanoord.com>; <g.j.deboer@tudelft.nl>
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

% https://code.google.com/p/wafo/source/browse/trunk/wafo25/spec/jonswap.m?r=130
% http://www.maths.lth.se/matstat/wafo/documentation/wafodoc/wafo/spec/jonswap.html
% https://ltth1979.wordpress.com/2012/05/20/jonswap-source-matlab/
% SWAN: swanser.ftn: SUBROUTINE SSHAPE: M. Yamaguchi: Approximate expressions for integral properties
%                    of the JONSWAP spectrum; Proc. JSCE, No. 345/II-1, pp. 149-152, 1984.

OPT.Tp        = [];
OPT.Hm0       = [];
OPT.g         = 9.81;
OPT.gamma     = 3.3;
OPT.method    = 'Yamaguchi'; % 'Goda'
OPT.normalize = 1;
OPT.sa        = 0.07;
OPT.sb        = 0.09;

if nargin==0
    varargout = {OPT};
    return
end
OPT = setproperty(OPT,varargin);

%% Pierson-Moskowitz

    if strcmpi(OPT.method,'Yamaguchi') | strcmpi(OPT.method,'Swan')
       alpha = 1/(0.06533*OPT.gamma.^0.8015 + 0.13467)./16; % Yamaguchi (1984), used in SWAN
    elseif strcmpi(OPT.method,'Goda')
      alpha = 1/(0.23+0.03*OPT.gamma-0.185*(1.9+OPT.gamma)^-1)./16; % Goda
    else
        error(['METHOD UNKNOWN: ',OPT.method])
    end

    pm    = alpha*OPT.Hm0^2*OPT.Tp^-4*f.^-5.*exp(-1.25*(OPT.Tp*f).^-4);

%% apply JONSWAP shape

    jon   = pm.*OPT.gamma.^exp(-0.5*(OPT.Tp*f-1).^2./sigma(f,1./OPT.Tp,OPT.sa,OPT.sb).^2);

%% Optinally correct total energy of user-discretized spectrum to match Hm0, as above methods are only an approximation

    if OPT.normalize
        corr = OPT.Hm0.^2./(16*trapz(f,jon));
        jon  = jon.*corr;
    end

varargout = {jon,corr};

function s = sigma(f,fpeak,sa,sb)

s = repmat(sa, size(f));
s(f > fpeak) = sb;

