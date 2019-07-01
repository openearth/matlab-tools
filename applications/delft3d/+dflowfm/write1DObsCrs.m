function varargout = writeObsCrs1D(varargin)
% Define observational cross-sections 1 net node apart from all boundaries 
% (end points) and surrounding junctions of 1D network and write to *_crs.pli file
%
%
%   Syntax:
%   varargout = writeObsCrs1D('net',net,'crs',crsFile)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   net     = string or structure read by dflowfm.readNet
%   crsFile = filename to *_crs.pli file
%
%   Output:
%   *_crs.pli file with observation cross-sections
%
%   Example
%   Untitled
%
%   See also
%   dflowfm.writeProfdef dflowfm.readProfdef_crs

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 <COMPANY>
%       schrijve
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 01 Jul 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.keyword=value;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
