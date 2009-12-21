function url = vaklodingen_url
% VAKLODINGEN_URL returns the links to the vaklodingen netCDF's. 
%
% Returns the links to the vaklodingen netCDF files. If the vaklodingen
% netCDF are available locally on the Deltares network, this is returned, 
% otherwise the internet link is returned
% 
% See also: nc_dump, nc_varget

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 <Deltares>
%       Thijs Damsma
%
%       <Thijs.Damsma@Deltares.nl>	
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
% Created: 04 Aug 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

if exist(fullfile('P:','mcdata','opendap','rijkswaterstaat','vaklodingen'),'dir')
	names = dir(fullfile('P:','mcdata','opendap','rijkswaterstaat','vaklodingen','vaklodingen*.nc'));
    for ii = 1:length(names)
        url{ii} = fullfile('P:','mcdata','opendap','rijkswaterstaat','vaklodingen',names(ii).name);
    end
else
    url = opendap_folder_contents(...
        'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen');
end

