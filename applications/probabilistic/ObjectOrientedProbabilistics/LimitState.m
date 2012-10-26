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
        EvaluationIsConverged
        EvaluationIsApproximate
        EvaluationIsRandom
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
            this.RandomVariables    = RandomVariables;
%             
%             RandomVariables(size(RandomVariablesInput,1),1)     = RandomVariable;
%             this.RandomVariables                                = RandomVariables;
%             for i=1:length(RandomVariablesInput)
%                 this.RandomVariables(i).Name                    = RandomVariablesInput{i,1};
%                 this.RandomVariables(i).Distribution            = RandomVariablesInput{i,2};
%                 this.RandomVariables(i).DistributionParameters  = RandomVariablesInput{i,3};
%             end
        end
        
        %% Getters

        %% Other methods       
        %Evaluate LSF at given point in U (standard normal) space
        function zvalue = Evaluate(this, un, beta, RandomVariables)
            ProbabilisticChecks.CheckInputClass(RandomVariables,'RandomVariable')
            uvalues     = un.*beta;
            xvalues     = NaN(1,length(RandomVariables));
            input       = cell(2,size(RandomVariables));
            for i=1:length(RandomVariables)
                xvalues(i)  = RandomVariables{i}.GetXValue(uvalues(i));
                input{1,i}  = RandomVariables{i}.Name;
                input{2,i}  = xvalues(i);
            end
            this.Betas      = [this.Betas beta];
            this.XValues    = [this.XValues; xvalues];
            this.UValues    = [this.UValues; uvalues];
            zvalue          = this.EvaluateAtX(input);
            this.ZValues    = [this.ZValues; zvalue];
        end
        
        %Evaluate LSF at given point in X space
        function zvalue = EvaluateAtX(this, input)
            zvalue          = feval(this.LimitStateFunction,input{:});
        end
        
%         %Evaluate LSF at given point in X space
%         function Aggregate(this)
%             zvalues         = NaN(size(this.LimitStates));
%             for i=1:length(this.LimitStates)
%                 zvalues(i)  = this.LimitStates{1}.ZValues(end);
%             end
%             zaggregate      = feval(this.AggregateFunction,zvalues);
%             this.ZValues    = [this.ZValues zaggregate];
%         end
    end
end
