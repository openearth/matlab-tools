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
    'maxiter',          50,                 ...     % maximum number of iterations
    'maxretry',         1,                  ...     % maximum number of iterations before retry
    'maxorder',         2,                  ...     % maximum order of polynom in line search
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

% remove nan's
b   = b(~isnan(z));
z   = z(~isnan(z));

%% search zero

if startsearch
        
    while isempty(zn) || abs(zn(end))>OPT.epsZ
        
        ii          = ~ismember(b,bn);
        
        b           = [b(ii) bn];
        z           = [z(ii) zn];

        % set model evaluations in order of absolute z-value
        order       = min(OPT.maxorder, length(z)-1);
        ii          = isort(abs(z));
        
        % check if finite interval is available, and if so, preserve it
        if any(z>0) && any(z<0)
            il      = ii(z>=0);
            iu      = ii(z<0);
            
            ni      = ceil((order+1)/2);
            nl      = min(ni,length(il));
            nu      = min(ni,length(iu));
            
            ii      = [il(1:nl) iu(1:nu)];
            ii      = ii(isort(abs(z(ii))));
            
            % remove outliers
            while max(abs(z(ii)))/min(abs(z(ii)))>OPT.maxratio
                if length(ii)>2
                    npos    = sum(z(ii)>=0);
                    nneg    = sum(z(ii)<0);
                    
                    if npos<2
                        ii(find(z(ii)<0,1,'last')) = [];
                    elseif nneg<2
                        ii(find(z(ii)>=0,1,'last')) = [];
                    else
                        ii(end) = [];
                    end
                else
                    n       = n+1;
        
                    bn      = [bn mean(b(ii))];
                    zn      = [zn feval(OPT.zFunction, un, bn(end))];
                    
                    im      = ~ismember(b,bn);
                    
                    b       = [b(im) bn];
                    z       = [z(im) zn];
                    
                    ii      = [ii length(z)];
                    ii      = ii(isort(abs(z(ii))));
                    
                    order   = min(OPT.maxorder, length(ii)-1);
                    
                    break;
                end
                
                order       = min(OPT.maxorder, length(ii)-1);
            end
        end
        
        ii          = ii(1:order+1);
        
        % select evaluations closest to z is zero
        [zs bs]     = deal(z(ii), b(ii));
        
        % fit polynom to selected points and decrease order until a real
        % root is found
        for o = order:-1:1
            
            p       = polyfit(bs(1:o+1), zs(1:o+1), o);
            
            if all(isfinite(p))
                rts     = sort(roots(p));
                oi1     = isreal(rts);
                oi2     = rts>0;

                if any(oi1)

                    % select the smallest positive real root, if available,
                    % or the smallest negative real root otherwise
                    if any(oi1&oi2)
                        b0 = min(rts(oi1&oi2));
                    else
                        b0 = max(rts(oi1));
                    end

                    break;
                end
            end
        end
    
        % skip negative beta values
        if b0<0
            break;
        else
            
            n   = n+1;
            
            % add new beta and z-value
            bn  = [bn b0];
            zn  = [zn feval(OPT.zFunction, un, bn(end))];
            
        end

        % if maximum numbers of samples is not yet reached, check if
        % infinity is reached and, if so, start retry search for finite
        % numbers
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

        % give up in case infinity or maximum number of iterations is
        % reached
        if ~isfinite(zn(end)) || length(zn)>=OPT.maxiter
            break;
        end
        
        % give up in case new value is not closer to zero
        if all(abs(zn(end))>abs(zs))
            break;
        end
    end

    if ~isempty(zn) && abs(zn(end))<OPT.epsZ
        converged = true;
    end
    
end
