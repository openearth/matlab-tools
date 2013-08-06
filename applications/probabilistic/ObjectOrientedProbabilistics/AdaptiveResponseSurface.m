classdef AdaptiveResponseSurface < handle
    %ADAPTIVERESPONSESURFACE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also AdaptiveResponseSurface.AdaptiveResponseSurface
    
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
    % Created: 26 Oct 2012
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
        CheckQualityARS
        WeightedARS
    end
    properties (SetAccess = private)
        Fit
        GoodFit
        MaxCoefficient
        MaxRootMeanSquareError
        ModelTerms
    end
    
    %% Methods
    methods
        %% Constructor
        function this = AdaptiveResponseSurface
            %ADAPTIVERESPONSESURFACE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = AdaptiveResponseSurface(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "AdaptiveResponseSurface"
            %
            %   Example
            %   AdaptiveResponseSurface
            %
            %   See also AdaptiveResponseSurface
            
            this.SetDefaults
        end
        
        %% Setters
        function set.Name(this, name)
            ProbabilisticChecks.CheckInputClass(name,'char')
            this.Name   = name;
        end
    
        function set.WeightedARS(this, weighted)
            ProbabilisticChecks.CheckInputClass(weighted,'logical')
            this.WeightedARS   = weighted;
        end
        %% Getters
        
        %% Other methods
        
        %Evaluate the ARS at a given point
        function zvalue = Evaluate(this, un, beta)
            uvalues     = un.*beta;
            zvalue      = polyvaln(this.Fit, uvalues);
        end
        
        %Update ARS fit
        function UpdateFit(this, limitState)
            this.DetermineModelTerms(limitState);
                        
            absoluteZValues = abs(limitState.ZValues(limitState.EvaluationIsExact));
            [Y,I] = sort(absoluteZValues,'ascend');
            
            nrUsedEvaluations =  max(1 + limitState.NumberRandomVariables + limitState.NumberRandomVariables*(limitState.NumberRandomVariables + 1)/2,round(size(absoluteZValues,1)/2));
            
            if ~isempty(this.ModelTerms)
                if ~this.WeightedARS
                    this.Fit    = polyfitn(limitState.UValues(limitState.EvaluationIsExact,:), limitState.ZValues(limitState.EvaluationIsExact), this.ModelTerms);
                else
                    if size(limitState.ZValues(limitState.EvaluationIsExact),1)>nrUsedEvaluations
                        usedZValues = Y(1:nrUsedEvaluations);
                        usedSortedIndex = I(1:nrUsedEvaluations);
                        
                        inputUvalues = limitState.UValues(limitState.EvaluationIsExact,:);
                        usedUValues = inputUvalues(usedSortedIndex,:);
                        this.Fit    = polyfitn(usedUValues, usedZValues, this.ModelTerms);
                    end
                end
            end
            
            this.CheckFit
        end
        
        %Check fit quality
        function CheckFit(this)
            if ~isempty(this.Fit) && ~isempty(fieldnames(this.Fit))
                if ~any(isnan(this.Fit.Coefficients)) && ...
                        ~any(isinf(this.Fit.Coefficients)) && ...
                        ~any(this.Fit.Coefficients > this.MaxCoefficient) && ...
                        ~any(isnan(this.Fit.ParameterVar)) && ...
                        ~any(isinf(this.Fit.ParameterVar)) && ...
                        ~any(this.Fit.ParameterVar > this.MaxCoefficient) && ...
                        this.Fit.RMSE/max(1,max(abs(this.Fit.Coefficients))) < this.MaxRootMeanSquareError || ...
                        ~this.CheckQualityARS
                    this.GoodFit    = true;
                else
                    this.GoodFit    = false;
                end
            else
                this.GoodFit    = false;
            end
        end
        
        %Determine modelterms in polynomial fit depending on number of
        %variables
        function DetermineModelTerms(this, limitState)
            if  sum(limitState.EvaluationIsExact) >= 1 + limitState.NumberRandomVariables + limitState.NumberRandomVariables*(limitState.NumberRandomVariables + 1)/2
                this.ModelTerms = 2;
            elseif sum(limitState.EvaluationIsExact) >= 2*limitState.NumberRandomVariables + 1
                this.ModelTerms = [zeros(1,limitState.NumberRandomVariables); eye(limitState.NumberRandomVariables); 2*eye(limitState.NumberRandomVariables)];
            else
                this.ModelTerms = []; 
            end
        end

        %Set default values
        function SetDefaults(this)
            this.GoodFit                = false;
            this.MaxCoefficient         = 1e5;
            this.MaxRootMeanSquareError = 1;
            this.CheckQualityARS        = true;
        end
        
        %plot response surface
        function plot(this, axARS)
            if nargin < 2 || isempty(axARS)
                if isempty(findobj('Type','axes','Tag','axARS'))
                    axARS           = axes('Tag','axARS');
                else
                    axARS           = findobj('Type','axes','Tag','axARS');
                end
            end

            lim             = linspace(-10,10,1000);
            [xGrid, yGrid]   = meshgrid(lim,lim);
            grid            = [xGrid(:) yGrid(:)];
            if this.GoodFit
                zGrid   = reshape(polyvaln(this.Fit, grid), size(xGrid));
            else
                zGrid   = NaN(size(xGrid));
            end
            
            phars = findobj(axARS,'Tag','ARS');
            
            if isempty(phars)
                phars = pcolor(axARS,xGrid,yGrid,zGrid);
                set(phars,'Tag','ARS','DisplayName','ARS');
            else
                set(phars,'CData',zGrid);
            end
            
            cm = colormap('gray');
            
            colorbar('peer',axARS);
            colormap(axARS,[flipud(cm) ; cm]);
            shading(axARS,'flat');
            clim(axARS,[-1 1]);
        end
    end
end
