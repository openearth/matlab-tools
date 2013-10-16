classdef LimitState < handle
    %LIMITSTATE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also LimitState.LimitState
    
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
        Name
        RandomVariables
        LimitStateFunction
        BetaSphere
        BetaValues
        XValues
        UValues
        ZValues
        ZValueOrigin
        EvaluationIsExact
        EvaluationIsEnabled
        ResponseSurface
    end
    
    properties (Dependent)
        NumberRandomVariables
        NumberExactEvaluations
    end
        
    %% Methods
    methods
        %% Constructor
        function this = LimitState
            %LIMITSTATE  object describing a probabilistic problem
            %
            %   Syntax:
            %   this = LimitState(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "LimitState"
            %
            %   Example
            %   LimitState
            %
            %   See also LimitState
           
            % Adding a BetaSphere by default
            this.BetaSphere     = BetaSphere;
        end
        
        %% Setters
        %Set RandomVariables: the stochastic variables used in the limit
        %state function
        function set.RandomVariables(this, RandomVariables)
            ProbabilisticChecks.CheckInputClass(RandomVariables,'RandomVariable')
            this.RandomVariables        = RandomVariables;
        end
        
        %% Getters

        %Get the number of random variables present
        function numberrandomvariables = get.NumberRandomVariables(this)
            numberrandomvariables   = length(this.RandomVariables);
        end
        
        % Get how many exact limit state evaluations are present
        function numberexactevaluations = get.NumberExactEvaluations(this)
            numberexactevaluations = sum(this.EvaluationIsExact);
        end
           
        %% Other methods       
        %Evaluate LSF at given point in U (standard normal) space
        function zvalue = Evaluate(this, un, beta, randomVariables, varargin)
            ProbabilisticChecks.CheckInputClass(randomVariables,'RandomVariable')
            
            % location to be evaluated
            uvalues     = un.*beta;
            
            % initialise variable
            input       = cell(2,length(randomVariables));
            for i=1:length(randomVariables)
                % translate location in standard normal space to regular
                % space
                xvalue      = randomVariables(i).GetXValue(uvalues(i));
                
                if isempty(xvalue)
                    % stop if no value can be found
                    break
                end
                input{1,i}  = randomVariables(i).Name;
                input{2,i}  = xvalue;
            end
            
            if isempty(xvalue)
                zvalue          = [];
            else
                % add found values to vectors
                this.BetaValues = [this.BetaValues; beta];
                this.XValues    = [this.XValues; [input{2,:}]];
                this.UValues    = [this.UValues; uvalues];
                
                % calculate & save associated Z value
                zvalue          = this.EvaluateAtX(input, uvalues);
                % here we actually add to the vector of the limit state 
                this.ZValues    = [this.ZValues; zvalue];
                
                % flag as exact evaluation (no use of response surface)
                this.EvaluationIsExact          = logical([this.EvaluationIsExact; true]);
                
                % If specified, calculated points are disabled so they
                % aren't used for calculating Pf (necessary for StartUp methods)
                if ~isempty(varargin)
                    if (strcmp(varargin{1},'disable') && varargin{2} == true)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; false]);
                    elseif (strcmp(varargin{1},'disable') && varargin{2} == false)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                    else
                        error('The only valid values for the keyword "disable" are true or false')
                    end
                else
                    this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                end
            end
        end
        
        %Evaluate LSF at given point in X (regular) space, zvalue is
        %normalized with the zvalue in the origin
        function zvalue = EvaluateAtX(this, input, uvalues)
            zvalue  = feval(this.LimitStateFunction,input{:});

            %Normalize with origin, or save zvalue of origin
            if ~isempty(this.ZValueOrigin) && ~isnan(this.ZValueOrigin)
                zvalue  = zvalue/this.ZValueOrigin;
            elseif isempty(this.ZValueOrigin) && all(uvalues == 0)
                this.ZValueOrigin   = zvalue;
                zvalue              = 1;
            elseif isnan(this.ZValueOrigin) && all(uvalues == 0)
                % ZValueOrigin is set later (it's the aggregated value for
                % all limit states)
                zvalue  = zvalue;
            else
                error('The Z-Value in the origin is not available for normalizing, please calculate it first!')                
            end
        end
        
        %Approximate LSF at given point using the ResponseSurface
        function zvalue = Approximate(this, un, beta, varargin)
            if ~this.CheckAvailabilityARS
                error('No ARS (with a good fit) available!')
            else
                % add values to vector
                this.BetaValues = [this.BetaValues; beta];
                uvalues         = un.*beta;
                this.UValues    = [this.UValues; uvalues];
                
                % Approximate using response surface & save
                zvalue          = this.ResponseSurface.Evaluate(un, beta);
                this.ZValues    = [this.ZValues; zvalue];
                
                % Flag as not exact (=approximated)
                this.EvaluationIsExact          = logical([this.EvaluationIsExact; false]);
                
                % If specified, calculated points are disabled so they
                % aren't used for calculating Pf (necessary for StartUp methods)
                if ~isempty(varargin)
                    if (strcmp(varargin{1},'disable') && varargin{2} == true)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; false]);
                    elseif (strcmp(varargin{1},'disable') && varargin{2} == false)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                    else
                        error('The only valid values for the keyword "disable" are true or false')
                    end
                else
                    this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                end
            end
        end
        
        %Check if a response surface is available and has a good fit
        function arsAvailable = CheckAvailabilityARS(this)
            
            if isempty(this.ResponseSurface) || (~isempty(this.ResponseSurface) && ~this.ResponseSurface.GoodFit)
                arsAvailable    = false;
            elseif ~isempty(this.ResponseSurface) && this.ResponseSurface.GoodFit
                arsAvailable    = true;
            end
        end
        
        %Check if origin is available and return Z-value
        function originZ = CheckOrigin(this)
            originZ = [];
            if ~any(this.BetaValues == 0)
                error('Origin not available in LimitState')
            elseif any(this.BetaValues  == 0) && this.ZValues(this.BetaValues == 0) <= 0
                error('Failure at origin of limit state is not supported by this line search algorithm');
            elseif any(this.BetaValues  == 0) && this.ZValues(this.BetaValues == 0) > 0
                originZ = this.ZValues(this.BetaValues == 0);
            end
        end
        
        %Update response surface (AdaptiveResponseSurface method)
        function UpdateResponseSurface(this)
            this.ResponseSurface.UpdateFit(this)
        end
        
        %Get minimum nr of evaluations needed for full fit from
        %ResponseSurface
        function nrEvals = GetNrEvaluationsFullFit(this)
            nrEvals = [];
            if ~isempty(this.ResponseSurface)
                nrEvals = this.ResponseSurface.MinNrEvaluationsFullFit;
            end
        end
        
        %Add ARS to plot if available
        function AddARSToPlot(this, axisHandle)
            if ~isempty(this.ResponseSurface)
                axARS           = findobj('Type','axes','Tag','axARS');
                this.ResponseSurface.plot(axARS);
                set(axARS,'Position',get(axisHandle,'Position'));
            end
        end
        
        %Plot limit state (and response surface if applicable)
        function plot(this, figureHandle, evaluationApproachesZero)
            if isempty(figureHandle)
                if isempty(findobj(figureHandle,'Type','figure','Tag','LimitStatePlot'))
                    figureHandle = figure('Tag','LimitStatePlot');
                else
                    figureHandle = findobj('Type','figure','Tag','LimitStatePlot');
                end
            end
            
            s    = [];
            s(1) = subplot(3,1,[1 2]); hold on;
            s(2) = axes('Position',get(s(1),'Position')); hold on;
            
            linkaxes(s,'xy');
            
            set(s, 'Color', 'none'); box on;
            set(s(1),'XTick',[],'YTick',[],'Tag','axARS');
            set(s(2),'Tag','axSamples');
            
            axis(s,'equal')
            
            uitable( ...
                'Units','normalized', ...
                'Position',[0.09 0.05 0.82 0.25],...
                'Data', [], ...
                'ColumnName', {'total', 'exact', 'approx', 'not converged' 'model'},...
                'RowName', {'N' 'P' 'Accuracy' 'Ratio'});

        
            axisHandle  = findobj(figureHandle,'Type','axes','Tag','axSamples');
            uitHandle   = findobj(figureHandle,'Type','uitable');
            
            ph1 = findobj(axisHandle,'Tag','P1');
            ph2 = findobj(axisHandle,'Tag','P2');
            ph3 = findobj(axisHandle,'Tag','P3');
            ph4 = findobj(axisHandle,'Tag','P4');
            
            if  isempty(ph1) || isempty(ph2) || isempty(ph3) || isempty(ph4)
                
                ph1 = scatter(axisHandle,this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero & this.BetaValues > 0,1),this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero & this.BetaValues > 0,2),'+','MarkerEdgeColor','b');
                ph2 = scatter(axisHandle,this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2),'MarkerEdgeColor','c');
                ph3 = scatter(axisHandle,this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2),'MarkerEdgeColor','g');
                ph4 = scatter(axisHandle,this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero  & this.BetaValues > 0,1),this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero  & this.BetaValues > 0,2),'+','MarkerEdgeColor','m');
                
                set(ph1,'Tag','P1','DisplayName','not converged (approximated)');
                set(ph2,'Tag','P2','DisplayName','approximated');
                set(ph3,'Tag','P3','DisplayName','exact');
                set(ph4,'Tag','P3','DisplayName','not converged (exact)');
            else
                set(ph1,'XData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,1),'YData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,2));
                set(ph2,'XData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),'YData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2));
                set(ph3,'XData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),'YData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2));
                set(ph4,'XData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,1),'YData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,2));
            end
            
            if ~isempty(this.BetaSphere)
                this.BetaSphere.plot(axisHandle);
            end
            
            xlabel(axisHandle,'u_1');
            ylabel(axisHandle,'u_2');

            legend(axisHandle,'-DynamicLegend','Location','NorthWestOutside');
            legend(axisHandle,'show');
            
            data = { ...
                0 sum(this.EvaluationIsExact & evaluationApproachesZero) sum(~this.EvaluationIsExact & evaluationApproachesZero) 0   this.NumberExactEvaluations ; ...
                0          0        0           ''                0            ; ...
                0     ''         ''            ''                0            ; ...
                0 0    0       ''                0   };
            
            set(uitHandle,'Data',data);
            set(axisHandle,'XLim',[-6 6],'YLim',[-6 6]);
            
            this.AddARSToPlot(axisHandle)
            
            drawnow;
        end
    end
end