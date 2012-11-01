classdef LineSearch < handle
    %LINESEARCH  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also LineSearch.LineSearch
    
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
        BetaFirstPoint
        Fit
        Roots
        MaxBeta
        MaxOrderFit
        MaxIterationsFit
        MaxIterationsBisection
        MaxErrorZ
        IterationsFit
        IterationsBisection
        NrEvaluations
        SearchConverged
        IndexLineSearchValues
        BetaValues
        ZValues
        ApproximateUsingARS
        StartBeta
        StartZ
    end
    
    properties (Access = private)
        plotBetaLowerBound
        plotBetaUpperBound
    end
    
    %% Methods
    methods
        %% Constructor
        function this = LineSearch
            %LINESEARCH  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = LineSearch(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "LineSearch"
            %
            %   Example
            %   LineSearch
            %
            %   See also LineSearch
            
            this.SetDefaults
        end
        
        %% Setters
        %BetaFirstPoint setter
        function set.BetaFirstPoint(this, BetaFirstPoint)
            ProbabilisticChecks.CheckInputClass(BetaFirstPoint,'double')
                                
            this.BetaFirstPoint = BetaFirstPoint;
        end
        
        %MaxIterationsFit setter
        function set.MaxIterationsFit(this, MaxIterationsFit)
            ProbabilisticChecks.CheckInputClass(MaxIterationsFit,'double')
                                
            this.MaxIterationsFit   = MaxIterationsFit;
        end
        
        %MaxIterationsBisection setter
        function set.MaxIterationsBisection(this, MaxIterationsBisection)
            ProbabilisticChecks.CheckInputClass(MaxIterationsBisection,'double')
                                
            this.MaxIterationsBisection = MaxIterationsBisection;
        end
        
        %MaxErrorZ setter
        function set.MaxErrorZ(this, MaxErrorZ)
            ProbabilisticChecks.CheckInputClass(MaxErrorZ,'double')
                                
            this.MaxErrorZ  = MaxErrorZ;
        end
        
        %Set StartBeta
        function set.StartBeta(this, beta)
            ProbabilisticChecks.CheckInputClass(beta,'double')
                                
            this.StartBeta  = beta;
        end
        
        %Set StartZ
        function set.StartZ(this, startZ)
            ProbabilisticChecks.CheckInputClass(startZ,'double')
                                
            this.StartZ     = startZ;
        end
        
        %% Main line search loop
        function PerformSearch(this, un, limitState, randomVariables, varargin)
            this.Reset
            
            this.SwitchExactApproximate(limitState, varargin{:})
            limitState.CheckOrigin
            
            this.BetaValues = [this.BetaValues; 0];
            this.ZValues    = [this.ZValues; limitState.ZValues(limitState.BetaValues == 0)];
            
            if ~isempty(this.StartBeta) || ~isempty(this.StartZ)
                this.BetaValues     = [this.BetaValues; this.StartBeta];
                this.ZValues        = [this.ZValues; this.StartZ];
            else
                this.EvaluatePoint(limitState, un, this.BetaFirstPoint, randomVariables);
            end
                
            this.FitPolynomial(un, limitState, randomVariables);
            
            if ~this.SearchConverged
                this.Bisection(un, limitState, randomVariables);
            end
            
            this.StartBeta  = [];
            this.StartZ     = [];
        end
        
        %% Other methods
        
        %Check whether exact evaluations or approximations are to be used
        function SwitchExactApproximate(this, limitState, varargin)
            if ~isempty(varargin)
                if (strcmp(varargin{1},'approximate') && varargin{2} == true) && limitState.CheckAvailabilityARS 
                    this.ApproximateUsingARS    = true;
                end
            end
        end
                
        %Call LimitState to either evaluate or approximate a certain point
        function varargout = EvaluatePoint(this, limitState, un, beta, randomVariables)
            if this.ApproximateUsingARS
                this.BetaValues     = [this.BetaValues; beta];
                zvalue              = limitState.Approximate(un, beta);
                this.NrEvaluations  = this.NrEvaluations + 1;
                this.ZValues        = [this.ZValues; zvalue];
            else
                zvalue              = limitState.Evaluate(un, beta, randomVariables);
                this.NrEvaluations  = this.NrEvaluations + 1;
                if isempty(zvalue)
                    varargout       = zvalue;
                else
                    this.BetaValues = [this.BetaValues; beta];
                    this.ZValues    = [this.ZValues; zvalue];
                end
            end
        end
               
        %Find Z=0 by fitting polynomial
        function FitPolynomial(this, un, limitState, randomVariables)
            while this.IterationsFit <= this.MaxIterationsFit && ~this.SearchConverged
                order   = min(this.MaxOrderFit, length(this.ZValues)-1);
                for o = order:-1:1
                    ii  = isort(abs(this.ZValues));
                    bs  = this.BetaValues(ii(1:(o+1)));
                    zs  = this.ZValues(ii(1:(o+1)));
                    
                    this.Fit    = polyfit(bs, zs ,o);
                    if this.CheckFit
                        this.Roots  = roots(this.Fit);
                        if this.CheckRoots
                            this.EvaluatePoint(limitState, un, this.Roots, randomVariables);
                            %                             this.plot(bs,zs)
                        end
                    end
                    this.CheckConvergence(limitState)
                    if this.SearchConverged
                        break
                    end
                end
                this.IterationsFit  = this.IterationsFit + 1;
                if this.SearchConverged
                    break
                end
            end
        end
        
        %Find Z=0 by performing Bisection
        function Bisection(this, un, limitState, randomVariables)
            while this.IterationsBisection <= this.MaxIterationsBisection && ~this.SearchConverged
                ii  = isort(abs(this.ZValues));
                if this.IterationsBisection == 0
                    if any(this.ZValues<0)
                        ii  = isort(this.BetaValues);
                        iu  = ii(find(this.ZValues(ii)<0 ,1 ,'first'));
                        il  = ii(find(this.BetaValues(ii)<this.BetaValues(iu),1,'last'));
                    elseif ~any(this.ZValues<0) && ~any(this.BetaValues == this.MaxBeta)
                        this.EvaluatePoint(limitState, un, this.MaxBeta, randomVariables);
                        ii      = isort(this.BetaValues);
                        iu      = ii(this.BetaValues(ii)==this.MaxBeta);
                        if this.ZValues(end) < 0
                            il  = ii(find(this.BetaValues(ii)<this.BetaValues(iu),1,'last'));
                        else
                            il  = ii(this.BetaValues(ii)==0);
                        end
                    else
                        il  = ii(this.BetaValues(ii)==0);
                        iu  = ii(2);
                    end
                elseif this.IterationsBisection > 0 && this.ZValues(end) < 0
                    iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                elseif this.IterationsBisection > 0 && this.ZValues(end) > 0
                    if abs(this.ZValues(end)) > abs(zs(1)) && abs(this.ZValues(end)) <= abs(zs(2))
                        iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                    elseif abs(this.ZValues(end)) <= abs(zs(1)) && abs(this.ZValues(end)) > abs(zs(2))
                        il  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                    elseif abs(this.ZValues(end)) > abs(zs(1)) && abs(this.ZValues(end)) > abs(zs(2))
                        if abs(zs(1)) > abs(zs(2))
                            il  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        elseif abs(zs(1)) <= abs(zs(2))
                            iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        end
                    elseif abs(this.ZValues(end)) <= abs(zs(1)) && abs(this.ZValues(end)) <= abs(zs(2))
                        if abs(zs(1)) > abs(zs(2))
                            il  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        elseif abs(zs(1)) <= abs(zs(2))
                            iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        end
                    end
                elseif this.IterationsBisection > 0 && isnan(this.ZValues(end))
                    iu  = ii(this.BetaValues(ii)==this.Roots);
                elseif this.IterationsBisection > 0 && ~isnan(this.ZValues(end)) && any(isnan(zs))
                    if bs(~isnan(zs)) <= this.BetaValues(end)
                        iu  = ii(find(this.BetaValues(ii)==this.BetaValues(end),1,'last'));
                    elseif bs(~isnan(zs)) > this.BetaValues(end)
                        il  = ii(find(this.BetaValues(ii)==this.BetaValues(end),1,'last'));
                    end
                end
                
                bs  = [this.BetaValues(il) this.BetaValues(iu)];
                zs  = [this.ZValues(il) this.ZValues(iu)];
                
                if all(bs < 0)                                                        
                    break
                elseif any(bs < 0) && any( bs >= 0)                                      
                    in          = ii(this.BetaValues(ii)==0);
                    bs(bs<0)    = this.BetaValues(in);
                    zs(bs<0)    = this.ZValues(in);
                end
                
                this.EvaluatePoint(limitState, un, mean(bs), randomVariables);
                
                if isnan(this.ZValues(end))
                    this.MaxIterationsBisection  = 10;
                end
                   
                this.IterationsBisection    = this.IterationsBisection + 1;
                this.CheckConvergence(limitState)
                if this.SearchConverged
                    break
                end
            end
        end
        
        %Check convergence of line search
        function CheckConvergence(this, limitState)
            if abs(limitState.ZValues(end)) < this.MaxErrorZ && limitState.BetaValues(end) > 0
                this.SearchConverged                    = true;
            end
        end
        
        %Reset logical indicating convergence
        function Reset(this)
            this.SearchConverged        = false;
            this.IterationsFit          = 0;
            this.IterationsBisection    = 0;
            this.BetaValues             = [];
            this.ZValues                = [];
            this.ApproximateUsingARS    = false;
            this.MaxIterationsBisection = 5;
            this.NrEvaluations          = 0;
        end
        
        %Check the coefficients of the polynomial fit
        function goodFit = CheckFit(this)
            if all(isfinite(this.Fit))
                goodFit = true;                
            else
                goodFit = false;
            end
        end
        
        %Check the roots
        function goodRoots = CheckRoots(this)
            if ~isempty(this.Roots)
                i1  = isreal(this.Roots);
                i2  = this.Roots > 0;
                if any(i1)
                    if any(i1&i2)
                        ii          = find(i1&i2);
                        ii          = ii(isort(this.Roots(ii)));
                        this.Roots  = this.Roots(ii(1));
                        goodRoots   = true;
                    else
                        this.Roots  = max(this.Roots(i1));
                        goodRoots   = true;
                    end
                else
                    goodRoots   = false;
                end
            else 
                goodRoots   = false;
            end
        end
        
        %Plot routine
        function plot(this, bs, zs)
            figure(1);
            plot(this.BetaValues(1:(end-1),:),this.ZValues(1:(end-1),:),'kx');
            grid on;
            hold on;
            plot(this.Roots,0,'ro','MarkerFaceColor','r');
            plot(this.BetaValues(end,:),this.ZValues(end,:),'mo','MarkerFaceColor','m');
            plot(bs,zs,'go');
            betaFit = linspace(this.plotBetaLowerBound, this.plotBetaUpperBound, 100);
            zFit    = polyval(this.Fit,betaFit);
            plot(betaFit, zFit, '-b');
            set(gca,'XLim',[this.plotBetaLowerBound this.plotBetaUpperBound])
            hold off
            pause
        end
    end
    
    methods (Access = protected)
        %Set default values
        function SetDefaults(this)
            this.BetaFirstPoint             = 4;
            this.MaxBeta                    = 8.3;
            this.MaxOrderFit                = 2;
            this.MaxIterationsFit           = 5;
            this.MaxIterationsBisection     = 5;
            this.MaxErrorZ                  = 1e-2;
            this.SearchConverged            = false;
            this.IterationsFit              = 0;
            this.IterationsBisection        = 0;
            this.ApproximateUsingARS        = false;
            this.plotBetaLowerBound         = -5;
            this.plotBetaUpperBound         = 10;
            this.NrEvaluations              = 0;
        end
    end
end