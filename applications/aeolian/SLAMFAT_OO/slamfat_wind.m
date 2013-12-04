classdef slamfat_wind < handle
    %SLAMFAT_WIND  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_wind.slamfat_wind
    
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
    %   version 2.1 of the License, or (at your thision) any later version.
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
    % Created: 05 Nov 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        velocity_mean       = 5
        velocity_std        = 2.5
        gust_mean           = 4
        gust_std            = 4
        duration            = 3600
        dt                  = 0.05
        block               = 1000
        time                = []
        time_series         = []
        number_of_timesteps = 0
    end
    
    properties(Access = private)
        isinitialized       = false
    end
    
    %% Methods
    methods
        function this = slamfat_wind(varargin)
            setproperty(this, varargin);
        end
        
        function wind = generate(this)
            wind = zeros(sum(this.number_of_timesteps),1);
            for i = 1:length(this.duration)
                n_wind  = this.number_of_timesteps(i);
                n_start = sum(round(this.duration(1:i-1)/this.dt)) + 1;

                f_series = [];
                l_series = [];

                while sum(l_series) < this.duration(i)
                    f_series = [f_series     normrnd(this.velocity_mean(i), this.velocity_std(i), this.block, 1)    ]; %#ok<AGROW>
                    l_series = [l_series max(normrnd(this.gust_mean(i),     this.gust_std(i),     this.block, 1), 0)]; %#ok<AGROW>
                end

                n_series = round(l_series / this.dt);
                idx      = find(cumsum(n_series)>=n_wind,1,'first');

                f_series = f_series(1:idx);
                n_series = n_series(1:idx);

                n = n_start;
                for j = 1:length(n_series)
                    n_next = min(n+n_series(j), n_start+n_wind-1);
                    wind(n:n_next) = f_series(j);
                    n = n_next;
                end
            end
            wind(wind<0) = 0;
            
            this.time_series = wind;
        end
        
        function val = get.time_series(this)
            if ~this.isinitialized
                this.generate;
                this.isinitialized = true;
            end
            val = this.time_series;
        end
        
        function val = get.time(this)
            val = [0:sum(this.number_of_timesteps)-1] * this.dt;
        end
        
        function val = get.number_of_timesteps(this)
            val = round(this.duration/this.dt) + 1;
        end
        
        function val = get.velocity_mean(this)
            val = this.unify_series(this.velocity_mean);
        end
        
        function val = get.velocity_std(this)
            val = this.unify_series(this.velocity_std);
        end
        
        function val = get.gust_mean(this)
            val = this.unify_series(this.gust_mean);
        end
        
        function val = get.gust_std(this)
            val = this.unify_series(this.gust_std);
        end
        
        function val = unify_series(this, val)
            if length(this.duration) > 1
                if length(val) == 1
                    val = repmat(val, 1, length(this.duration));
                end
            else
                this.duration = repmat(this.duration, 1, length(val));
            end
        end
        
        function plot(this, fig)
            if nargin < 2
                figure;
            else
                figure(fig);
            end
            
            plot(this.time, this.time_series);
            
            xlabel('time [s]');
            ylabel('wind speed [m/s]');
            
            set(gca,'XLim',[0 max(this.time)]);
        end
    end
end
