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
        ReevaluateIndices
        UNormalVector
        UNormalIndexPerEvaluation
        NrDirectionsEvaluated
        MaxNrDirections
        LineSearcher
        LastIteration
        Abort
    end
    
    properties (Dependent = true)
        PfExact
        PfApproximated
        dPfExact
        dPfApproximated
        dPf
        PRatio
        COV
        StandardDeviation
        EvaluationApproachesZero
    end

    
    %% Methods
    methods
        function this = DirectionalSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed)
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
            
            ProbabilisticChecks.CheckInputClass(limitState,'LimitState');
            ProbabilisticChecks.CheckInputClass(lineSearcher,'LineSearch');
            ProbabilisticChecks.CheckInputClass(confidenceInterval,'double');
            ProbabilisticChecks.CheckInputClass(accuracy,'double');
            ProbabilisticChecks.CheckInputClass(seed,'double');
            
            this.LimitState         = limitState;
            this.LineSearcher       = lineSearcher;
            this.ConfidenceInterval = confidenceInterval;
            this.Accuracy           = accuracy;  
            this.Seed               = seed;
            
            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
        
        %Get PfExact 
        function pfexact = get.PfExact(this)
            pfexact     = sum(this.dPfExact);
        end
        
        %Get dPfExact
        function dpfexact = get.dPfExact(this)
            if sum(this.LimitState.EvaluationIsExact) > 0
                dpfexact    = (1-chi2_cdf(this.LimitState.BetaValues(this.EvaluationApproachesZero & this.LimitState.EvaluationIsExact & this.LimitState.EvaluationIsEnabled & this.LimitState.BetaValues > 0).^2,length(this.LimitState.RandomVariables)))/this.NrDirectionsEvaluated;
            elseif sum(this.LimitState.EvaluationIsExact) == 0
                dpfexact    = 0;
            end
        end
        
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
        
        %Get dP
        function dpf = get.dPf(this)
            dpf = [this.dPfExact; this.dPfApproximated; zeros(size(this.LimitState.BetaValues(this.LimitState.BetaValues <= 0)))];
        end
        
        %Get PRatio
        function pratio = get.PRatio(this)
            if ~isempty(this.Pf) && ~isempty(this.PfApproximated)
                pratio  = this.PfApproximated/this.Pf;
            else
                pratio  = Inf;
            end
        end
        
        %Get COV
        function cov = get.COV(this)
            if this.StandardDeviation ~= 0 && isreal(this.StandardDeviation) && ~isnan(this.StandardDeviation)
                cov = this.StandardDeviation/this.Pf;
            else
                cov = Inf;
            end
        end
        
        %Get StandardDeviation
        function sigma = get.StandardDeviation(this)
%             n       = sum(this.LimitState.EvaluationIsConverged&this.LimitState.EvaluationIsExact) + sum(this.LimitState.EvaluationIsConverged&this.LimitState.EvaluationIsApproximated);
%             sigma   = sqrt(1/(n*(n-1))*sum(([this.dPfExact; this.dPfApproximated]-this.Pf).^2)); 
%             sigma2  = sqrt((1/n)*sum(([this.dPfExact; this.dPfApproximated]-(this.Pf/n)).^2)); 
            sigma   = sqrt(1/(this.NrDirectionsEvaluated*(this.NrDirectionsEvaluated-1))*sum((this.dPf-this.Pf).^2)); 
%             sigma2  = sqrt((1/this.NrDirectionsEvaluated)*sum((this.dPf-(this.Pf/this.NrDirectionsEvaluated)).^2)); 
        end
        
        %Get EvaluationApproachesZero
        function evaluationApproachesZero = get.EvaluationApproachesZero(this)
            evaluationApproachesZero = (abs(this.LimitState.ZValues) < this.LineSearcher.MaxErrorZ) & this.LimitState.BetaValues > 0;
        end
        
        %% Main Directional Sampling Loop
        function CalculatePf(this)
            
            this.ConstructUNormalVector

            this.ComputeOrigin
            
            %Perform line searches through random directions until solution converges
            while ~this.StopCalculation && ~this.Abort
                while (~this.SolutionConverged || ~isempty(this.ReevaluateIndices)) && ~this.Abort
                    if isempty(this.ReevaluateIndices)
                        this.NrDirectionsEvaluated  = this.NrDirectionsEvaluated + 1;
                        this.IndexQueue             = this.NrDirectionsEvaluated;
                    else
                        this.IndexQueue             = this.ReevaluateIndices(1);
                    end
                    this.IndexQueue %temp output
                    this.CheckMaxNrDirections
                    
                    for iq = 1:length(this.IndexQueue)
                        
                        if this.LimitState.CheckAvailabilityARS
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables, 'approximate', true);
                        else
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables);
                        end
                        
                        this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(iq));
                        
                        if this.CheckExactEvaluationLastPoint
                            this.DisableEvaluations(this.UNormalIndexPerEvaluation == this.IndexQueue(iq));
                            this.LineSearcher.StartBeta = this.LimitState.BetaValues(end);
                            this.LineSearcher.StartZ    = this.LimitState.ZValues(end);
                            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(iq),:), this.LimitState, this.LimitState.RandomVariables);
                            this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(iq));
%                             this.plot
                        end
                        
                        this.UpdatePf
                        
                        this.CheckCOV;
                        if this.LineSearcher.SearchConverged && ~this.LineSearcher.ApproximateUsingARS
                            this.LimitState.UpdateResponseSurface
%                             this.LimitState.ResponseSurface.UpdateFit(this.LimitState)
                            if this.LastIteration
                                this.LastIteration      = false;
                            end
                        end
                        
                        if ~isempty(this.ReevaluateIndices)
                            this.ReevaluateIndices(1)   = [];
                        end
                    end
                end
                
                if ~this.CheckPRatio
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
                
                %daarna nog een keer checkconvergence
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
            this.MaxNrDirections            = 1000;
            this.SolutionConverged          = false;
            this.StopCalculation            = false;
            this.NrDirectionsEvaluated      = 0;
            this.LastIteration              = false;
            this.Abort                      = false;
        end
        
        %Construct normal vector with random directions
        function ConstructUNormalVector(this)
            randomP             = this.GenerateRandomSamples(this.MaxNrDirections, this.LimitState.NumberRandomVariables);
            u                   = norm_inv(randomP,0,1);
            uLength             = sqrt(sum(u.^2,2));
            this.UNormalVector  = u./repmat(uLength,1,this.LimitState.NumberRandomVariables);
        end
        
        %Compute origin
        function ComputeOrigin(this)
            this.LimitState.Evaluate(zeros(1,this.LimitState.NumberRandomVariables),0,this.LimitState.RandomVariables);
            if this.LimitState.ZValues(1) > this.LineSearcher.MaxErrorZ
                this.AssignUNormalIndices(1,0);
            else
                error('Failure at origin is not supported!');
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
        
        %Check COV
        function goodCOV = CheckCOV(this)
            if this.COV < this.MaxCOV
                goodCOV = true;
                this.SolutionConverged = true;
            else 
                goodCOV = false;
                this.SolutionConverged = false;
            end 
        end
        
        %Check if maximum nr of directions is exceeded
        function CheckMaxNrDirections(this)
            if any(this.IndexQueue >= this.MaxNrDirections)
                warning('Maximum number of random directions reached!')
                this.Abort  = true;
            end
        end
        
        %Check if previously approximated point needs to be evaluated
        %exactly
        function evaluateExact = CheckExactEvaluationLastPoint(this)
            if this.LineSearcher.SearchConverged && this.LimitState.BetaSphere.IsInBetaSphere(this.LimitState.BetaValues(end), this.LimitState, this.EvaluationApproachesZero) && ~this.LimitState.EvaluationIsExact(end)
                evaluateExact   = true;
            else
                evaluateExact   = false;
            end
        end
        
        %Fill the UNormalIndexPerEvaluation vector, to track the index of 
        %the  direction of each evaluation
        function AssignUNormalIndices(this, nrEvaluations, index)
            this.UNormalIndexPerEvaluation = [this.UNormalIndexPerEvaluation; ones(nrEvaluations,1)*index];
        end
        
        %Disable evaluations so that they aren't used to calculate Pf
        function DisableEvaluations(this, indices)
            this.LimitState.EvaluationIsEnabled(indices) = false;
        end
        
        %Calculate the failure probabilities
        function UpdatePf(this)
            this.Pf = this.PfExact + this.PfApproximated;
        end
        
        %Plot directional sampling results
        function plot(this)
            figureHandle = figure('Tag','ProbabilisticMethodResults');
            this.LimitState.plot(figureHandle, this.EvaluationApproachesZero)
        end
    end
end
