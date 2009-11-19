function [OPT Set Default] = setproperty(OPT, varargin)
% SETPROPERTY  generic routine to set values in PropertyName-PropertyValue pairs
%
% Routine to set properties based on PropertyName-PropertyValue 
% pairs (aka <keyword,value> pairs). Can be used in any function 
% where PropertyName-PropertyValue pairs are used.
%   
% syntax:
% [OPT Set Default] = setproperty(OPT, varargin{:})
%  OPT              = setproperty(OPT, 'PropertyName', PropertyValue,...)
%  OPT              = setproperty(OPT, OPT2)
%
% input:
% OPT      = structure in which fieldnames are the keywords and the values are the defaults 
% varargin = series of PropertyName-PropertyValue pairs to set
% OPT2     = is a structure with the same fields as OPT. 
%
%            Internally setproperty translates OPT2 into a set of
%            PropertyName-PropertyValue pairs (see example below) as in:
%            OPT2    = struct( 'propertyName1', 1,...
%                              'propertyName2', 2);
%            varcell = reshape([fieldnames(OPT2)'; struct2cell(OPT2)'], 1, 2*length(fieldnames(OPT2)));
%            OPT     = setproperty(OPT, varcell{:});
%
% output:
% OPT     = structure, similar to the input argument OPT, with possibly
%           changed values in the fields
% Set     = structure, similar to OPT, values are true where OPT has been 
%           set (and possibly changed)
% Default = structure, similar to OPT, values are true where the values of
%           OPT are equal to the original OPT
%
% Example:
%
% +------------------------------------------->
% function y = dosomething(x,'debug',1)
% OPT.debug  = 0;
% OPT        = setproperty(OPT, varargin{:});
% y          = x.^2;
% if OPT.debug; plot(x,y);pause; end
% +------------------------------------------->
%
% See also: VARARGIN, STRUCT, MERGESTRUCTS


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Divert to old name
% For the moment use the old name with uppercase. setProperty should be renamed to this function
% name (see matlab style guide).

[OPT, Set, Default] = setProperty(OPT, varargin{:});