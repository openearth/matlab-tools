classdef XBeachLimitStateFunctionChecker < handle
    %XBEACHLIMITSTATEFUNCTIONCHECKER
    %
    %   Creates an object that checks if an XBeach simulation has finished
    %   yet
    %
    %   See also XBeachLimitStateFunctionChecker.XBeachLimitStateFunctionChecker
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2014 Deltares
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
    % Created: 31 Jan 2014
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        
    end
    
    %% Events
    events
        SimulationStarted
        SimulationCompleted
    end
    
    %% Methods
    methods
        function this = XBeachLimitStateFunctionChecker(varargin)
            %XBEACHLIMITSTATEFUNCTIONCHECKER  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = XBeachLimitStateFunctionChecker(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "XBeachLimitStateFunctionChecker"
            %
            %   Example
            %   XBeachLimitStateFunctionChecker
            %
            %   See also XBeachLimitStateFunctionChecker
        end
    end
end
