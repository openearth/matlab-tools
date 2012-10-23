classdef LimitState < handle
%LIMITSTATE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = LimitState(varargin)
%
%   Input: For <keyword,value> pairs call LimitState() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   LimitState
%
%   See also

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
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Properties

    properties (SetAccess = private)
        name
        LimitStateFunction
        betas   = [];
        Zvalues = [];
    end

%% Methods

    methods 
        %Constructor
        function newLimitState = LimitState(name, LimitStateFunction)
            newLimitState.name                  = name;
            newLimitState.LimitStateFunction    = LimitStateFunction;
        end
        
        %Evaluate LSF at given point in U (standard normal) space
        function evaluateLSFinU(thisLimitState, un, beta, StochVars)
            if ~iscell(StochVars)
                StochVars               = {StochVars};
            end
            u                           = un.*beta;
            input                       = cell(2,size(StochVars));
            for i=1:length(StochVars)
                if isa(StochVars{1},'StochVar')
                    StochVars{i}.addValue(u(i));
                    input{1,i}  = StochVars{i}.name;
                    input{2,i}  = StochVars{i}.Xvalues(end);
                else
                    error('Stochastic variable objects should have the class StochVar!')
                end
            end
            thisLimitState.betas        = [thisLimitState.betas beta];
            thisLimitState.evaluateLSF(input);
        end
        
        %Evaluate LSF at given point in X space
        function evaluateLSF(thisLimitState, input)
            valZ    = feval(thisLimitState.LimitStateFunction,input{:});
            thisLimitState.Zvalues  = [thisLimitState.Zvalues valZ];
        end
    end
end