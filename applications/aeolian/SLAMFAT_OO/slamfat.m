classdef slamfat < handle
    %SLAMFAT  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat.slamfat
    
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
        dx                      = 1
        relaxation              = 0.5
        g                       = 9.81
        relative_velocity       = 1
        output_timesteps        = 100
        output_time             = []
        size_of_output          = 0
        
        transport               = []
        capacity                = []
        supply                  = []
        supply_limited          = []
        
        source_maximalization   = 'none'
        threshold_maximalization= 'none'
        
        data                    = struct()
        timestep                = 0
        output_timestep         = 0
        
        profile                 = zeros(1,100)
        wind                    = slamfat_wind
        bedcomposition          = slamfat_bedcomposition
        visualization           = @slamfat_plot
        
        animate                 = false;
    end
    
    properties(Access = private)
        it                      = 2
        io                      = 1
        transport_transportltd  = []
        transport_supplyltd     = []
        fig                     = []
        initial_profile         = []
        isinitialized           = false
    end
    
    %% Methods
    methods
        function this = slamfat(varargin)
            setproperty(this, varargin);
        end
        
        function initialize(this)
            if ~this.isinitialized

                this.bedcomposition.number_of_gridcells = this.number_of_gridcells;
                this.bedcomposition.initialize;

                this.transport              = this.empty_matrix;
                this.transport_transportltd = this.empty_matrix;
                this.transport_supplyltd    = this.empty_matrix;
                this.supply                 = this.empty_matrix;
                this.capacity               = this.empty_matrix;

                n  = this.size_of_output;
                nx = this.number_of_gridcells;
                nf = this.bedcomposition.number_of_fractions;
                nl = this.bedcomposition.number_of_actual_layers;

                this.data = struct(                     ...
                    'profile',          zeros(n,nx),    ...
                    'transport',        zeros(n,nx,nf), ...
                    'supply',           zeros(n,nx,nf), ...
                    'capacity',         zeros(n,nx,nf), ...
                    'supply_limited',   false(n,nx,nf), ...
                    'd50',              zeros(n,nx,nl));
                
                this.initial_profile = this.profile;
                
                this.isinitialized = true;
            end
        end
        
        function run(this)
            this.initialize;
            
            if this.animate
                this.plot;
            end
            
            this.output;
            
            while this.it < this.wind.number_of_timesteps
                this.next;
                this.output;
            end
        end
        
        function next(this)
            
            if this.isinitialized
                
                threshold = this.get_maximum_threshold;
                
                % transport capacity according to Bagnold
            	this.capacity = max(0, 1.5e-4 * ((this.wind.time_series(this.it-1) - threshold).^3) ./ ...
                                                 (this.wind.time_series(this.it-1) * this.relative_velocity));
            
                % transport limited concentration
                this.transport_transportltd(2:end,:) = ((-this.relative_velocity * this.wind.time_series(this.it-1) .* ...
                    (this.transport(2:end,:) - this.transport(1:end-1,:)) / this.dx) * this.wind.dt + ...
                     this.transport(2:end,:) + this.capacity(2:end,:) / (this.relaxation / this.wind.dt)) / (1 + 1/(this.relaxation/this.wind.dt));
                
                % supply limited concentration
                this.transport_supplyltd(2:end,:)    = (-this.relative_velocity * this.wind.time_series(this.it-1) .* ...
                    (this.transport(2:end,:) - this.transport(1:end-1,:)) / this.dx) * this.wind.dt + ...
                     this.transport(2:end,:) + this.supply   (2:end  ,:)  / (this.relaxation/this.wind.dt);

                idx = this.supply_limited;

                this.transport(~idx) = this.transport_transportltd(~idx);
                this.transport( idx) = this.transport_supplyltd   ( idx);
                
                source = this.get_maximum_source;

                if this.bedcomposition.enabled
                    mass       = zeros(this.number_of_gridcells,this.bedcomposition.number_of_fractions);
                    mass( idx) = source( idx) / this.dx - this.supply(idx) / (this.relaxation/this.wind.dt);
                    mass(~idx) = source(~idx) / this.dx - (this.capacity(~idx) - this.transport(~idx)) / (this.relaxation / this.wind.dt);

                    dz = this.bedcomposition.deposit(mass);

                    this.profile = this.profile + dz;
                    this.supply  = this.bedcomposition.top_layer_mass;
                else
                    this.supply( idx) = this.supply( idx) + source( idx) / this.dx - ...
                                        this.supply( idx) / (this.relaxation / this.wind.dt);
                    this.supply(~idx) = this.supply(~idx) + source(~idx) / this.dx - ...
                                        (this.capacity(~idx) - this.transport(~idx)) / (this.relaxation / this.wind.dt);
                end

                this.it = this.it + 1;
            else
                error('SLAMFAT model is not initialized');
            end
        end
        
        function threshold = get_maximum_threshold(this)
            threshold = repmat(this.bedcomposition.threshold_velocity, this.number_of_gridcells, 1);
            switch this.threshold_maximalization
                case 'tide'
                    n = 20;
                    nf = this.bedcomposition.number_of_fractions;
                    ff = repmat(linspace(2,1,n)',[1 nf]);
                    threshold(1:n,:) = ff .* threshold(1:n,:);
            end
        end
        
        function source = get_maximum_source(this)
            source = this.bedcomposition.source;
            switch this.source_maximalization
                case 'initial_profile'
                    nf = this.bedcomposition.number_of_fractions;
                    source = min(source, max(0,repmat((this.initial_profile - this.profile)',1,nf) .* this.bedcomposition.initial_mass_unit));
            end
        end
        
        function output(this)
            if ismember(this.it, this.output_timesteps)
                
                % update output matrices
                this.data.profile       (this.io,:)   = this.profile;
                this.data.transport     (this.io,:,:) = this.transport;
                this.data.supply        (this.io,:,:) = this.supply;
                this.data.capacity      (this.io,:,:) = this.capacity;
                this.data.supply_limited(this.io,:,:) = this.supply_limited;
                this.data.d50           (this.io,:,:) = this.bedcomposition.d50;
                
                if this.animate
                    this.fig.reinitialize;
                else
                    fprintf('%2.1f%%\n',this.it/this.wind.number_of_timesteps*100);
                end
                
                this.io = this.io + 1;
            end
        end
        
        function val = get.supply_limited(this)
            val = (this.capacity - this.transport_transportltd) / (this.relaxation/this.wind.dt) > this.supply;
        end
        
        function val = get.output_timesteps(this)
            if isscalar(this.output_timesteps)
                val = 1:this.output_timesteps:this.wind.number_of_timesteps;
            else
                val = this.output_timesteps;
            end
        end
        
        function val = get.output_time(this)
            val = this.output_timesteps * this.wind.dt;
        end
        
        function val = get.number_of_gridcells(this)
            val = length(this.profile);
        end
        
        function val = get.size_of_output(this)
            val = length(this.output_timesteps);
        end
        
        function val = get.timestep(this)
            val = this.it;
        end
        
        function val = get.output_timestep(this)
            val = find(this.output_timesteps <= this.it,1,'last');
        end
        
        function mtx = empty_matrix(this)
            nx = this.number_of_gridcells;
            nf = this.bedcomposition.number_of_fractions;
            mtx = zeros(nx,nf);
        end
        
        function plot(this)
            if isempty(this.fig)
                this.fig = this.visualization(this);
            else
                try
                    this.fig.update;
                catch
                    this.fig = this.visualization(this);
                end
            end
        end
    end
end
