% OOP.SETPROPERTY adds setproperty-like capabilities to a class.
%    
%   See also oop.handle_light, oop.inspectable

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Thijs Damsma
%
%       Thijs.Damsma@VanOord.com
%
%       Schaardijk 211
%       3063 NH
%       Rotterdam
%       Netherlands
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
% Created: 21 Feb 2014
% Created with Matlab version: 8.3.0.73043 (R2014a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
classdef (Abstract) setproperty < oop.handle_light
    methods
        function set(self,varargin)
            if nargin == 1
                % short circuit when nothing to set
                return
            end
            
            % use arrayfun when assignments to multiple objects are made simultaneously
            if numel(self)>1
                arrayfun(@(self) self.set(varargin{:}),self);
            end
            
            % input check
            
            % possible are keyword/value pairs, or a single struct
            if nargin == 2
                % assume struct
                assert(isstruct(varargin{1}),...
                    'Could not set object of class ''%s'',\nExpected varargin to be a single struct, or keyword/value pairs',class(self));
                prop_names     = fieldnames(varargin{1});
                prop_values    = struct2cell(varargin{1});
            else
                % check for odd number of inputs
                assert(rem(nargin,2)==1,...
                    'Could not set object of class ''%s'',\nExpected varargin to be a single struct, or keyword/value pairs',class(self));
                prop_names     = varargin(1:2:end);
                prop_values    = varargin(2:2:end);
            end
            
            availabe_props = properties(self);
            
            for ii = 1:length(prop_names)
                prop_name = prop_names{ii};
                % allow property assignment with different case with
                % warnings
                n = strcmpi(prop_name,availabe_props);
                if any(n)
                    % if there is exactly one match, check case
                    if sum(n) == 1 && ~strcmp(prop_name,availabe_props{n})
                        error('Could not set ''%s'' for object of class ''%s'',\n Did you mean ''%s''?',...
                            prop_name,class(self),availabe_props{n});
                    end
                    if ~isequaln(self.(prop_name),prop_values{ii})
                        % pass non-default values to self
                        self.(prop_name) = prop_values{ii};
                    end
                else
                    msg = [...
                        sprintf('Unknown property: ''%s'' for object of class ''%s''\n',prop_name,class(self)),...
                        sprintf('Available properties are:\n'),...
                        sprintf('   %s \n',availabe_props{:})];
                    error('TEXTBOX:IllegalProperty',...
                        msg);
                end
            end
        end
    end
end