classdef slamfat_plot < handle
    %SLAMFAT_PLOT  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_plot.slamfat_plot
    
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
    %   This library is free software: you can redistribute it and/or
    %   modify it under the terms of the GNU Lesser General Public
    %   License as published by the Free Software Foundation, either
    %   version 2.1 of the License, or (at your option) any later version.
    %
    %   This library is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %   Lesser General Public License for more details.
    %
    %   You should have received a copy of the GNU Lesser General Public
    %   License along with this library. If not, see <http://www.gnu.org/licenses/>.
    %   --------------------------------------------------------------------
    
    % This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
    % OpenEarthTools is an online collaboration to share and manage data and
    % programming tools in an open source, version controlled environment.
    % Sign up to recieve regular updates of this function, and to contribute
    % your own tools.
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: 06 Nov 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        figure          = []
        subplots        = struct()
        axes            = struct()
        lines           = struct()
        hlines          = []
        vlines          = []
        colorbars       = []
        
        hide_profile    = true
        timestep        = 1
        
        sy              = 10
        sx              = 1
        window          = inf
        
        obj             = []
    end
    
    properties(Access = private)
        isinitialized           = false
        animating               = false
    end
    
    %% Methods
    methods(Static)
        function cmap = colormap(n)
            if nargin == 0
                n = 100;
            end
            nn   = round(1.1*n);
            cmap = flipud(1 - linspace(1,0,nn)' * [0 1 1]);
            cmap = cmap([1 end-n+2:end],:);
        end

        function e = handleKeyPress(this, ~, event)
            e = 0;
            switch(event.Key)
                case 'leftarrow'
                    if ismember('shift',event.Modifier)
                        this.move(-1);
                    else
                        this.move(-100);
                    end
                case 'rightarrow'
                    if ismember('shift',event.Modifier)
                        this.move(1);
                    else
                        this.move(100);
                    end
                case 'space'
                    this.toggle_animate;
            end
        end
    end
    
    methods
        function this = slamfat_plot(varargin)
            %SLAMFAT_PLOT  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = slamfat_plot(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "slamfat_plot"
            %
            %   Example
            %   slamfat_plot
            %
            %   See also slamfat_plot
            
            setproperty(this, varargin);
            
            if ~isempty(this.obj)
                this.update;
            end
        end
        
        function initialize(this)
            if ~this.isinitialized || ~ishandle(this.figure)
                
                this.figure          = [];
                this.subplots        = struct();
                this.axes            = struct();
                this.lines           = struct();
                this.hlines          = [];
                this.vlines          = [];
                this.colorbars       = [];
        
                this.timestep = max(1,this.obj.output_timestep);
                
                nx = this.obj.number_of_gridcells;
                nf = this.obj.bedcomposition.number_of_fractions;
                nl = this.obj.bedcomposition.number_of_actual_layers;
                th = this.obj.bedcomposition.layer_thickness;

                this.axes = struct();
                this.axes.t_out = this.obj.output_time;
                this.axes.t_in  = this.obj.wind.time;
                this.axes.x     = [1:this.obj.number_of_gridcells] * this.obj.dx;

                this.figure = figure;
                set(this.figure,'keypressfcn',@(obj,event) this.handleKeyPress(this,obj,event));

                % set colormap
                colormap(this.colormap);

                % set figure dimensiond
                pos    = get(this.figure,'Position');
                pos(4) = pos(4) * 2;
                set(gcf,'Position',pos);

                % plot profile
                this.subplots.profile = subplot(this.sy,this.sx,1:5); hold on;

                f1 = squeeze(this.obj.data.profile(1,:));
                f2 = squeeze(this.obj.data.d50(:,:,:)) * 1e6;

                this.lines.d50          = pcolor(repmat(this.axes.x,nl,1),repmat(f1,nl,1) - repmat([0:nl-1]',1,nx).*th',squeeze(f2(1,:,:))');
                this.lines.profile      = plot(this.axes.x,f1,'-k','LineWidth',2);
                this.lines.capacity     = plot(this.axes.x,zeros(nx,nf),':k');
                this.lines.transport    = plot(this.axes.x,zeros(nx,nf),'-k');

                set(this.subplots.profile,'XTick',[]);
                ylabel(this.subplots.profile, {'surface height [m]' 'transport concentration [kg/m^3]'});

                xlim(this.subplots.profile, minmax(this.axes.x));
                ylim(this.subplots.profile, [-.01 .01]); %max(.01,max(abs(f1(:)))) * [-.01 .01]);
                clim(this.subplots.profile, [min(f2(:)) max(f2(:))] + [0 1000]);

                box on;

                this.colorbars.profile = colorbar;
                ylabel(this.colorbars.profile,'Median grain size [\mum]');

                % plot supply limitation indicator
                this.subplots.supply_limited = subplot(this.sy,this.sx,6); hold on;
                this.lines.supply_limited    = pcolor(repmat(this.axes.x,2,1),repmat([0;1],1,nx),zeros(2,length(this.axes.x)));

                set(this.subplots.supply_limited,'YTick',[]);
                xlabel(this.subplots.supply_limited, 'distance [m]');

                xlim(this.subplots.supply_limited, minmax(this.axes.x));
                ylim(this.subplots.supply_limited, [0 1]);
                clim(this.subplots.supply_limited, [0 nf]);

                box on;

                this.colorbars.supply_limited = colorbar;
                set(this.colorbars.supply_limited,'YTick',[]);
                ylabel(this.colorbars.supply_limited,{'Supply' 'limitations'});

                cmap = this.colormap(nf+1);

                % plot wind time series
                this.subplots.wind = subplot(this.sy,this.sx,7:8); hold on;

                f1 = squeeze(this.obj.wind.time_series);
                this.lines.wind = plot(this.axes.t_in,f1,'-k');
                this.hlines.wind = hline(squeeze(this.obj.bedcomposition.threshold_velocity),'-r');
                this.vlines = [this.vlines vline(0,'-b')];

                set(this.subplots.wind,'XTick',[]);
                ylabel(this.subplots.wind,'wind speed [m/s]');

                xlim(this.subplots.wind, minmax(this.axes.t_out));
                ylim(this.subplots.wind, [0 max(abs(f1(:))) + 1e-3]);
                clim(this.subplots.wind, [0 nf]);

                box on;

                this.colorbars.wind = colorbar;
                set(this.colorbars.wind,'YTick',1:nf,'YTickLabel',fliplr(this.obj.bedcomposition.grain_size * 1e6));
                ylabel(this.colorbars.wind,'Grain size fraction [\mum]');

                for i = 1:length(this.hlines.wind)
                    set(this.hlines.wind(i),'Color',cmap(nf-i+2,:));
                end

                % plot transport time series
                this.subplots.transport = subplot(this.sy,this.sx,9:10); hold on;

                f1 = squeeze(this.obj.data.transport(:,end,:));
                f2 = squeeze(this.obj.data.capacity(:,end,:));

                this.lines.capacity_t = plot(this.axes.t_out,f2,'-k');
                this.lines.transport_t = plot(this.axes.t_out,f1,'-k');
                this.vlines = [this.vlines vline(0,'-b')];

                xlabel(this.subplots.transport, 'time [s]');
                ylabel(this.subplots.transport, {'transport concentration' 'and capacity [kg/m^3]'});

                xlim(this.subplots.transport, minmax(this.axes.t_out));
                ylim(this.subplots.transport, [0 max(abs(f1(:))) + 1e-3]);
                clim(this.subplots.transport, [0 nf]);

                box on;

                this.colorbars.transport = colorbar;
                set(this.colorbars.transport,'YTick',1:nf,'YTickLabel',this.obj.bedcomposition.grain_size * 1e6);
                ylabel(this.colorbars.transport,'Grain size fraction [\mum]');

                for i = 1:length(this.lines.transport_t)
                    set(this.lines.transport_t(i),'Color',cmap(i+1,:));
                end
                
                this.isinitialized = true;
            end
            
            this.reinitialize;
        end
        
        function this = reinitialize(this)
            nf = this.obj.bedcomposition.number_of_fractions;

            f1 = squeeze(this.obj.data.transport(:,end,:));
            f2 = squeeze(this.obj.data.capacity(:,end,:));

            for i = 1:nf
                set(this.lines.capacity_t(i),  'YData', f2(:,i));
                set(this.lines.transport_t(i), 'YData', f1(:,i));
            end
            
            f3 = squeeze(this.obj.data.d50(:,:,:)) * 1e6;
            clim(this.subplots.profile, [max([0 min(f3(f3~=0))]) max([1;f3(:)])]);
            
            f1 = squeeze(this.obj.data.transport(:,end,:));
            ylim(this.subplots.transport, [0 max(abs(f1(:))) + 1e-3]);
        end
        
        function this = update(this)
            
            if ~this.isinitialized || ~ishandle(this.figure)
                this.initialize;
            elseif this.obj.output_timestep < this.obj.size_of_output
                this.reinitialize;
            end
            
            ot = this.timestep;
            it = this.timestep;
            nx = this.obj.number_of_gridcells;
            nf = this.obj.bedcomposition.number_of_fractions;
            nl = this.obj.bedcomposition.number_of_actual_layers;
            th = this.obj.bedcomposition.layer_thickness;
            
            f1  = squeeze(this.obj.data.profile(ot,:));
            f2  = squeeze(this.obj.data.d50(ot,:,:))' * 1e6;
            f3  = squeeze(sum(this.obj.data.supply_limited(ot,:,:),3));

            if this.hide_profile
                f1 = f1 - this.obj.initial_profile;
            end
            
            set(this.lines.profile, 'YData', f1);
            set(this.lines.d50,     'YData', repmat(f1,nl,1) - repmat([0:nl-1]',1,nx).*th', ...
                                    'CData', f2);
            set(this.lines.supply_limited, 'CData', repmat(f3(:)',2,1));

            for i = 1:nf
                f4 = squeeze(this.obj.data.transport(ot,:,i));
                f5 = squeeze(this.obj.data.capacity(ot,:,i));
                set(this.lines.transport(i), 'YData', f4);
                set(this.lines.capacity(i),  'YData', f5);
            end

            title(this.subplots.profile, sprintf('t = %d s (%d%%)', round((it-1)*this.obj.wind.dt), round(it/this.obj.wind.number_of_timesteps*100)));

            set(this.vlines, 'XData', this.axes.t_out(ot) * [1 1]);

            if isfinite(this.window)
                set([this.subplots.wind this.subplots.transport], 'XLim', this.axes.t_out(ot) + [-.5 .5] * this.window);
            end

            drawnow;
        end
        
        function this = move(this, n)
            if nargin < 2
                n = 1;
            end
            this.timestep = max(1,min(this.obj.size_of_output,this.timestep + n));
            this.update;
        end
        
        function this = reset(this)
            this.timestep = 1;
            this.update;
        end
        
        function toggle_animate(this)
            if this.animating
                this.animating = false;
            else
                this.animating = true;
                this.animate;
            end
        end
        
        function animate(this)
            while this.timestep < this.obj.size_of_output && this.animating
                this.update;
                this.timestep = this.timestep + 1;
            end
        end
        
        function delete(this)
            if ishandle(this.figure)
                close(this.figure);
            end
        end
    end
end