function str = createconfig
%CREATECONFIGFILE  Create string with local config settings
%
%   Create an evalstr of a structure containing local config information
%
%   Syntax:
%   str = createconfig
%
%   Output:
%   str = string containing config
%
%   Example
%   createconfigfile
%
%   See also getenv

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% Created: 21 Nov 2008
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: createconfig.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/config_FUN/createconfig.m $

%%
str = sprintf('config = struct(...\n');
str = sprintf('%s\t%s\n', str, ['''NAME'', ''' getenv('USERNAME') ''',...']);
str = sprintf('%s\t%s\n', str, '''COMPANY'', ''<COMPANY>'',...');
str = sprintf('%s\t%s\n', str, '''ADDRESS'', {{''<ADDRESS>''}},... % address must be written as: {{''line1'' ''line2'' ''line3'' ''linen''}}');
str = sprintf('%s\t%s\n', str, '''EMAIL'', ''<EMAIL>'');');
