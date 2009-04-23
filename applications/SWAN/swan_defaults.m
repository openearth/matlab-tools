function DAT = swan_defaults
%SWAN_DEFAULTS            returns SWAN default SET settings
%
%  DAT.set.level    = 0;
%  DAT.set.nor      = 90;
%  DAT.set.depmin   = 0.05;
%  DAT.set.maxmes   = 200;
%  DAT.set.maxerr   = 1;
%  DAT.set.naut     = false; % means default cartesian
%  DAT.set.grav     = 9.81;
%  DAT.set.rho      = 1025;
%  DAT.set.inrhog   = 0;
%  DAT.set.hserr    = 0.10;
%
%  DAT.set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
%  DAT.set.froudmax = 0.80;
%  DAT.set.printf   = 4;
%  DAT.set.prtest   = 4;
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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

   DAT.set.level    = 0;
   DAT.set.nor      = 90;
   DAT.set.depmin   = 0.05;
   DAT.set.maxmes   = 200;
   DAT.set.maxerr   = 1;
   DAT.set.naut     = false; % means default cartesian
   DAT.set.grav     = 9.81;
   DAT.set.rho      = 1025;
   DAT.set.inrhog   = 0;
   DAT.set.hserr    = 0.10;
  %NAUTical/CARTesian
   DAT.set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
   DAT.set.froudmax = 0.80;
   DAT.set.printf   = 4;
   DAT.set.prtest   = 5;
   
%% EOF   