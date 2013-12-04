classdef slamfat_bedcomposition_basic < handle
    %SLAMFAT_BEDCOMPOSITION  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_bedcomposition.slamfat_bedcomposition
    
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
        number_of_gridcells     = 100
        number_of_fractions     = 1
        number_of_layers        = 1
        
        source              = []
        
        grain_size          = 255e-6
        distribution        = 1
        porosity            = .4
        bed_density         = 1600
        grain_density       = 2650
        air_density         = 1.25
        water_density       = 1025
        
        initial_mass_unit   = 0
        
        g                   = 9.81
        A                   = 100
        dt                  = 0.05
 
        threshold_velocity  = []
    end
    
    properties(Access = protected)
        mass                = []
        isinitialized       = false
    end
    
    %% Methods
    methods
        function this = slamfat_bedcomposition_basic(varargin)
            %SLAMFAT_BEDCOMPOSITION  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = slamfat_bedcomposition(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "slamfat_bedcomposition"
            %
            %   Example
            %   slamfat_bedcomposition
            %
            %   See also slamfat_bedcomposition
            
            setproperty(this, varargin);
        end
        
        function initialize(this)
            if ~this.isinitialized

                % source
                if isempty(this.source)
                    this.number_of_fractions = 1;
                    this.source = zeros(this.number_of_gridcells,1);
                end
                
                this.mass = zeros(this.number_of_gridcells,1);
            end
        end
        
        function dz = deposit(this, mass)
            this.mass = this.mass + mass;
            dz = zeros(size(mass))';
        end
        
        function data = output(~, data, ~)
            % no output
        end
        
        function val = get.threshold_velocity(this)
            % Bagnold formulation for threshold velocity:
            %     u* = A * sqrt(((rho_p - rho_a) * g * D) / rho_p)
            val = this.A * sqrt(((this.bed_density - this.air_density) .* ...
                  this.g .* this.grain_size) ./ this.bed_density);
        end
        
        function mass = get_top_layer_mass(this)
            mass = this.mass;
        end
        
        function val = get_number_of_actual_layers(this)
            val = this.number_of_layers;
        end
        
        function val = get.number_of_fractions(this)
            val = length(this.grain_size);
        end
        
        function val = get.grain_density(this)
            val = this.unify_series(this.grain_density);
        end
        
        function val = get.bed_density(this)
            val = this.unify_series(this.grain_density * (1-this.porosity));
        end
        
        function val = get.distribution(this)
            val = this.unify_series(this.distribution);
            val = val ./ sum(val); % normalize
        end
        
        function val = get.initial_mass_unit(this)
            val = repmat(this.bed_density .* this.distribution, this.number_of_gridcells, 1);
        end
        
        function val = unify_series(this, val)
            if length(this.grain_size) > 1
                if length(val) == 1
                    val = repmat(val, 1, length(this.grain_size));
                end
            else
                this.grain_size = repmat(this.grain_size, 1, length(val));
            end
        end
    end
end
