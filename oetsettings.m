function oetsettings(varargin)
%OETSETTINGS   enable the OpenEarthTools matlab tools by adding all relevant matlab paths.
%
% OpenEarthTools is a collection of open source tools 
% intended to be licensed under the GNU (Lesser) Public License
% (<a href="http://www.gnu.org/licenses/licenses.html">http://www.gnu.org/licenses/licenses.html</a>).
%
% For more information on OpenEarthTools refer to the following two sources:
%
% * wiki:        <a href="http://OpenEarth.deltares.nl"                               >http://OpenEarth.Deltares.nl</a>
% * repository:  <a href="https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab">https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab</a>
% * help blocks: Scroll through the OpenEarthTools directories and read interesting help blocks.
%
%See also: ADDPATHFAST, RESTOREDEFAULTPATH

%   --------------------------------------------------------------------
%   Copyright (C) <2004-2008> <Deltares>
%
%          <gerben.deboer@deltares.nl>
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

%% TODO remove quickstart option or include in help block
%% TODO rename quickstart (too general name) to DB_mcstart for example ??

   disp('Adding <a href="http://OpenEarth.deltares.nl">OpenEarthTools</a>, please wait ...')
   disp(' ')
      
%% Collect warning and directory state
%% ---------------------
   state.warning = warning;
   state.pwd     = cd;

%% Add paths
%% ---------------------
   basepath = fileparts(which(mfilename));
   warning off
   path(path, fullfile(basepath, 'oet_general'));
   addpathfast(basepath); % excludes *.svn directories!

%% Restore warning and directory state
%% ---------------------
   warning(state.warning)
        cd(state.pwd)

   clear state

%% set svn:keywords automatically to any new m-file
   autosetSVNkeywords
   
%% Report
%% ---------------------
   help oetsettings
   fprintf('\n*** OpenEarthTools settings enabled! ***\n');
   
%% EOF
