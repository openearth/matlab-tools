function plotDS(varargin)
%PLOTDS Plots results from DS function
%
%   Plots results of DS function. Can also be used to plot intermediate
%   results and create animations by updating data.
%
%   Syntax:
%   plotDS(varargin)
%
%   Input:
%   varargin  = DS result structure
%                   or
%               separate DS result variables in order:
%                   un beta ARS P_f P_e P_a Accuracy Calc Calc_ARS Calc_dir
%                   progress exact notexact converged
%
%   Output:
%   none
%
%   Example
%   plotDS(result)
%   plotDS(un,beta,ARS,P_f,P_e,P_a,Accuracy,Calc,Calc_ARS,Calc_dir,progress,exact,notexact,converged)
%
%   See also DS

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

%% read input

if isempty(varargin)
    error('No data');
else
    if isstruct(varargin{1})
        r = varargin{1};
        f = fieldnames(r.Output);
        for i = 1:length(f)
            eval([f{i} '=r.Output.(f{i});']);
            progress = 1;
        end
    else
        [un beta ARS P_f P_e P_a Accuracy Calc Calc_ARS Calc_dir progress exact notexact converged] = deal(varargin{:});
    end
end

%% plot

fh = findobj('Tag','DSprogress');

% initialize plot
if isempty(fh)
    fh = figure('Tag','DSprogress');

    subplot(3,1,[1 2]); hold on;

    uitable( ...
        'Units','normalized', ...
        'Position',[0.09 0.05 0.82 0.25],...
        'Data', [], ...
        'ColumnName', {'total', 'exact', 'approx', 'not converged' 'model'},...
        'RowName', {'N' 'P' 'Accuracy' 'Ratio'});
end

ax  = findobj(gcf,'Type','axes','Tag','');
uit = findobj(gcf,'Type','uitable');

% create plot grid
lim         = linspace(-10,10,100);
[gx gy]     = meshgrid(lim,lim);

% plot response surface
d = find(ARS.active, 2);

if ARS.hasfit
    dat         = zeros(numel(gx),sum(ARS.active));
    dat(:,d)    = [gx(:) gy(:)];
    rsz         = reshape(polyvaln(ARS.fit,dat), size(gx));

    ph = findobj(fh,'Tag','ARS');
    if isempty(ph)
        ph = pcolor(ax,gx,gy,rsz);
        set(ph,'Tag','ARS');
        colorbar; shading flat;
    else
        set(ph,'CData',rsz)
    end
end

% plot DS samples
up = un.*repmat(beta(:),1,size(un,2));

ph1 = findobj(fh,'Tag','P1');
ph2 = findobj(fh,'Tag','P2');
ph3 = findobj(fh,'Tag','P3');

if isempty(ph1) || isempty(ph2) || isempty(ph3)
    ph1 = scatter(ax,un(~converged,d(1)),un(~converged,d(2)),'MarkerEdgeColor','b');
    ph2 = scatter(ax,up(notexact,  d(1)),up(notexact,  d(2)),'MarkerEdgeColor','r');
    ph3 = scatter(ax,up(exact,     d(1)),up(exact,     d(2)),'MarkerEdgeColor','g');

    set(ph1,'Tag','P1');
    set(ph2,'Tag','P2');
    set(ph3,'Tag','P3');
else
    set(ph1,'XData',un(~converged,d(1)),'YData',un(~converged,d(2)));
    set(ph2,'XData',up(notexact,  d(1)),'YData',up(notexact,  d(2)));
    set(ph3,'XData',up(exact,     d(1)),'YData',up(exact,     d(2)));
end

% plot beta sphere
[x1,y1] = cylinder(ARS.betamin,100);
[x2,y2] = cylinder(ARS.betamin+ARS.dbeta,100);

ph1 = findobj(fh,'Tag','B1');
ph2 = findobj(fh,'Tag','B2');

if isempty(ph1) || isempty(ph2)
    ph1 = plot(ax,x1(1,:),y1(1,:),':k');
    ph2 = plot(ax,x2(1,:),y2(1,:),'-k');

    set(ph1,'Tag','B1');
    set(ph2,'Tag','B2');
else
    set(ph1,'XData',x1(1,:),'YData',y1(1,:));
    set(ph2,'XData',x2(1,:),'YData',y2(1,:));
end

% create labels
xlabel('u_1');
ylabel('u_2');

title(sprintf('%4.3f%%', progress*100));

% update table contents
data = { ...
    length(beta) sum(exact) sum(notexact) sum(~converged)   Calc                ; ...
    P_f          P_e        P_a           ''                Calc_ARS            ; ...
    Accuracy     ''         ''            ''                Calc_dir            ; ...
    ''           P_e/P_f    P_a/P_f       ''                Calc/length(beta)   };

set(uit,'Data',data);
set(ax,'XLim',[min(gx(:)) max(gx(:))],'YLim',[min(gy(:)) max(gy(:))]);

drawnow;