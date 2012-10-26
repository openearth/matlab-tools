classdef DirectionalSampling < ProbabilisticMethod
    %DIRECTIONALSAMPLING  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also DirectionalSampling.DirectionalSampling
    
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
    % Created: 25 Oct 2012
    % Created with Matlab version: 7.14.0.739 (R2012a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    
    properties
        MaxCOV
        MaxPRatio
        SolutionConverged
        StopCalculation
        IndexQueue
        UNormalVector
        DirectionIndex
        MaxNumberDirections
    end
    
    properties (Dependent = true)
        PfExact
        PfApproximated
        PRatio
        COV
    end

    
    %% Methods
    methods
        function this = DirectionalSampling(LimitState, confidenceInterval, accuracy)
            %DIRECTIONALSAMPLING  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = DirectionalSampling(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "DirectionalSampling"
            %
            %   Example
            %   DirectionalSampling
            %
            %   See also DirectionalSampling
            
            ProbabilisticChecks.CheckInputClass(LimitState,'LimitState');
            ProbabilisticChecks.CheckInputClass(confidenceInterval,'double');
            ProbabilisticChecks.CheckInputClass(accuracy,'double');
            
            this.LimitState         = LimitState;
            this.ConfidenceInterval = confidenceInterval;
            this.Accuracy           = accuracy;  
            
            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
        
        function pfexact = get.PfExact(this)
            pfexact = this.LimitState.Betas(this.LimitState.EvaluationIsConverged && this.LimitState.EvaluationIsExact && this.LimitState.EvaluationIsRandom); %chi^2
        end
        
        function pfapproximated = get.PfApproximated(this)
            pfapproximated = this.LimitState.Betas(this.LimitState.EvaluationIsApproximated && this.LimitState.EvaluationIsRandom); %chi^2
        end
        
        %% Main Directional Sampling Loop
        function CalculatePf(this)
            
            %Construct matrix with random directions
            randomP             = this.GenerateRandomSamples(this.MaxNumberDirections, this.LimitState.NumberRandomVariables);
            u                   = norm_inv(randomP,0,1);
            uLength             = sqrt(sum(u.^2,2));
            this.UNormalVector  = u./repmat(uLength,1,this.LimitState.NumberRandomVariables);
            
            %Compute origin
            this.LimitState.Evaluate(zeros(1,this.LimitState.NumberRandomVariables),0,this.LimitState.RandomVariables);
            
            %Perform line searches through random directions until solution converges
            while ~this.StopCalculation
                this.DirectionIndex = this.DirectionIndex + 1;
                
                this.IndexQueue     = this.DirectionIndex;
                
                %initiate LineSearch (either exact or approximated, depending on whether there is a fit)
           
                %if linesearch converged: UpdateFit, UpdatePf and CheckConvergence
            
                %if CheckConvergence = true, alle
                %this.LimitState.EvaluationIsApproximated in de queue
            
                %daarna nog een keer checkconvergence
                if this.SolutionConverged && isempty(this.IndexQueue)
                    this.CheckConvergence;
                    if this.SolutionConverged
                        this.StopCalculation    = true;
                    end
                end
            end
            %Aanmaken en vullen Results object
        end
        
        %% Other methods
        
        %Set default values
        function SetDefaults(this)
            this.MaxCOV                 = 0.1;
            this.MaxPRatio              = 0.4;
            this.MaxNumberDirections    = 1000;
            this.SolutionConverged      = false;
            this.StopCalculation        = false;
        end
        
        %Exact evaluation
        function EvaluateExact
        end
        
        %Approximate evaluation (of an ARS)
        function EvaluateApprox
        end
        
        %Check convergence
        function CheckConvergence(this)
            if this.DirectionIndex < this.MaxNumberDirections
                if this.PRatio < this.MaxPRatio && this.COV < this.MaxCOV
                    this.SolutionConverged = true;
                else
                    this.SolutionConverged = false;
                end
            else
                warning('Maximum number of random directions reached!')
                this.StopCalculation    = true;
            end
        end
        
        %Calculate the failure probabilities
        function UpdatePf(this)
            this.Pf = this.PfExact + this.PfApproximated;
        end
    end
end
