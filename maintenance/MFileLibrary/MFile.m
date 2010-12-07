classdef MFile < handle
    %MFILE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also MFunction MClass
    
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
        FileName = [];                      % Original name of the testfile
        FilePath = [];                      % Path of the "_test.m" file
        TimeStamp = [];                     % Timestamp of the last time the definition was saved
    end
    
    properties (Hidden = true)
       FullString = [];                    % Full string of the contents of the test file
    end
    
    methods 
        function isUpToDate = verifytimestamp(this)
            isUpToDate = false;

            fullname = fullfile(this.FilePath, [this.FileName ,'.m']);
            if ~exist(fullname,'file')
                fullname = which(this.FileName);
                if ~exist(fullname,'file')
                    warning('MTest:DefinitionNotFound',['MFile tried to verify the timestamp of test: "' this.FileName '", but failed to do so because of a missing test definition']);
                    return;
                end
                warning('MTest:DefinitionMoved',['MTest could not find a file that exactly matches this test objects definition',char(10),...
                    '(' fullfile(this.FilePath,[this.FileName '.m']),char(10),'but for timestamp verification used:',char(10),...
                    fullname]);
                this.FilePath = fileparts(fullname);
            end
            
            fileinfo = dir(fullname);
            isUpToDate = this.TimeStamp == fileinfo.datenum;
        end
    end
end
