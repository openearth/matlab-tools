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
        
        transport               = 0
        capacity                = 0
        supply                  = 0
        supply_limited          = false
        
        max_source              = 'none'
        max_threshold           = []
        
        data                    = struct()
        timestep                = 0
        output_timestep         = 0
        output_time             = 0
        size_of_output          = 0
        
        profile                 = zeros(1,100)
        initial_profile         = []
        wind                    = []
        bedcomposition          = []
        figure                  = []
        
        animate                 = false;
        progress                = true;
        progressbar             = []
    end
    
    properties(Access = private)
        it                      = 1
        io                      = 1
        transport_transportltd  = []
        transport_supplyltd     = []
        total_transport         = []
        
        isinitialized           = false
        performance             = struct()
    end
    
    %% Methods
    methods
        function this = slamfat(varargin)
            setproperty(this, varargin);
            
            if isempty(this.wind)
                this.wind = slamfat_wind;
            end

            if isempty(this.bedcomposition) || ~ishandle(this.bedcomposition)
                this.bedcomposition = slamfat_bedcomposition_basic;
            end

            if isempty(this.figure)
                this.figure = slamfat_plot;
            end
            
            if isempty(this.max_threshold)
                this.max_threshold = slamfat_threshold_basic;
            end
        end
        
        function initialize(this)
            if ~this.isinitialized
                
                if isscalar(this.output_timesteps)
                    this.output_timesteps = 1:this.output_timesteps:sum(this.wind.number_of_timesteps);
                else
                    this.output_timesteps = this.output_timesteps;
                end
                
                this.output_time         = this.output_timesteps * this.wind.dt;
                this.size_of_output      = length(this.output_timesteps);
                this.number_of_gridcells = length(this.profile);

                this.bedcomposition.number_of_gridcells = this.number_of_gridcells;
                this.bedcomposition.dt                  = this.wind.dt;
                this.bedcomposition.initialize;
                
                this.transport              = this.empty_matrix;
                this.transport_transportltd = this.empty_matrix;
                this.transport_supplyltd    = this.empty_matrix;
                this.supply                 = this.empty_matrix;
                this.capacity               = this.empty_matrix;
                this.total_transport        = this.empty_matrix;

                n  = this.size_of_output;
                nx = this.number_of_gridcells;
                nf = this.bedcomposition.number_of_fractions;
                nl = this.bedcomposition.get_number_of_actual_layers;

                this.data = struct(                     ...
                    'profile',          zeros(n,nx),    ...
                    'transport',        zeros(n,nx,nf), ...
                    'total_transport',  zeros(n,nx,nf), ...    
                    'supply',           zeros(n,nx,nf), ...
                    'capacity',         zeros(n,nx,nf), ...
                    'threshold',        zeros(n,nx,nf), ...
                    'supply_limited',   false(n,nx,nf), ...
                    'moisture',         zeros(n,nx),    ...
                    'd50',              zeros(n,nx,nl), ...
                    'thickness',        zeros(n,nx,nl));
                
                this.performance = struct(  ...
                    'initialization',   0,  ...
                    'transport',        0,  ...
                    'bedcomposition',   0,  ...
                    'grainsize',        0,  ...
                    'visualization',    0);
                
                this.initial_profile = this.profile;
                this.max_threshold.initialize(this.dx, this.profile);

                this.isinitialized = true;
            end
            
            if this.animate
                this.plot;
            elseif this.progress
                if isempty(this.progressbar)
                    this.progressbar = waitbar(0,'SLAMFAT model running...');
                end
            end
        end
        
        function run(this)
            tic;
            
            this.initialize;
            this.output;
            
            this.performance.initialization = toc;
            
            this.it = this.it + 1;
            while this.it < sum(this.wind.number_of_timesteps)
                this.next;
                this.output;
            end
            
            this.finalize;
        end
        
        function next(this)
            
            if this.isinitialized
                
                tic;
                
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

                idx = (this.capacity - this.transport_transportltd) / (this.relaxation/this.wind.dt) > this.supply;
                
                this.transport(~idx) = this.transport_transportltd(~idx);
                this.transport( idx) = this.transport_supplyltd   ( idx);
                
                this.total_transport = this.total_transport + this.transport*(this.wind.time_series(this.it-1) * this.relative_velocity);
                
                this.performance.transport = this.performance.transport + toc; tic;
                
                source = this.get_maximum_source;

                % coompute added mass
                mass       = zeros(this.number_of_gridcells,this.bedcomposition.number_of_fractions);
                mass( idx) = source( idx) / this.dx - this.supply(idx) / (this.relaxation/this.wind.dt);
                mass(~idx) = source(~idx) / this.dx - (this.capacity(~idx) - this.transport(~idx)) / (this.relaxation / this.wind.dt);

                dz = this.bedcomposition.deposit(mass);

                this.profile        = this.profile + dz;
                this.supply         = this.bedcomposition.get_top_layer_mass;
                this.supply_limited = idx;
                
                this.performance.bedcomposition = this.performance.bedcomposition + toc;

                this.it = this.it + 1;
            else
                error('SLAMFAT model is not initialized');
            end
        end
        
        function finalize(this)
            if this.progress
                close(this.progressbar);
            end
            
            if this.animate && ~isempty(this.figure)
                this.figure.reinitialize;
            end
        end
        
        function threshold = get_maximum_threshold(this)
            threshold = repmat(this.bedcomposition.threshold_velocity, this.number_of_gridcells, 1);
            threshold = this.max_threshold.maximize_threshold(threshold, this.wind.dt, this.profile, this.wind.time_series(this.it-1));
            threshold = max(0, threshold);
        end
        
        function source = get_maximum_source(this)
            source = this.bedcomposition.source;
            switch this.max_source
                case 'initial_profile'
                    nf = this.bedcomposition.number_of_fractions;
                    source = min(source, max(0,repmat((this.initial_profile - this.profile)',1,nf) .* this.bedcomposition.initial_mass_unit));
            end
        end
        
        function output(this)
            if ismember(this.it, this.output_timesteps)
                
                this.output_timestep = find(this.output_timesteps <= this.it,1,'last');
                
                % update output matrices
                this.data.profile        (this.io,:)   = this.profile;
                this.data.transport      (this.io,:,:) = this.transport;
                this.data.supply         (this.io,:,:) = this.supply;
                this.data.capacity       (this.io,:,:) = this.capacity;
                this.data.supply_limited (this.io,:,:) = this.supply_limited;
                this.data.total_transport(this.io,:,:) = this.total_transport;       
                
                this.data = this.max_threshold.output(this.data, this.io);
                
                tic;
                
                this.data = this.bedcomposition.output(this.data, this.io);
                
                this.performance.grainsize = this.performance.grainsize + toc; tic;
                
                if this.animate
                    this.figure.timestep = this.io;
                    this.figure.update;
                elseif this.progress
                    waitbar(this.io/this.size_of_output, this.progressbar);
                end
                
                this.performance.visualization = this.performance.visualization + toc;
                
                this.io = this.io + 1;
            end
        end
        
        function val = get.timestep(this)
            val = this.it;
        end
        
        function mtx = empty_matrix(this)
            nx = this.number_of_gridcells;
            nf = this.bedcomposition.number_of_fractions;
            mtx = zeros(nx,nf);
        end
        
        function fig = plot(this)
            if ~isempty(this.figure)
                if isempty(this.figure.obj)
                    this.figure.obj = this;
                end
                this.figure.timestep = this.output_timestep;
                this.figure.update;
            end
            
            fig = this.figure;
        end
        
        function delete(this)
            % clean up
            this.wind           = [];
            this.bedcomposition = [];
            this.max_threshold  = [];
            this.figure         = [];
        end
        
        function show_performance(this)
            tm  = cell2mat(struct2cell(this.performance));
            tmp = tm(2:end)./sum(tm(2:end))*100;
            
            fprintf('%20s : %10.4f s\n', 'initialization', this.performance.initialization);
            fprintf('%20s : %10.4f s [%5.1f%%]\n', ...
                'transport',        this.performance.transport,         tmp(1), ...
                'bed composition',  this.performance.bedcomposition,    tmp(2), ...
                'grain size',       this.performance.grainsize,         tmp(3), ...
                'visualization',    this.performance.visualization,     tmp(4), ...
                'total', sum(tm), this.it/sum(this.wind.number_of_timesteps)*100);
        end
    end
end
