function [bn zn n converged] = find_zero_poly4(un, b, z, varargin)
%find_zero_poly4 
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
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
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 27 Sep 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings
OPT = struct(...
    'animate',          false,              ...
    'zFunction',        '',                 ...
    'maxorder',         2,                  ...    
    'maxiter',          5,                  ...                             % Maximum iterations for finding z=0
    'maxbisiter',       5,                  ...
    'epsZ',             1e-2                ...                             % precision in stop criterium
);

OPT = setproperty(OPT, varargin{:});

%% Initialise

n           = 0;
iter        = 0;
bisiter     = 0;
b0          = [];
bn          = [];
zn          = [];
converged   = false;
        
%% Check for origin (b=0)

if ~any(b == 0)
    keyboard
    b   = [0 b];
    z   = [feval(OPT.zFunction, un, b(1)) z];
    
    n   = n + 1;
elseif any(b == 0) && z(b == 0) <= 0
    error('Failure at origin.');
end

%% approximate results handling

% check if beta value for which z=0 is already available
if ~converged && any(abs(z)<OPT.epsZ)
    
    id = find(abs(z)<OPT.epsZ,1,'first');
    zi = feval(OPT.zFunction, un, b(id));
    
    n  = n+1;
    bn = b(id);
    zn = zi;
    
    z(id)   = zi;
    
    if abs(zn)<OPT.epsZ
        % limit state already available, abort
        converged   = true;
    end
end

%% Line search by fitting polynomial

while iter < OPT.maxiter && ~converged 
    
    % Use bisection when encountering NaN of Inf
    if any(isnan(z)) || any(isinf(z))
        break
    end
    
    order   = min(OPT.maxorder, length(z)-1);

    for o = order:-1:1
        
        ii  = isort(abs(z));
        zs  = z(ii(1:(o+1)));
        bs  = b(ii(1:(o+1)));
        
        p   = polyfit(bs, zs, o);                                                   % Fit polynomial through points
        
        % continue if fit does not have any singularities
        if all(isfinite(p))
            
            % compute roots
            rts     = sort(roots(p));
            
            % continue of roots are found
            if ~isempty(rts)
                
                % select real and positive roots separately
                oi1     = isreal(rts);
                oi2     = rts > 0;
                
                % continue if a real root is found
                if any(oi1)
                    
                    % select the positive real root closest to the
                    % points with smallest z-values, if available, or
                    % the smallest negative real root otherwise
                    if any(oi1&oi2)
                        ii = find(oi1&oi2);
                        ii = ii(isort(rts(ii)));
                        b0 = rts(ii(1));
                    else
                        b0 = max(rts(oi1));
                    end
                end
            end
        end
        
        % Evaluate zFunction at b0
        if ~isempty(b0)
            n   = n + 1;
            
            b   = [b b0];
            z0  = feval(OPT.zFunction, un, b0);
            z   = [z z0];
            bn  = [bn b0];
            zn  = [zn z0];
            
            if OPT.animate
                plot_progress(OPT,b0,b,z,bs,zs,bn,zn,p);
            end
            
            b0  = [];
        end
            
        iter    = iter + 1;
        
        if abs(z(end))<OPT.epsZ && b(end)>0
            converged = true;
%             fprintf('Found Z=0 with polynomial fit! \n')
            break
        end
    end
end

%% Line search by bisection

if ~converged
    
    % remove nan's from initial results
    b = b(~isnan(z));
    z = z(~isnan(z));
    while ~converged && bisiter < OPT.maxbisiter
        ii  = isort(abs(z));
        
        if bisiter == 0
            if any(z<0)
                ii  = isort(b);
                iu  = ii(find(z(ii)<0 ,1 ,'first'));

                il  = ii(find(b(ii)<b(iu),1,'last'));
            elseif ~any(z<0) && ~any(b == 8.3)
                b   = [b 8.3];
                bn  = [bn 8.3];
                zu  = feval(OPT.zFunction, un, bn(end));
                n   = n + 1;
                
                z   = [z zu];
                zn  = [zn zu];
                
                ii  = isort(abs(z));
                il  = ii(b(ii)==0);
                iu  = ii(b(ii)==8.3);
            else
                il  = ii(b(ii)==0);
                iu  = ii(2);
            end
        elseif bisiter > 0 && z(end) < 0
            iu  = ii(z(ii)==z(end));
        elseif bisiter > 0 && z(end) > 0
            if abs(z(end)) > abs(zs(1)) && abs(z(end)) <= abs(zs(2))
                iu  = ii(z(ii)==z(end));
            elseif abs(z(end)) <= abs(zs(1)) && abs(z(end)) > abs(zs(2)) 
                il  = ii(z(ii)==z(end));
            elseif abs(z(end)) > abs(zs(1)) && abs(z(end)) > abs(zs(2))
                if abs(zs(1)) > abs(zs(2))
                    il  = ii(z(ii)==z(end));
                elseif abs(zs(1)) <= abs(zs(2))
                    iu  = ii(z(ii)==z(end));
                end
            elseif abs(z(end)) <= abs(zs(1)) && abs(z(end)) <= abs(zs(2))
                if abs(zs(1)) > abs(zs(2))
                    il  = ii(z(ii)==z(end));
                elseif abs(zs(1)) <= abs(zs(2))
                    iu  = ii(z(ii)==z(end));
                end
            end
        elseif bisiter > 0 && isnan(z(end))
            iu  = ii(b(ii)==b0);
        end
        bs  = [b(il) b(iu)];
        zs  = [z(il) z(iu)];
        b0  = mean(bs);
        z0  = feval(OPT.zFunction, un, b0);
        b   = [b b0];
        z   = [z z0];
        bn  = [bn b0];
        zn  = [zn z0];
        
        if OPT.animate && exist('p')
            plot_progress(OPT,b0,b,z,bs,zs,bn,zn,p);
        end
        
        n   = n + 1;
        bisiter     = bisiter + 1;
        
        if ~isnan(z0)
            OPT.maxbisiter  = 10;                                           % Use more iterations when encountering NaN's
        end

        if abs(z(end))<OPT.epsZ && b(end)>0
            converged = true;
%             fprintf('Found Z=0 with bisection! \n')
        end
    end
end

% remove nan's from final results
bn  = bn(~isnan(zn));
zn  = zn(~isnan(zn));

function plot_progress(OPT,b0,b,z,bs,zs,bn,zn,p)

    brange = max(abs([b0 b bn]))+1;
    zrange = max(abs([z zn]))+1;
    
    fh = findobj('Tag','LSprogress');

    % initialize plot
    if isempty(fh)
        fh = figure('Tag','LSprogress'); hold on;
    end
    
    ax  = findobj(fh,'Type','axes','Tag','');

    % original data
    ph = findobj(ax,'Tag','LSpath1');
    if isempty(ph)
        ph = plot(ax,b,z,'xk');
        set(ph,'Tag','LSpath1','DisplayName','initial');
    else
        set(ph,'XData',b,'YData',z);
    end
    
    % added data
    ph = findobj(ax,'Tag','LSpath2');
    if isempty(ph)
        ph = plot(ax,bn,zn,'xr');
        set(ph,'Tag','LSpath2','DisplayName',sprintf('added (%d)',length(zn)));
    else
        set(ph,'XData',bn,'YData',zn,'DisplayName',sprintf('added (%d)',length(zn)));
    end
    
    % selected data
    ph = findobj(ax,'Tag','LSpath3');
    if isempty(ph)
        ph = plot(ax,bs,zs,'og');
        set(ph,'Tag','LSpath3','DisplayName','selected');
    else
        set(ph,'XData',bs,'YData',zs);
    end
    
    % poly fit
    grb = linspace(-brange,brange,100);
    grz = polyval(p, grb);
    
    ph = findobj(ax,'Tag','LSpoly');
    if isempty(ph)
        ph = plot(ax, grb, grz, '-b','DisplayName','fit');
        set(ph,'Tag','LSpoly');
    else
        set(ph,'XData',grb,'YData',grz);
    end
    
    % zero location
    ph = findobj(ax,'Tag','LSzero');
    if isempty(ph)
        ph = plot(ax,b0,0,'or','MarkerFaceColor','r');
        set(ph,'Tag','LSzero','DisplayName','root');
    else
        set(ph,'XData',b0,'YData',0);
    end
    
    % layout
    grid(ax,'on');
    xlabel(ax,'\beta');
    ylabel(ax,'z');
    
    title(ax,func2str(OPT.zFunction));
    
    legend(ax,'-DynamicLegend','Location','NorthWest');
    legend(ax,'show');
    
    set(ax,'XLim',brange*[-1 1],'YLim',zrange*[-1 1]);
    
    drawnow;