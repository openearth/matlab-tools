classdef AdaptiveDirectionalImportanceSampling < DirectionalSampling
    %ADAPTIVEDIRECTIONALIMPORTANCESAMPLING  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also AdaptiveDirectionalImportanceSampling.AdaptiveDirectionalImportanceSampling
    
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
    % Created: 29 Oct 2012
    % Created with Matlab version: 7.14.0.739 (R2012a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        MaxPRatio
        MinNrApproximatedPoints
        MinNrLimitStatePoints
    end
    
    properties (Dependent = true)
        PfApproximated
        dPfApproximated
        PRatio
    end
    
    %% Methods
    methods
        %% Constructor
        function this = AdaptiveDirectionalImportanceSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed)
            %ADAPTIVEDIRECTIONALIMPORTANCESAMPLING  constructor for the
            %ADIS probabilistic method object
            %
            %   Syntax:
            %   this = AdaptiveDirectionalImportanceSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed, varargin)
            %
            %   Input:
            %   limitState          = [LimitState object]
            %   lineSearcher        = [LineSearch object]
            %   confidenceInterval  = confidence interval (used for
            %   convergence) [double]
            %   accuracy            = accuracy used for convergence [double]
            %   seed                = fixed seed (for reproducable results)
            %   [double]
            %
            %   Output:
            %   this       = Object of class "AdaptiveDirectionalImportanceSampling"
            %
            %   Example
            %   AdaptiveDirectionalImportanceSampling
            %
            %   See also AdaptiveDirectionalImportanceSampling
            
            % The input is passed to the DirectionalSampling constructor function (DirectionalSampling is the superclass of AdaptiveDirectionalImportanceSampling)                        
            this    = this@DirectionalSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed);
            
            % Set default values for certain properties
            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
               
        %Get PfApproximated: total contribution of all approximated points (points from response surface)
        function pfapproximated = get.PfApproximated(this)
            pfapproximated  = sum(this.dPfApproximated);
        end
        
        %Get dPfApproximated: contribution of each approximated point (points from response surface)
        function dpfapproximated = get.dPfApproximated(this)
            if sum(~this.LimitState.EvaluationIsExact) > 0
                % there are approximated points: use Chi-squared
                % distribution to calculate probability
                dpfapproximated = (1-chi2_cdf(this.LimitState.BetaValues(this.EvaluationApproachesZero & ~this.LimitState.EvaluationIsExact& this.LimitState.EvaluationIsEnabled & this.LimitState.BetaValues > 0).^2,length(this.LimitState.RandomVariables)))/this.NrDirectionsEvaluated;
            elseif sum(~this.LimitState.EvaluationIsExact) == 0
                % no approcimated points
                dpfapproximated = 0;
            end
        end
        
        %Get PRatio: ratio between contribution of approximated points to
        %the total Pf (used in convergence check)
        function pratio = get.PRatio(this)
            if ~isempty(this.Pf) && ~isempty(this.PfApproximated)
                pratio  = this.PfApproximated/this.Pf;
            else
                pratio  = Inf;
            end
        end
        
        %% Main Adaptive Directional Importance Sampling Loop: call this function to run ADIS
        function CalculatePf(this)
            % Random direction vector is created in advance (DirectionalSampling method)
            this.ConstructUNormalVector
            
            % Calculate Z-Value at the origin in standard-normal-space (DirectionalSampling method)
            this.ComputeOrigin
            
            %Use start-up method if available
            if ~isempty(this.StartUpMethods)
                this.StartUpMethods.StartUp(this.LimitState, this.LimitState.RandomVariables)
            end
            
            %Perform line searches through random directions until solution converges
            while ~this.StopCalculation && ~this.Abort
                % Continue is the solution hasn't converged yet or there
                % are still directions that need to be reevaluated
                while (~this.SolutionConverged || ~isempty(this.ReevaluateIndices)) && ~this.Abort
                    if isempty(this.ReevaluateIndices)
                        % A new direction is chosen
                        this.NrDirectionsEvaluated  = this.NrDirectionsEvaluated + 1;
                        this.IndexQueue             = this.NrDirectionsEvaluated;
                    else
                        % A direction needs to be reevaluated
                        this.IndexQueue             = this.ReevaluateIndices(1);
                    end

                    % Check whether the maximum nr of directions is reached
                    this.CheckMaxNrDirections
                    
                    % IndexQueue can be used for parallellization purposes
                    % in the future
                    for iq = 1:length(this.IndexQueue)
                        
                        % Perform a line search in the chosen direction 
                        % (PerformSearch is a method of the LineSearch class)
                        if this.LimitState.CheckAvailabilityARS
                            % if a good response surface is available, use
                            % that in the line search
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables, 'approximate', true);
                        else
                            % else, perform exact line search (without use of response surface)
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables);
                        end
                        
                        % Save the index of the chosen direction for each
                        % point evaluated during the line search (DirectionalSampling method)
                        this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(iq));
                        
                        %Check whether last point needs to be evaluated
                        %exactly (is an ARS point & in beta sphere)
                        if this.CheckExactEvaluationLastPoint
                            % Disable the approximated evaluation in the
                            % current direction (replaced by exact points)
                            this.DisableEvaluations(this.UNormalIndexPerEvaluation == this.IndexQueue(iq));
                            
                            % start line search at approximated Z=0 ponit
                            this.LineSearcher.StartBeta = this.LimitState.BetaValues(end);
                            this.LineSearcher.StartZ    = this.LimitState.ZValues(end);
                            
                            % perform exact line search (LineSearch method)
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables);
                            
                            % Save the index of the chosen direction for each
                            % point evaluated during the line search (DirectionalSampling method)
                            this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(iq));
                        end
                        
                        % Recalculate the probability of failure
                        this.UpdatePf
                        
                        % Check if the method has converged to final answer
                        this.CheckConvergence;
                        
                        % If there are new exact points available: fit the
                        % response surface again
                        if ~this.LineSearcher.ApproximateUsingARS
                            this.LimitState.UpdateResponseSurface
                            if this.LastIteration
                                % if ARS is updated, do one more iteration
                                % (approximate points might have changed)
                                this.LastIteration      = false;
                            end
                        end
                        
                        %Remove the first element of the reevaluate vector
                        %(which was just reevaluated)
                        if ~isempty(this.ReevaluateIndices)
                            this.ReevaluateIndices(1)   = [];
                        end
                    end
                end
                
                %Extend beta sphere to include closest approximated point,
                %if PRatio is too large
                if ~this.CheckPRatio && this.PfApproximated ~= 0
                    % Look for smallest beta among approximated points
                    beta    = min(this.LimitState.BetaValues(this.LimitState.EvaluationIsEnabled & ~this.LimitState.EvaluationIsExact & this.EvaluationApproachesZero & this.LimitState.BetaValues > 0));
                    idx     = find(this.LimitState.BetaValues == beta, 1, 'first');
                    
                    % Extend beta-sphere to include approximate point
                    % nearest to the origin
                    this.LimitState.BetaSphere.UpdateBetaSphereMargin(beta, this.LimitState, this.EvaluationApproachesZero);
                    
                    % Reevaluate the associated direction & disable old
                    % points
                    this.ReevaluateIndices  = this.UNormalIndexPerEvaluation(idx);
                    this.DisableEvaluations(this.UNormalIndexPerEvaluation == this.ReevaluateIndices)
                end
                
                % if there are no more directions to reevaluate: flag as
                % last iteration & reevaluate all approximated points with
                % Z=0
                if isempty(this.ReevaluateIndices) && ~this.LastIteration
                    this.ReevaluateIndices  = this.UNormalIndexPerEvaluation(this.LimitState.EvaluationIsEnabled & ~this.LimitState.EvaluationIsExact & this.EvaluationApproachesZero);
                    this.DisableEvaluations(ismember(this.UNormalIndexPerEvaluation, this.ReevaluateIndices));
                    this.LastIteration      = true;
                end
                
                % If all convergence criteria are met, stop calculation
                if this.SolutionConverged && isempty(this.ReevaluateIndices) && this.CheckPRatio
                    this.StopCalculation    = true;
                end
            end
        end
        
        %% Other methods
           
        %Set default values
        function SetDefaults(this)
            this.MaxCOV                     = 0.1;
            this.MaxPRatio                  = 0.4;
            this.MinNrDirections            = 50;
            this.MaxNrDirections            = 1000;
            this.MinNrLimitStatePoints      = 0;
            this.MinNrApproximatedPoints    = 0;
            this.SolutionConverged          = false;
            this.StopCalculation            = false;
            this.NrDirectionsEvaluated      = 0;
            this.LastIteration              = false;
            this.Abort                      = false;
        end
             
        %Check convergence of the solution
        function CheckConvergence(this)
            if ... 
                    this.CheckCOV && ...
                    this.NrDirectionsEvaluated > this.MinNrDirections && ...
                    sum(this.EvaluationApproachesZero) >= this.MinNrLimitStatePoints  && ...
                    (sum(~this.LimitState.EvaluationIsExact & this.EvaluationApproachesZero) >= this.MinNrApproximatedPoints) 
                this.SolutionConverged = true;
            else
                this.SolutionConverged = false;
            end
        end
        
        %Check PRatio: ratio between contribution of approximated points to
        %the total Pf. 
        function goodRatio = CheckPRatio(this)
            if this.PRatio < this.MaxPRatio 
                goodRatio   = true;
            else 
                goodRatio   = false;
            end 
        end
             
        %Check if previously approximated point needs to be evaluated
        %exactly
        function evaluateExact = CheckExactEvaluationLastPoint(this)
            if this.LimitState.BetaSphere.IsInBetaSphere(this.LimitState.BetaValues(end), this.LimitState, this.EvaluationApproachesZero) && this.LineSearcher.SearchConverged && ~this.LimitState.EvaluationIsExact(end)
                % true if last point is approximated and within beta-sphere
                evaluateExact   = true;
            else
                evaluateExact   = false;
            end
        end
        
        %Disable evaluations so that they aren't used to calculate Pf
        function DisableEvaluations(this, indices)
            this.LimitState.EvaluationIsEnabled(indices) = false;
        end
        
        %Calculate the failure probabilities
        function UpdatePf(this)
            this.Pf = this.PfExact + this.PfApproximated;
        end
    end
end