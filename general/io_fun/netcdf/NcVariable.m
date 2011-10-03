classdef NcVariable < handle
    %NCVARIABLE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also NcVariable.NcVariable
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2011 Deltares
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
    % Created: 30 Sep 2011
    % Created with Matlab version: 7.12.0.635 (R2011a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        FileName
        Name
        NcType
        DataType
        Unlimited
        Dimensions
        Size
        Attributes
    end
    
    %% Methods
    methods
        function this = NcVariable(url,variableInfo,dimensions)
            %NCVARIABLE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = NcVariable(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "NcVariable"
            %
            %   Example
            %   NcVariable
            %
            %   See also NcVariable
            
            %% return empty object when no input is given
            if nargin == 0
                return;
            end
            
            %% Cal with (url, variablename), retrieve info object
            if ischar(variableInfo)
                info = nc_info(url);
                variableInfo = info.Dataset(ismember({info.Dataset.Name}',variableInfo));
            end
            
            %% Get dimensions
            if nargin == 2
                info = nc_info(url);
                dimensions = NcDimension(url,info.Dimension);
            end
            
            if isempty(variableInfo)
                this(1) = [];
            elseif length(variableInfo) > 1
                %% multiple variables
                this(1,length(variableInfo)) = NcVariable;
                for i = 1:length(variableInfo)
                    this(i) = NcVariable(url,variableInfo(i),dimensions);
                end
            else
                %% Set properties
                this.FileName = url;
                this.Name = variableInfo.Name;
                this.NcType = variableInfo.Nctype;
                this.DataType = variableInfo.Datatype;
                this.Unlimited = variableInfo.Unlimited;
                this.Dimensions = dimensions(ismember({dimensions.Name}',variableInfo.Dimension));
                this.Size = variableInfo.Size;
                this.Attributes = variableInfo.Attribute;
            end
        end
        function sz = getsize(this)
            if (length(this) > 1)
                sz = size(this);
            else
                sz = this.Size;
            end
        end
    end
    methods (Hidden = true)
        function ind = end(this,k,n)
            if length(this) > 1
                szd = size(this);
            else
                szd = this.Size;
            end
            if k < n
                ind = szd(k);
            else
                ind = prod(szd(k:end));
            end
        end
        function varargout = subsref(this,s)
            switch s(1).type
                % Use the built-in subsref for dot notation
                case '.'
                    for i = 1:length(this)
                        varargout{i} = builtin('subsref',this(i),s);
                    end
                case '()'
                    if length(s)<2
                        %% Retrieve data from file
                        if length(this) > 1
                            if length(s.subs) > length(size(this))
                                error('Unknown reference');
                            end
                            varargout{1} = builtin('subsref',this,s);
                            return;
                        end
                        if length(s.subs) > length(this.Size)
                            error(['This variable has only ' num2str(length(this.Size)) ' dimensions']);
                        end
                        
                        nDims = length(this.Dimensions);
                        start = nan(1,nDims);
                        len = nan(1,nDims);
                        stride = nan(1,nDims);
                        for i = 1:length(this.Dimensions)
                            if length(s.subs) < i
                                start(i) = 0;
                                len(i) = inf;
                                stride(i) = 1;
                            else
                                [start(i) len(i) stride(i)] = parsesubs(s.subs{i});
                            end
                        end
                        varargout{1} = nc_varget(this.FileName,this.Name,start,len,stride);
                        
                        return
                    else
                        %% reference to one of the objects in the array
                        varargout{1} = builtin('subsref',this,s);
                    end
                case '{}'
                    % No support for indexing using '{}'
                    error('NcVariable:subsref',...
                        'Not a supported subscripted reference')
            end
        end
        function val = double(this)
            val = nc_varget(this.FileName,this.Name);
        end
    end
end

function [start len stride] = parsesubs(sub)
if islogical(sub)
    sub = find(sub==1);
end

if ischar(sub)
    if strcmp(sub,':')
        start = 0;
        len = inf;
        stride = 1;
        return;
    else
        error('Index exceeds matrix dimensions.');
    end
end
if isnumeric(sub)
    if length(sub) == 1
        start = sub - 1;
        len = 1;
        stride = 1;
        return;
    end
    d = diff(sub);
    if length(unique(d)) == 1
        start = min(sub)-1;
        stride = d(1);
        len = floor((max(sub) - min(sub)) / stride);
    else
        error('Need a constant stride');
        % TODO: come up with a solution
    end
end

end