function OPT = ncgen_surface_adf(varargin)
%NCGEN_SURFACE_XYZ  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   OPT = ncgen_surface_adf(varargin)
%
%   Input:
%   varargin =
%
%   Output:
%   OPT      =
%
%   Example
%   ncgen_surface_adf
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Kees den Heijer / Wiebe de Boer
%
%       Kees.denHeijer@Deltares.nl / Wiebe.deBoer@Deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Apr 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Define schemaFcn, readFcn and writeFcn
% Define appropriate functions dependant on the dataset as ex[plained
% above. Note that each function requires a fixed set of inputs. 
schemaFcn   = @(OPT)              ncgen_schemaFcn_surface  (OPT);
readFcn     = @(OPT,writeFcn,fns) ncgen_readFcn_surface_adf(OPT,writeFcn,fns);
writeFcn    = @(OPT,data)         ncgen_writeFcn_surface   (OPT,data);

% by passing these functions to the main function, an OPT structure is
% returned that can then be inspecdted to see which properties can be set.
if nargin == 0
    OPT         = ncgen_mainFcn(schemaFcn,readFcn,writeFcn);
    return
end

OPT = ncgen_mainFcn(schemaFcn,readFcn,writeFcn,varargin{:});

