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
        EvaluationIsExact
        EvaluationIsEnabled
        ResponseSurface
    end
    
    properties (Dependent)
        NumberRandomVariables
    end
        
    %% Methods
    methods
        %% Constructor
        function this = LimitState
            %LIMITSTATE  One line description goes here.
            %
            %   More detailed description goes here.
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
           
            this.BetaSphere     = BetaSphere;
        end
        
        %% Setters
        %Set RandomVariables
        function set.RandomVariables(this, RandomVariables)
            ProbabilisticChecks.CheckInputClass(RandomVariables,'RandomVariable')
            this.RandomVariables        = RandomVariables;
        end
        
        %% Getters

        %Get number of random variables
        function numberrandomvariables = get.NumberRandomVariables(this)
            numberrandomvariables   = length(this.RandomVariables);
        end
            
        %% Other methods       
        %Evaluate LSF at given point in U (standard normal) space
        function zvalue = Evaluate(this, un, beta, randomVariables)
            ProbabilisticChecks.CheckInputClass(randomVariables,'RandomVariable')
            uvalues     = un.*beta;
            input       = cell(2,length(randomVariables));
            for i=1:length(randomVariables)
                xvalue      = randomVariables(i).GetXValue(uvalues(i));
                
                if isempty(xvalue)
                    break
                end
                input{1,i}  = randomVariables(i).Name;
                input{2,i}  = xvalue;
            end
            
            if isempty(xvalue)
                zvalue          = [];
            else
                this.BetaValues = [this.BetaValues; beta];
                this.XValues    = [this.XValues; [input{2,:}]];
                this.UValues    = [this.UValues; uvalues];
                zvalue          = this.EvaluateAtX(input);
                this.ZValues    = [this.ZValues; zvalue];
                
                this.EvaluationIsExact          = logical([this.EvaluationIsExact; true]);
                this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
            end
        end
        
        %Evaluate LSF at given point in X space
        function zvalue = EvaluateAtX(this, input)
            zvalue          = feval(this.LimitStateFunction,input{:});
        end
        
        %Approximate LSF at given point using the ResponseSurface
        function zvalue = Approximate(this, un, beta)
            if ~this.CheckAvailabilityARS
                error('No ARS (with a good fit) available!')
            else
                this.BetaValues = [this.BetaValues; beta];
                uvalues         = un.*beta;
                this.UValues    = [this.UValues; uvalues];
                zvalue          = this.ResponseSurface.Evaluate(un, beta);
                this.ZValues    = [this.ZValues; zvalue];
                
                this.EvaluationIsExact          = logical([this.EvaluationIsExact; false]);
                this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
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
        
        %Check if origin is available
        function CheckOrigin(this)
            if ~any(this.BetaValues == 0)
                error('Origin not available in LimitState');
            elseif any(this.BetaValues  == 0) && this.ZValues(this.BetaValues == 0) <= 0
                error('Failure at origin of limit state is not supported by this line search algorithm');
            end
        end
    end
end