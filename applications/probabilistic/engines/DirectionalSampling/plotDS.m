function plotDS(result, varargin)
%PLOTDS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = plotDS(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   plotDS
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
% Created: 17 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

OPT = struct(...
    'animate',  false,  ...
    'save',     false,  ...
    'MC',       [],     ...
    'idx',      [1 2]   ...
);

OPT = setproperty(OPT, varargin{:});

%% initialize

N = result.Output.Calc;

%% make plot

figure;

c = repmat('cymk',1,ceil(N));

iu1 = OPT.idx(1);
iu2 = OPT.idx(2);

u = vertcat(result.Output.process.u{:});
u = u(:,[iu1 iu2]);
u = u(:);
u = u(~isinf(u));
lim = [min(u) max(u)];

g = linspace(lim(1),lim(2),100);
[gx gy] = meshgrid(g,g);

fac = result.Output.computations/sum(cellfun(@length, result.Output.process.beta(result.Output.exact)));

nm = 0;
it0 = ~OPT.animate*(N-1)+1;
for it = it0:N
    jt0 = (it-1)*OPT.animate+1;
    
    subplot(3,1,[1 2]); hold on;

    % response surface
    if ~isempty(result.Output.process.RS(it).u)
        try
            rsz = reshape(polyvaln(result.Output.process.RS(it).fit,[gx(:) gy(:)]), size(gx));
        catch
            rsz = zeros(size(gx));
        end
    else
        rsz = zeros(size(gx));
    end
    
    if it==it0
        prs = pcolor(gx,gy,rsz); shading flat;
    else
        set(prs,'CData',rsz);
    end
    
    clim(max(max(abs([min(min(rsz)) max(max(rsz))])),1)*[-1 1]);
    
    % MC samples
    if it == it0 && ~isempty(OPT.MC)
        scatter(OPT.MC.Output.u(~OPT.MC.Output.idFail,iu1),OPT.MC.Output.u(~OPT.MC.Output.idFail,iu2),3,'MarkerEdgeColor','k');
        scatter(OPT.MC.Output.u(OPT.MC.Output.idFail,iu1),OPT.MC.Output.u(OPT.MC.Output.idFail,iu2),3,'MarkerEdgeColor','k','MarkerFaceColor','k');
    end
    
    % DS samples
    for jt = jt0:it
        if result.Output.converged(jt)
            if result.Output.exact(jt)
                nm = nm + fac*size(result.Output.process.u{jt},1);
                plot(squeeze(result.Output.process.u{jt}(:,iu1)),squeeze(result.Output.process.u{jt}(:,iu2)),['-x' c(jt)]);
            else
                plot(squeeze(result.Output.process.u{jt}(:,iu1)),squeeze(result.Output.process.u{jt}(:,iu2)),['--x' c(jt)]);
            end
            plot(squeeze(result.Output.process.u{jt}(1,iu1)),squeeze(result.Output.process.u{jt}(1,iu2)),['s' c(jt)]);
            plot(squeeze(result.Output.process.u{jt}(end,iu1)),squeeze(result.Output.process.u{jt}(end,iu2)),['o' c(jt)]);
        else
            plot(squeeze(result.Output.process.u{jt}(1,iu1)),squeeze(result.Output.process.u{jt}(1,iu2)),['s' c(jt)]);
            plot(squeeze(result.Output.process.u{jt}(:,iu1)),squeeze(result.Output.process.u{jt}(:,iu2)),[':x' c(jt)]);
        end
    end
    
    % beta sphere
    [x1,y1] = cylinder(result.Output.process.betamin(it),100);
    [x2,y2] = cylinder(result.Output.process.betath(it),100);
    
    if it==it0
        pbm = plot(x1(1,:),y1(1,:),':k');
        pbt = plot(x2(1,:),y2(1,:),'-k');
    else
        set(pbm,'XData',x1(1,:),'YData',y1(1,:));
        set(pbt,'XData',x2(1,:),'YData',y2(1,:));
    end

    if it==it0
        xlabel('u_1');
        ylabel('u_2');
    end
    
    set(gca,'XLim',lim,'YLim',lim);
    
    beta = result.Output.betas(1:it);
    idx = beta>0;
    Pl = 1-chi2_cdf(beta.^2,2);
    Pl(~idx) = 0;
    Pf = cumsum(Pl,1)./[1:length(beta)]';
    
    title({'Directional sampling with Adaptive Response Surface' sprintf('model runs: %d ; probability of failure: %7.6f', round(nm), Pf(end))});
    
    box on;
    
    % plot failure probability
    subplot(3,1,3); hold on;
    
    if it==it0
        ppf = plot(1:it,Pf,'-r','DisplayName','Directional Sampling');
        
        if ~isempty(OPT.MC)
            plot(1:OPT.MC.Output.Calc,cumsum((OPT.MC.Output.z<0).*OPT.MC.Output.P_corr)./[1:OPT.MC.Output.Calc]','-b','DisplayName','Monte Carlo');
        end
        
        xlabel('P_f');
        ylabel('number of samples');
        legend show;
    else
        set(ppf,'XData',1:it,'YData',Pf);
    end
    
    box on;
   
    if OPT.animate
        drawnow;
        if OPT.save
            print(gcf, '-dpng', sprintf('frame_%04d.png', it));
        end
        pause(.1);
    end
end

