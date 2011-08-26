function [bn zn n converged] = find_zero_poly2(un, b, z, varargin)
%FIND_ZERO_POLY2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = find_zero_poly2(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   find_zero_poly2
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
% Created: 25 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

OPT = struct(...
    'zFunction',        '',                 ...
    'epsZ',             1e-2,               ...     % precision in stop criterium
    'maxinput',         4,                  ...     % maximum number of known points to use within known interval
    'maxiter',          50,                 ...     % maximum number of iterations
    'maxretry',         1,                  ...     % maximum number of iterations before retry
    'maxorder',         3,                  ...     % maximum order of polynom in line search
    'maxratio',         10                  ...     % maximum ratio between interval boundaries
);

OPT = setproperty(OPT, varargin{:});

%% determine approach

n               = 0;
bn              = [];
zn              = [];

converged       = false;
startsearch     = true;

% check if origin is available, assume it is exact
if any(b==0)
    
    % store origin as scaling factor
    i0 = find(b==0,1,'first');
    z0 = z(i0);
    
    if z(i0)<-OPT.epsZ
        % origin in failure area, abort
        startsearch = false;
    end
    
    if abs(z(i0))<OPT.epsZ
        % origin is design point, abort
        bn          = b(i0);
        zn          = z(i0);
        converged   = true;
        startsearch = false;
    end
end

% check if design point is available, check value
if any(abs(z)<OPT.epsZ)
    
    id = find(abs(z)<OPT.epsZ,1,'first');
    zi = feval(OPT.zFunction, un, b(id));
    
    n  = n+1;
    bn = b(id);
    zn = zi;
    
    if abs(zn)<OPT.epsZ
        % design point already available, abort
        converged   = true;
        startsearch = false;
    end
end

% check if finite interval is available, restrict search
if startsearch && any(z>0) && any(z<0)
    
    n        = ceil(OPT.maxinput/2);
    
    [bu bui] = sort(b(z<0),          'ascend' );
    [bl bli] = sort(b(z>0&b<min(bu)),'descend');
    
    nu       = min([n length(bu)]);
    nl       = min([n length(bl)]);
    
    iu       = ismember(b,bu(1:nu));
    il       = ismember(b,bl(1:nl));
    
    zu       = z(iu);
    zl       = z(il);
    
    % if asymptotic, add extra point in the middle of interval
    if abs(zu(1))/abs(zl(1))>OPT.maxratio || abs(zl(1))/abs(zu(1))>OPT.maxratio
        
        n   = n+1;
        
        bn  = mean([bl(1) bu(1)]);
        zn  = feval(OPT.zFunction, un, bn);
        
    end
        
	% select points closest to zero point    
    b       = [b(il) b(iu)];
    z       = [z(il) z(iu)];
end

%% search zero

if startsearch
        
    while isempty(zn) || abs(zn(end))>OPT.epsZ

        % fit polygon through know points and approximate zero
        p   = polyfit([z zn],[b bn],min([length([b bn])-1 OPT.maxorder]));
        bn  = [bn polyval(p,0)];

        if bn(end)<0
            break;
        else
            n   = n+1;
            zn  = [zn feval(OPT.zFunction, un, bn(end))];
        end

        % if maximum numbers of samples is not yet reached, check if infinity
        % is reached and, if so, start retry search for finite numbers
        if length(zn)<=OPT.maxretry
            while ~isfinite(zn(end))

                bt  = [b bn];
                zt  = [z zn];

                % overwrite infinite values with new approximates
                if length(bt)>1
                    n           = n+1;
                    bn(end)     = mean(bt(end-1:end));
                    zn(end)     = feval(OPT.zFunction, un, bn(end));
                else
                    break;
                end

                if length(zn)>=OPT.maxiter
                    break;
                end
            end
        end

        % give up in case infinity or maximum number of iterations is reached
        if ~isfinite(zn(end)) || length(zn)>=OPT.maxiter
            break;
        end
    end

    if ~isempty(zn) && abs(zn(end))<OPT.epsZ
        converged = true;
    end
    
end
