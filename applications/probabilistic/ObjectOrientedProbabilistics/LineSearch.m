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
        MaxIterationsFit
        MaxIterationsBisection
        MaxErrorZ
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
        
        %MaxIterationsBisection setter
        function set.MaxErrorZ(this, MaxErrorZ)
            ProbabilisticChecks.CheckInputClass(MaxErrorZ,'double')
                                
            this.MaxErrorZ  = MaxErrorZ;
        end
        
        %% Other methods
        %Find Z=0 for a LSF
        function FindZeroLSF(this,LimitState,RandomVariables)
                                    
        end
        
        %Find Z=0 for an ARS
        function FindZeroARS(this,ARS)
            
        end
    end
    
    methods (Access = protected)
        %Set default values
        function SetDefaults(this)
            this.BetaFirstPoint             = 4;
            this.MaxIterationsFit           = 5;
            this.MaxIterationsBisection     = 5;
            this.MaxErrorZ                  = 1e-2;
        end
    end
end
