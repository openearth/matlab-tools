function ARS = prob_ars_set3(b, u, z, varargin)
%PROB_ARS_SET2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_set2(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_set2
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 24 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

OPT = struct(...
    'ARS',      prob_ars_struct,    ...
    'maxZ',     Inf,                ...
    'epsZ',     1e-2,               ...
    'nr_DPs',   1,                  ...
    'n',        1                   ...
);

OPT = setproperty(OPT, varargin{:});

%% add data

if size(OPT.ARS,2)==OPT.n
    ARS             = OPT.ARS(OPT.n);
else
    ARS             = prob_ars_struct_mult;
    ARS.active      = OPT.ARS(1).active;
    ARS.dbeta       = OPT.ARS(1).dbeta;
%     keyboard
end

ARS.b           = [b(:)];
ARS.u           = [u(:,ARS.active)];
ARS.z           = [z(:)];
% ARS.b           = [ARS.b ; b(:)];
% ARS.u           = [ARS.u ; u(:,ARS.active)];
% ARS.z           = [ARS.z ; z(:)];

% remove beta=0 (for mulitple ARS's) test
b               = ARS.b;
u               = ARS.u;
z               = ARS.z;

if OPT.nr_DPs > 1
    ii  = b==0;
    b   = b(~ii);
    u   = u(~ii,:);
    z   = z(~ii);
end
%% fit data

notinf      = all(isfinite(ARS.u),2) & isfinite(ARS.z);
notout      = abs(ARS.z)<=OPT.maxZ;
nva         = sum(ARS.active);

% derive 2nd degree response surface with all cross terms
if length(ARS.z) >= 1+nva+nva*(nva+1)/2

    ARS.fit     = polyfitn(ARS.u(notinf&notout,:), ARS.z(notinf&notout), 2);
 
    if ~any(isnan(ARS.fit.Coefficients)) && ~any(isinf(ARS.fit.Coefficients)) && ARS.fit.RMSE < 1  
        ARS.hasfit  = true;
        i           = find(b == min(b(abs(z(isfinite(z)))<OPT.epsZ)));
        ARS.beta_DP = b(i);
        ARS.u_DP    = u(i,:);
    else 
        ARS.hasfit  = false;
        ARS.fit     = struct();
        ARS.beta_DP = nan;
        ARS.u_DP    = nan(1,sum(ARS.active));
%         keyboard
    end

% derive 2nd degree response surface with no cross terms
elseif length(ARS.z) >= 2*nva+1

    pfmat       = [zeros(1,nva); eye(nva); 2*eye(nva)];
    ARS.fit     = polyfitn(ARS.u(notinf&notout,:), ARS.z(notinf&notout), pfmat);

    if ~any(isnan(ARS.fit.Coefficients)) && ~any(isinf(ARS.fit.Coefficients)) && ARS.fit.RMSE < 1
        ARS.hasfit  = true;
        i           = find(b == min(b(abs(z(isfinite(z)))<OPT.epsZ)));
        ARS.beta_DP = b(i);
        ARS.u_DP    = u(i,:);
    else
        ARS.hasfit  = false;
        ARS.fit     = struct();
        ARS.beta_DP = nan;
        ARS.u_DP    = nan(1,sum(ARS.active));
%         keyboard
    end
else
    ARS.beta_DP = nan;
    ARS.u_DP    = nan(1,sum(ARS.active));
end



% hij werkt vooralsnog alleen als alle variabelen actief zijn. Als niet alle variabelen actief zijn moet de procedure m.i. aangepast worden zodanig dat de ARS-fit alleen op de actieve variabelen wordt uitgevoerd.

% in een later stadium kan de procedure nog verbeterd worden door niet in 1 keer de stap te maken van "geen cross-terms" naar "alle cross-terms". De cross-terms kunnen we eventueel wellicht gradueel laten opvoeren door eerst alleen de cross-terms te introduceren voor de belangrijkste variabelen, d.w.z. de variabelen die de z-functie het sterkst beinvloeden. Maar dit is nog even toekomstmuziek.



