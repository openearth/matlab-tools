classdef MClassFile < MFile & handle
    %MCLASS  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also MClass.MClass
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2010 Deltares
    %       Pieter van Geer
    %
    %       pieter.vangeer@deltares.nl
    %
    %       Rotterdamseweg 185
    %       2629 HD Delft
    %       P.O. 177
    %       2600 MH Delft
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
    % Created: 30 Nov 2010
    % Created with Matlab version: 7.11.0.584 (R2010b)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        
        ClassHeader = '';                % Header of the test(case) function (first line)
        ClassName = '';                  % Name of the test(case) function
        
        H1Line   = [];                   % A one line description of the test (h1 line)
        Description = {};                % Detailed description of the test that appears in the help block
        Author   = [];                   % Last author of the test (obtained from svn keywords)
        SeeAlso  = {};                   % see also references
        
        Properties;
        Methods;
        Events;
    end
end
