function knmi_etmgeg2nc_test()
% KNMI_ETMGEG2NC_TEST  viual test for knmi_etmgeg2nc
%
%
%   See also KNMI_ETMGEG2NC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Apr 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

TeamCity.ignore('Test requires user input');

locbase = 'http://opendap.deltares.nl/thredds/dodsC/opendap/';

OPT.directory_nc                           = [locbase,'knmi/etmgeg/'];

fname     = [OPT.directory_nc,'etmgeg_391.nc'];
fname     = [OPT.directory_nc,'etmgeg_210.nc'];

D         = nc2struct(fname);
D.datenum = nc_cf_time(fname);

fldnames = fieldnames(D);

for ifld = 1:length(fldnames)
    fldname = fldnames{ifld};
    
    if isnumeric(D.(fldname)) && ...
            length(D.(fldname)) > 1 && ...
            ~strcmpi(fldname,'time') && ...
            ~strcmpi(fldname,'datenum')
        
        plot(D.datenum,D.(fldname));
        datetick('x')
        title({[char(D.station_name),': ',num2str(D.station_id)],...
            mktex(fldname)})
        grid on
        text(0,1,[' values [1 2 end-1 end]: ',num2str(D.(fldname)([1 2 (end-1) end]))],'units','normalized','verticalalignment','top')
        pausedisp
        
    end
    
end