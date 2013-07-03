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
            
%<<<<<<< .mine
            ProbabilisticChecks.CheckInputClass(limitState,'LimitState');
            ProbabilisticChecks.CheckInputClass(lineSearcher,'LineSearch');
            ProbabilisticChecks.CheckInputClass(confidenceInterval,'double');
            ProbabilisticChecks.CheckInputClass(accuracy,'double');
            ProbabilisticChecks.CheckInputClass(seed,'double');  
             
            %DANA    It calls the constructor function of
            %DirectionalSampling because we want as little as possible
            %lines of code, the inheritence applies here also because you
            %can change things in one spot and forget to change it in
            %another spot
            
%=======
            % The input is passed to the DirectionalSampling constructor function (DirectionalSampling is the superclass of AdaptiveDirectionalImportanceSampling)                        
%>>>>>>> .r8619
            this    = this@DirectionalSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed);
            
            % Set default values for certain properties
            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
               
        %Get PfApproximated: total contribution of all approximated points (points from response surface)
         % here i get the total contribution of the approximated points
        function pfapproximated = get.PfApproximated(this)
            pfapproximated  = sum(this.dPfApproximated);
        end
        
        %Get dPfApproximated: contribution of each approximated point (points from response surface)
        % here i get the contribution of every point
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
        % the part of the total prob that is approximated by the response
        % surface
        % if this is too large, then we need to do more exact evaluations
        function pratio = get.PRatio(this)
            if ~isempty(this.Pf) && ~isempty(this.PfApproximated)
                pratio  = this.PfApproximated/this.Pf;
            else
                pratio  = Inf;
            end
        end
        
        %% Main Adaptive Directional Importance Sampling Loop: call this function to run ADIS
        function CalculatePf(this)
%<<<<<<< .mine
            % construct the normal vector with random directions
%=======
            % Random direction vector is created in advance (DirectionalSampling method)
%>>>>>>> .r8619
            this.ConstructUNormalVector
            
            % Calculate Z-Value at the origin in standard-normal-space (DirectionalSampling method)
            
            % DANA: we start by computing the origin of the search
            this.ComputeOrigin
            
            
            %Use start-up method if available
            if ~isempty(this.StartUpMethods)
                this.StartUpMethods.StartUp(this.LimitState, this.LimitState.RandomVariables)
            end
            
            %Perform line searches through random directions until solution converges
            
            % DANA: While I do not stop the calculation (the boolean StopCalculation is false and I do not abort  - the boolean Abort is false)
            while ~this.StopCalculation && ~this.Abort
%<<<<<<< .mine
                % DANA: While the solution has not converged OR there are
                        % no samples left for reevaluation) AND we do not Abort
                        
                        % One i have an exact evaluation, then of course i
                        % update the RS, then i recalculate all the
                        % approximated points because the approximated
                        % points value may have changed. I update all the history
                        % of the points, except for the exact ones.
                        
                        % 
%=======
                % Continue is the solution hasn't converged yet or there
                % are still directions that need to be reevaluated
%>>>>>>> .r8619
                while (~this.SolutionConverged || ~isempty(this.ReevaluateIndices)) && ~this.Abort
                   
                    if isempty(this.ReevaluateIndices)
%<<<<<<< .mine
                        % DANA: the index for the number of evaluated directions increases
%=======
                        % A new direction is chosen
                        this.NrDirectionsEvaluated  = this.NrDirectionsEvaluated + 1;
%>>>>>>> .r8619
                        this.IndexQueue             = this.NrDirectionsEvaluated;
                    else
%<<<<<<< .mine
                        % DANA: we remember in IndexQueue the index of the directions that need to be re-evaluated
                        % you always take the first one, because then you
                        % remove it from the queue after it was
                        % re-evaluated and that's how you know what is the
                        % random direction for your iteration
                       
%=======
                        % A direction needs to be reevaluated
%>>>>>>> .r8619
                        this.IndexQueue             = this.ReevaluateIndices(1);
                    end

                    % Check whether the maximum nr of directions is reached

                    % DANA i checking if the maximum number of random directions has been reached
                    % so that it doen't go on foreevr if we have a diff
                    % problem to solve
                    this.CheckMaxNrDirections 
                    
%<<<<<<< .mine
                    % DANA For all the directions that need to be
                    % re-evaluated (there is only one value in the queue at the moment, this is prep for possible paerallelization)
%=======
                    % IndexQueue can be used for parallellization purposes
                    % in the future
%>>>>>>> .r8619
                    for iq = 1:length(this.IndexQueue)
                        
%<<<<<<< .mine
                        % DANA We check if the ARS is available 
%=======
                        % Perform a line search in the chosen direction 
                        % (PerformSearch is a method of the LineSearch class)
%>>>>>>> .r8619
                        if this.LimitState.CheckAvailabilityARS
%<<<<<<< .mine
                            % DANA We use an approximation with the RS
%=======
                            % if a good response surface is available, use
                            % that in the line search
%>>>>>>> .r8619
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables, 'approximate', true);
                            % DANA the return is: 
                                                  % this.NrEvaluations 
                                                  % this.BetaValues 
                                                  % this.ZValues 
                        else
%<<<<<<< .mine
                            % DANA We use an exact evaluation of the
                            % function
%=======
                            % else, perform exact line search (without use of response surface)
%>>>>>>> .r8619
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables);
                        end
                         %DANA Fill in the UNormalIndexPerEvaluation vector, to track the index of 
                         %the  direction of each evaluation
                        % Save the index of the chosen direction for each
                        % point evaluated during the line search (DirectionalSampling method)
                        this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(iq));
                        
                        
                        %DANA Why do we do this?
                        
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
                        
%<<<<<<< .mine
                         %DANA  We calculate the failure probabilities
                                % this.Pf = this.PfExact + this.PfApproximated;
        
%=======
                        % Recalculate the probability of failure
%>>>>>>> .r8619
                        this.UpdatePf
                        
%<<<<<<< .mine
                        %DANA  We check convergence of the solution
                              % We have convergence if :
                                % this.CheckPRatio  this.PRatio < this.MaxPRatio   AND
                                % this.CheckCOV :this.COV < this.MaxCOV  AND
                                % this.NrDirectionsEvaluated > this.MinNrDirections
                        
%=======
                        % Check if the method has converged to final answer
%>>>>>>> .r8619
                        this.CheckConvergence;
                        
%<<<<<<< .mine
                        %DANA Why do we do this??
                        
%=======
                        % If there are new exact points available: fit the
                        % response surface again
%>>>>>>> .r8619
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
            this.MaxNrDirections            = 100; %addedDana, initial it was 1000
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