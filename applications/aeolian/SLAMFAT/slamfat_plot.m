function slamfat_plot(result, varargin)
%SLAMFAT_PLOT  Plot routine for SLAMFAT result structure
%
%   Animates the result from the SLAMFAT result structure. Time-varying
%   parameters for the entire model domain are animated. Time-varying
%   parameters for the downwind model border are plotted.
%
%   Syntax:
%   slamfat_plot(result, varargin)
%
%   Input: 
%   result    = result structure from the slamfat_core routine
%   varargin  = slice:      Time step slice
%               movie:      Filename of movie generated
%
%   Output:
%   None
%
%   Example
%   slamfat_plot(result)
%   slamfat_plot(result, slice, 100)
%
%   See also slamfat_core

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 29 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct( ...
    'slice', 100, ...
    'maxfactor', 0.5, ...
    'window', inf, ...
    'movie', '');

OPT = setproperty(OPT, varargin);

make_movie = ~isempty(OPT.movie) && OPT.movie;

sy = 3;
sx = 2;

%% plot results

ax_t = [1:result.dimensions.time] * result.input.dt;
ax_x = [1:result.dimensions.space] * result.input.dx;

subplots = [];
vlines   = [];

figure;

subplots(1) = subplot(sy,sx,1); hold on;
p1 = plot(ax_x, squeeze(result.output.transport(1,:,:)));
p3 = plot(ax_x, squeeze(result.output.capacity(1,:,:)),':r');
pz = plot(ax_x, result.output.profile(1,:),'-k','LineWidth',2);

xlim([0 max(ax_x)]);
ylim([0 OPT.maxfactor * max(result.output.transport(:))]);
xlabel('distance [m]');
ylabel({'concentration in transport' '[kg/m^3]'});

subplots(2) = subplot(sy,sx,3); hold on;
p2 = plot(ax_x, squeeze(result.output.supply(1,:,:)));

xlim([0 max(ax_x)]);
ylim([0 OPT.maxfactor * max(result.output.supply(:))]);
xlabel('distance [m]');
ylabel({'concentration at bed' '[kg/m^2]'});

grain_size = result.input.bedcomposition.grain_size;
if length(grain_size) > 1
    legend(cellfun(@(x) sprintf('%d',round(x*1e6)), ...
        num2cell(result.input.bedcomposition.grain_size),'UniformOutput',false));
end

subplots(3) = subplot(sy,sx,5); hold on;
p4a = bar(ax_x, zeros(size(ax_x)), 1, 'g');
p4b = bar(ax_x, zeros(size(ax_x)), 1, 'r');

xlim([0 max(ax_x)]);
ylim([-1e-3 1e-3]); %max(max(diff(result.output.supply,[],1))) * [-1 1]);
xlabel('distance [m]');
ylabel({'erosion / accretion' '[kg/m^2]'});

subplots(4) = subplot(sy,sx,2);
plot(ax_t, result.input.wind(:,1,1));

xlim([0 max(ax_t)]);
ylim([0 max(result.input.wind(:))]);
vlines(1) = vline(0);
hline(result.input.threshold(1,1,:));
ylabel('wind speed [m/s]');

subplots(5) = subplot(sy,sx,4);
plot(ax_t, squeeze(result.output.transport(:,end,:)));

xlim([0 max(ax_t)]);
ylim([0 max(max(result.output.transport(:,end,:)))]);
vlines(2) = vline(0);
ylabel({'concentration [kg/m^3]' sprintf('at x = %d m', max(ax_x))});

subplots(6) = subplot(sy,sx,6);
plot(ax_t, squeeze(result.input.wind(:,1,:) .* result.output.transport(:,end,:)));

xlim([0 max(ax_t)]);
ylim([0 max(max(result.input.wind(:,1,:) .* result.output.transport(:,end,:)))]);
vlines(3) = vline(0);
xlabel('time [s]');
ylabel({'throughput [kg/s]' sprintf('at x = %d m', max(ax_x))});

i = 1;
for t = 1:OPT.slice:result.dimensions.time
    
    for i = 1:length(p1)
        set(p1(i),'YData',result.output.transport(t,:,i));
        set(p2(i),'YData',result.output.supply(t,:,i));
        set(p3(i),'YData',result.output.capacity(t,:,i));
        
        set(pz,'YData',result.output.profile(t,:));

        if t > 1
            % compute change in supply over current time slice
            dsupply = sum(sum(diff(result.output.supply(t-OPT.slice:t,:,:),[],1),1),2);
            dsupply1 = dsupply; dsupply1(dsupply< 0) = nan;
            dsupply2 = dsupply; dsupply2(dsupply>=0) = nan;

            set(p4a,'YData',dsupply1);
            set(p4b,'YData',dsupply2);
        end
    end
    
    title(subplots(1), sprintf('t = %d s', round((t-1)*result.input.dt)));
    
    set(vlines, 'XData', ax_t(t) * [1 1]);
    
    if isfinite(OPT.window)
        set(subplots([4 5 6]), 'XLim', ax_t(t) + [-.5 .5] * OPT.window);
    end
    
    if make_movie
        M(i) = getframe(gcf);
    end
    
    i = i + 1;
    
    pause(.1);
     
end

if make_movie
    make_movie_gif(M,5,OPT.movie,1)
    clear M
end
