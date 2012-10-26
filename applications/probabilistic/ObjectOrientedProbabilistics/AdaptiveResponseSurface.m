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
    end
    properties (SetAccess = private)
        Fit
        GoodFit
    end
    
    %% Methods
    methods
        %% Constructor
        function this = AdaptiveResponseSurface(varargin)
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
        end
        
        %% Setters
        function set.Name(this, name)
            ProbabilisticChecks.CheckInputClass(name,'char')
            this.Name   = name;
        end
        
        %% Getters
        
        %% Other methods
        %update ARS fit
        function UpdateFit(this, LimitState)
            this.Fit    = [];
            this.GoodFit = [];
        end
    end
end
