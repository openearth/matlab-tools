classdef slamfat_threshold < handle
    %SLAMFAT_THRESHOLD  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_threshold.slamfat_threshold
    
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
    % Created: 07 Nov 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        time                    = [] % [s]
        tide                    = [] % [m]
        rain                    = [] % [mm]
        solar_radiation         = [] % [J/m^2]
        initial_moisture        = .003
        porosity                = .4
        penetration_depth       = 10 % [mm]
        air_temperature         = 10 % [oC]
        latent_heat             = 2.45 % [MJ/kg]
        atmospheric_pressure    = 101.325 % [kPa]
        air_specific_heat       = 1.0035 % [J/g/K]
        relative_humidity       = .4
        
        method_moisture         = 'belly_johnson'
    end
    
    properties(Access = private)
        t                   = 0
        dt                  = 0
        profile             = []
        wind                = []
        moisture            = []
        isinitialized       = false
    end
    
    %% Methods
    methods(Static)
        function s = vaporation_pressure_slope(T)
            s = 4098 * 0.6108 * exp((17.27 * T) / (T - 237.3)) / (T + 237.3)^2;
        end
        
        function vp = saturation_pressure(T)
            T  = T + 273.15;
            A  = -1.88e-4;
            B  = -13.1;
            C  = -1.5e-2;
            D  =  8e-7;
            E  = -1.69e-11;
            F  =  6.456;
            vp = exp(A/T + B + C*T + D*T^2 + E*T^3 + F*log(T));
        end
    end
    
    methods
        function this = slamfat_threshold(varargin)
            %SLAMFAT_THRESHOLD  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = slamfat_threshold(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "slamfat_threshold"
            %
            %   Example
            %   slamfat_threshold
            %
            %   See also slamfat_threshold
            
            setproperty(this, varargin);
        end
        
        function initialize(this, profile)
            if ~this.isinitialized
                this.t        = 0;
                this.dt       = 0;
                this.profile  = profile;
                this.moisture = this.initial_moisture * ones(size(profile));
                
                this.isinitialized = true;
            end
        end
        
        function threshold = maximize_threshold(this, threshold, dt, profile, wind)
            this.t       = this.t + this.dt;
            this.dt      = dt;
            this.profile = profile;
            this.wind    = wind;
            
            if this.isinitialized
                %threshold = this.apply_bedslope   (threshold);
                %threshold = this.apply_evaporation(threshold);
                threshold = this.apply_tide       (threshold);
                %threshold = this.apply_rain       (threshold);
                %threshold = this.apply_salt       (threshold);
            else
                error('threshold module is not initialized');
            end
        end
        
        function threshold = apply_bedslope(~, threshold)
        end
        
        function threshold = apply_tide(this, threshold)
            if ~isempty(this.tide)
                idx = this.profile <= this.interpolate_time(this.tide);
                this.moisture(idx) = this.porosity;
                threshold = this.threshold_from_moisture(threshold);
            end
        end
        
        function threshold = apply_rain(this, threshold)
            if ~isempty(this.rain)
                rainfall = this.interpolate_time(this.rain);
                this.moisture = min(this.moisture + rainfall ./ this.penetration_depth, this.porosity);
                threshold = this.threshold_from_moisture(threshold);
            end
        end
        
        function threshold = apply_evaporation(this, threshold)
            if ~isempty(this.solar_radiation)
                radiation = this.interpolate_time(this.solar_radiation);
                m = this.vaporation_pressure_slope(this.air_temperature);
                delta = saturation_pressure(this.air_temperature) * (1 - this.relative_humidity);
                gamma = (this.air_specific_heat * this.atmospheric_pressure) / (.622 * this.latent_heat);
                evaporation = max(0, (m * radiation + gamma * 6.43 * (1 + 0.536 * this.wind) * delta) / ...
                    (this.latent_heat * (m + gamma)) / 24 / 3600 * this.dt);
                this.moisture = max(this.moisture - evaporation ./ this.penetration_depth, 0);
                threshold = this.threshold_from_moisture(threshold);
            end
        end
        
        function threshold = apply_salt(~, threshold)
        end
        
        function threshold = threshold_from_moisture(this, threshold)
            moist = repmat(this.moisture', 1, size(threshold,2));
            
            switch this.method_moisture
                case 'belly_johnson'
                    threshold_moist = threshold .* (1.8 + 0.6 .* log10(moist));
                case 'hotta'
                    threshold_moist = threshold + 7.5 .* moist;
                otherwise
                    error('Unknown moisture formulation [%s]', this.method_moisture);
            end
            threshold(this.moisture > .005,:) = threshold_moist(this.moisture > .005,:);
            threshold(this.moisture > .04 ,:) = inf;
        end
        
%         function val = get.tide(this)
%             val = this.unify_series(this.tide);
%         end
%         
%         function val = get.rain(this)
%             val = this.unify_series(this.rain);
%         end
%         
%         function val = get.solar_radiation(this)
%             val = this.unify_series(this.solar_radiation);
%         end
%         
%         function val = unify_series(this, val)
%             if length(this.time) > 1
%                 if length(val) == 1
%                     val = repmat(val, 1, length(this.time));
%                 end
%             end
%             if length(val) > length(this.time)
%                 val = val(1:length(this.time));
%             elseif length(val) < length(this.time)
%                 this.time = this.time(1:length(val));
%             end
%         end
        
        function val = interpolate_time(this, data)
            if length(data) > 1
                val = interp1(this.time, data, this.t);
            else
                val = data;
            end
        end
    end
end
