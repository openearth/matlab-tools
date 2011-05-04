function varargout = delft3d_io_mor(varargin)
%DELFT3D_IO_MOR   load delft3d online sed *.mor keyword file 
%
%  D   = DELFT3D_IO_MOR(fname)
% 
% loads contents of *.mor file into struct D
%
%  [D,U]   = DELFT3D_IO_MOR(fname)
%  [D,U,M] = DELFT3D_IO_MOR(fname)
%
% optionally loads units and meta-info into structs U and M.
%
% Also works for *.sed files that have the same *.ini structure, in fact
% DELFT3D_IO_MOR is just a different name for DELFT3D_IO_SED.
%
%See also: delft3d, inivalue, DELFT3D_IO_SED

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

[D,U,M] = delft3d_io_sed(varargin{:});

varargout  = {D,U,M};