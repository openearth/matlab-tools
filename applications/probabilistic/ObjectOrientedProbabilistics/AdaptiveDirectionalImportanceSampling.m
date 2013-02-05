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
        function this = AdaptiveDirectionalImportanceSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed, varargin)
            %ADAPTIVEDIRECTIONALIMPORTANCESAMPLING  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = AdaptiveDirectionalImportanceSampling(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "AdaptiveDirectionalImportanceSampling"
            %
            %   Example
            %   AdaptiveDirectionalImportanceSampling
            %
            %   See also AdaptiveDirectionalImportanceSampling
            
            ProbabilisticChecks.CheckInputClass(limitState,'LimitState');
            ProbabilisticChecks.CheckInputClass(lineSearcher,'LineSearch');
            ProbabilisticChecks.CheckInputClass(confidenceInterval,'double');
            ProbabilisticChecks.CheckInputClass(accuracy,'double');
            ProbabilisticChecks.CheckInputClass(seed,'double');
                        
            this    = this@DirectionalSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed);

            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
               
        %Get PfApproximated
        function pfapproximated = get.PfApproximated(this)
            pfapproximated  = sum(this.dPfApproximated);
        end
        
        %Get dPfApproximated
        function dpfapproximated = get.dPfApproximated(this)
            if sum(~this.LimitState.EvaluationIsExact) > 0
                dpfapproximated = (1-chi2_cdf(this.LimitState.BetaValues(this.EvaluationApproachesZero & ~this.LimitState.EvaluationIsExact& this.LimitState.EvaluationIsEnabled & this.LimitState.BetaValues > 0).^2,length(this.LimitState.RandomVariables)))/this.NrDirectionsEvaluated;
            elseif sum(~this.LimitState.EvaluationIsExact) == 0
                dpfapproximated = 0;
            end
        end
        
        %Get PRatio
        function pratio = get.PRatio(this)
            if ~isempty(this.Pf) && ~isempty(this.PfApproximated)
                pratio  = this.PfApproximated/this.Pf;
            else
                pratio  = Inf;
            end
        end
        
        %% Main Adaptive Directional Importance Sampling Loop
        function CalculatePf(this)
            this.ConstructUNormalVector

            this.ComputeOrigin
            
            %Use start-up method if available
            if ~isempty(this.StartUpMethods)
                this.StartUpMethods.StartUp(this.LimitState, this.LimitState.RandomVariables)
            end
            
            %Perform line searches through random directions until solution converges
            while ~this.StopCalculation && ~this.Abort
                while (~this.SolutionConverged || ~isempty(this.ReevaluateIndices)) && ~this.Abort
                    if isempty(this.ReevaluateIndices)
                        this.NrDirectionsEvaluated  = this.NrDirectionsEvaluated + 1;
                        this.IndexQueue             = this.NrDirectionsEvaluated;
                    else
                        this.IndexQueue             = this.ReevaluateIndices(1);
                    end
%                     this.IndexQueue %temp output
                    this.CheckMaxNrDirections
                    
                    for iq = 1:length(this.IndexQueue)
                        
                        if this.LimitState.CheckAvailabilityARS
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables, 'approximate', true);
                        else
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables);
                        end
                        
                        this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(iq));
                        
                        %Check whether last point needs to be evaluated
                        %exactly (is in beta sphere)
                        if this.CheckExactEvaluationLastPoint
                            this.DisableEvaluations(this.UNormalIndexPerEvaluation == this.IndexQueue(iq));
                            this.LineSearcher.StartBeta = this.LimitState.BetaValues(end);
                            this.LineSearcher.StartZ    = this.LimitState.ZValues(end);
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables);
                            this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(iq));
%                             this.plot; pause(0.1); close;
                        end
                        
                        this.UpdatePf
                        
                        this.CheckConvergence;
                        
                        if ~this.LineSearcher.ApproximateUsingARS
                            this.LimitState.UpdateResponseSurface
                            if this.LastIteration
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
                    beta    = min(this.LimitState.BetaValues(this.LimitState.EvaluationIsEnabled & ~this.LimitState.EvaluationIsExact & this.EvaluationApproachesZero & this.LimitState.BetaValues > 0));
                    idx     = find(this.LimitState.BetaValues == beta, 1, 'first');
                    this.LimitState.BetaSphere.UpdateBetaSphereMargin(beta, this.LimitState, this.EvaluationApproachesZero);
                    this.ReevaluateIndices  = this.UNormalIndexPerEvaluation(idx);
                    this.DisableEvaluations(this.UNormalIndexPerEvaluation == this.ReevaluateIndices)
                end
                
                if isempty(this.ReevaluateIndices) && ~this.LastIteration
                    this.ReevaluateIndices  = this.UNormalIndexPerEvaluation(this.LimitState.EvaluationIsEnabled & ~this.LimitState.EvaluationIsExact & this.EvaluationApproachesZero);
                    this.DisableEvaluations(ismember(this.UNormalIndexPerEvaluation, this.ReevaluateIndices));
                    this.LastIteration      = true;
                end
                
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
            if this.CheckPRatio && this.CheckCOV && this.NrDirectionsEvaluated > this.MinNrDirections && sum(this.EvaluationApproachesZero) >= this.MinNrLimitStatePoints  && (sum(~this.LimitState.EvaluationIsExact & this.EvaluationApproachesZero) >= this.MinNrApproximatedPoints) 
                this.SolutionConverged = true;
            else
                this.SolutionConverged = false;
            end
        end
        
        %Check PRatio
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