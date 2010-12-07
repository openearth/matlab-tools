classdef MFileFactory
    %MFILEFACTORY  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also MFileFactory.MFileFactory
    
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
    % Created: 03 Dec 2010
    % Created with Matlab version: 7.11.0.584 (R2010b)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        
    end
    
    %% Methods
    methods (Static = true)
        function argsout = readmfile(mFile,varargin)
            %MFILEFACTORY  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = MFileFactory(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "MFileFactory"
            %
            %   Example
            %   MFileFactory
            %
            %   See also MFileFactory
            
            argsout = MFileFactory.retrievefilenamefrominput(mFile,varargin{:});
            MFileFactory.retrievestringfromdefinition(mFile);
        end
    end
    methods (Static = true, Hidden = true)
        function argsout = retrievefilenamefrominput(mfile,varargin)
            %% Retrieve filename from input
            fname = [];
            if ischar(varargin{1}) && ~strcmpi(varargin{1},'filename')
                fname = varargin{1};
                varargin(1)=[];
            else
                id = find(strcmpi(varargin,'filename'),1,'first');
                if ~isempty(id)
                    fname = varargin{id+1};
                    varargin(id:id+1) = [];
                end
            end
            argsout = varargin;
            
            %% split filename into parts
            [pt fn ext] = fileparts(fname);
            if isempty(ext)
                ext = '.m';
            end
            if ~strcmp(ext,'.m')
                error('MTest:NoMatlabFile','Input must be a matlab (*.m) file');
            end
            
            %% Check file existance
            if exist(fullfile(pt,[fn ext]),'file')
                if isempty(pt)
                    pt = fileparts(which([fn ext]));
                end
            else
                % if fullname does not exist, try which
                fls = which(fn,'-all');
                if length(fls)>1
                    warning('MTestFactory:MultipleFiles','Multiple files were found with the same name. The first one in the search path is taken.');
                elseif length(fls) == 1
                    % just take this file (path appears to be wrong)
                else
                    % File can not be found
                    error('MTestFactory:NoFile','Input file could not be found.');
                end
                [pt fn] = fileparts(fls{1});
            end
            mfile.FileName = fn;
            mfile.FilePath = pt;
        end
        function obj = retrievestringfromdefinition(obj)
            %% #1 Open the input file
            % first try full file name
            fid = fopen(fullfile(obj.FilePath,[obj.FileName '.m']));
            %% #2 Read the contents of the file
            str = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',10000);
            str = str{1};
            %% #3 Close the input file
            fclose(fid);
            %% #4 Process contents of the input file
            obj.FullString = str;
            %% #5 Add timestamp
            infoo = dir(fullfile(obj.FilePath,[obj.FileName '.m']));
            obj.TimeStamp = infoo.datenum;
        end
    end
end
