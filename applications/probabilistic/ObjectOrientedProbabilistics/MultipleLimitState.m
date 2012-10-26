classdef MultipleLimitState < LimitState
    %MULTIPLELIMITSTATE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also MultipleLimitState.MultipleLimitState
    
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
        LimitStates
        AggregateFunction
    end
    
    %% Methods
    methods
        %% Constructor
        function this = MultipleLimitState(LimitStates, AggregateFunction)
            %MULTIPLELIMITSTATE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = MultipleLimitState(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "MultipleLimitState"
            %
            %   Example
            %   MultipleLimitState
            %
            %   See also MultipleLimitState
            
            ProbabilisticChecks.CheckInputClass(LimitStates,'LimitState')
            ProbabilisticChecks.CheckInputClass(AggregateFunction,'function_handle')
            this.LimitStates        = LimitStates;
            this.AggregateFunction  = AggregateFunction;
        end
        
        %% Setters
        
        %Set LimitStates
%         function set.LimitStates(this, LimitStatesInput)
%             ProbabilisticChecks.CheckInputClass(LimitStatesInput,'LimitState')
%             this.LimitStates        = LimitStates;
% %             this.LimitStates(length(LimitStatesInput)) = LimitState;
% %             for i=1:length(LimitStatesInput)
% %                 this.LimitStates(i).Name                = LimitStatesInput{i,1};
% %                 this.LimitStates(i).LimitStateFunction  = LimitStatesInput{i,2};
% %             end
%         end
        
        %Set AggregateFunction
        function set.AggregateFunction(this, AggregateFunction)
            ProbabilisticChecks.CheckInputClass(AggregateFunction,'function_handle')
            this.AggregateFunction  = AggregateFunction;
        end
        
        %% Other methods
        function zvalue = Evaluate(this,un, beta, RandomVariables)
            input   = cell(length(this.LimitStates),2);
            for i=1:length(this.LimitStates)
                input{i,2}  = this.LimitStates(i).Name;
                input{i,2}  = Evaluate@LimitState(un, beta, RandomVariables);
            end
            zvalue          = feval(this.AggregateFunction, input);
            this.ZValues    = [this.ZValues zvalue];
        end
    end
end
