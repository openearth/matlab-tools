function set = swan_defaults
%SWAN_DEFAULTS            returns SWAN default SET settings
%
%    set = swan_defaults()
%
% returns
%
%   set.level    = 0;
%   set.nor      = 90;
%   set.depmin   = 0.05;
%   set.maxmes   = 200;
%   set.maxerr   = 1;
%   set.naut     = false; % means default cartesian
%   set.grav     = 9.81;
%   set.rho      = 1025;
%   set.inrhog   = 0;
%   set.hsrerr   = 0.10;
%
%   set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
%   set.froudmax = 0.80;
%   set.printf   = 4;
%   set.prtest   = 4;
%
%See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_GRD, SWAN_IO_BOT, 
%          SWAN_SHORTNAME2KEYWORD, SWAN_QUANTITY

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

   set.level    = 0;
   set.nor      = 90;
   set.depmin   = 0.05;
   set.maxmes   = 200;
   set.maxerr   = 1;
   set.naut     = false; % means default cartesian
   set.grav     = 9.81;
   set.rho      = 1025;
   set.inrhog   = 0;
   set.hsrerr   = 0.10;
  %NAUTical/CARTesian
   set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
   set.froudmax = 0.80;
   set.printf   = 4;
   set.prtest   = 5;
   
%% EOF   