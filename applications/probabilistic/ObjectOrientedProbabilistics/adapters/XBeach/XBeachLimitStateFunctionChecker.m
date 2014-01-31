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
        Abort
        Delay
        TimeOut
        Timer
        SimulationFolder
    end
    
    %% Events
    events
        SimulationStarted
        SimulationCompleted
        SimulationNotCompleted
    end
    
    %% Methods
    methods
        %% Constructor
        function this = XBeachLimitStateFunctionChecker(limitState)
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
            
            addlistener(limitState, 'SimulationCompleted')%, @limitState.CallBackMethod)
            addlistener(limitState, 'SimulationNotCompleted')
            this.SetDefaults
        end
        
        %% Other methods
        % Check whether the simulation is done
        function CheckProgress(this)
            this.Timer  = timer('TimerFcn', @(h,e)this.StopWaiting, 'StartDelay', this.TimeOut);
            start(this.Timer);
            
            while ~this.Abort
                if this.CheckLogFile
                    notify(this, 'SimulationCompleted');
                end
                pause(this.Delay)
            end
        end
        
        % Check XBeach logfile to see if it's done
        function completed = CheckLogFile(this)
            % TODO!!!! Figure out how you know here in which folder to check
            completed   = false;
            if exist(fullfile(this.SimulationFolder,'xboutput.nc'),'file') ...
                    && ~exist(fullfile(this.SimulationFolder,'XBerror.txt'),'file')
                completed   = true;
            end
        end
        
        % Stop waiting for the simulation to end
        function StopWaiting(this)
            this.Abort  = true;
            notify(this, 'SimulationNotCompleted')
        end
        
        % Set default property values
        function SetDefaults(this)
            this.Abort      = false;
            this.Delay      = 5;
            this.TimeOut    = 900; 
        end
    end
end
