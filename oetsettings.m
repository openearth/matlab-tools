function oetsettings(varargin)
%OETSETTINGS   enable the OpenEarthTools matlab tools by adding all relevant matlab paths.
%
% OpenEarthTools is a collection of open source tools 
% intended to be licensed under the (<a href="http://www.gnu.org/licenses/licenses.html">GNU (Lesser) Public License</a>).
%
% In order to suppress this information, run the function with input argument quiet:
%	"oetsettings('quiet');" or "oetsettings quiet"
%
% For more information on OpenEarthTools refer to the following sources:
%
% * wiki:        <a href="http://OpenEarth.nl">OpenEarth.nl</a>
% * repository:  <a href="https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab">https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab</a>
% * help blocks: Scroll through the OpenEarthTools directories by clicking 
%                to see also links, or typing:
%
%    help oetsettings
%    help general
%    help applications
%    help io
%	
%See also: ADDPATHFAST, RESTOREDEFAULTPATH,
%          OpenEarthTools: general, applications, io, tutorials

%% Copyright notice
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
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

%% Retrieve verbose state from input
% -----------------------
   OPT.quiet = false;
   nextarg   = 1;
   
   if mod(nargin,2)==1 % odd # arguments
       if strcmp(varargin{1},'quiet')
       OPT.quiet = true;
       else
          error(['unknown argument:',varargin{1}])
       end
       nextarg   = 2;
   end
   
   OPT = setProperty(OPT,varargin{nextarg:end});
   
%% Acknowledge user we started adding the toolbox
% -----------------------
   if ~(OPT.quiet)
       disp('Adding <a href="http://OpenEarth.deltares.nl">OpenEarthTools</a>, please wait ...')
       disp(' ')
   end
      
%% Collect warning and directory state
% -----------------------
   state.warning = warning;
   state.pwd     = cd;

%% Add paths
% -----------------------
   basepath = fileparts(mfilename('fullpath'));
   warning off
   addpathfast(basepath); % excludes *.svn directories!

%% Create tutorial search database
% ------------------------
 
    disp('Creating <a href="http://OpenEarth.deltares.nl">OpenEarthTools</a> search database, please wait ...')
    try % does not work when using read-only checkout
        DocumentationExists = exist(fullfile(oetroot,'docs','OpenEarthDocs','oethelpdocs','helptoc.xml'),'file');
        if DocumentationExists && exist('builddocsearchdb','file')
            builddocsearchdb(fullfile(oetroot,'docs','OpenEarthDocs','oethelpdocs'));
        end
    catch
        warning('OET:NoSearchDB',['Could not build search database because ',oetroot,' is read-only.', char(10),...
            'the OpenEarthTools help documentation is still available in the matlab help navigator.']);
    end
    
%% Restore warning and directory state
% -----------------------
   warning(state.warning)
        cd(state.pwd)

   clear state

%% set svn:keywords automatically to any new m-file
% -----------------------
   autosetSVNkeywords
   
%% NETCDF (if not present yet)
%  (NB RESTOREDEFAULTPATH does not restore java paths)
% -----------------------
   java2add         = path2os(fullfile(oetroot, '/io/nctools', 'toolsUI-2.2.22.jar'));
   dynjavaclasspath = path2os(javaclasspath);
   indices          = strfind(dynjavaclasspath,java2add);
    
   if isempty(cell2mat(indices))
      javaaddpath (java2add)
   elseif ~(OPT.quiet)
      disp(['Java path not added, already there: ',java2add]);
      disp(' ');
   end
   setpref ('SNCTOOLS', 'USE_JAVA', true); % this requires SNCTOOLS 2.4.8 or better
    
%% Report
% -----------------------
   if ~(OPT.quiet)
       help oetsettings
       fprintf('\n*** OpenEarthTools settings enabled! ***\n');
   end
   
%% EOF


