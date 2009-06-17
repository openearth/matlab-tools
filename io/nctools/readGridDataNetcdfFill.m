function d = readGridDataNetcdfFill(varargin)
%READGRIDDATANETCDFFILL  Function to read a set of RWS grids from a url
%
%   Fills NaN with data from previous years.
%
%   Syntax:
%   varargout = readGridDataNetcdf(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   readGridDataNetcdfFill
%
%   See also readGridDataNetcdf

%   --------------------------------------------------------------------
%   Copyright (C) 2009 <COMPANY>
%       
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% Created: 22 Mar 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%%
% datatype -> number or string
% (http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/
% vaklodingen/catalog.html)
% name -> 
% year 
% soundingID
url = NaN;
name = NaN;
year = NaN;
soundingID = NaN;
switch nargin
    case 0
        return
    case 1
        [url] = deal(varargin{:});
        % 1 argument, get all grids? This won't work.
    case 2
        % 2 arguments return the grid with the given mapid
        
        [url, name] = deal(varargin{:});
    case 3
        % year is actually not enough because there are more than 1 samples
        % /year
        [url, name, year] = deal(varargin{:});
    case 4
        % not sure what the sounding id is?
        [url, name, year, soundingID] = deal(varargin{:});
end

d = creategridstruct();
x = nc_varget(url, 'x');
y = nc_varget(url, 'y');
dates = udunits2datenum(nc_varget(url, 'time'),'days since 1970-1-1 00:00:00 +01:00');
datematrix = cell2mat(arrayfun(@datevec, dates, 'UniformOutput', false));

if (~isnan(year))
    date_indices = find(datematrix(:,1) == year);
else
    date_indices = 1:length(dates);
end
Z = nc_varget(url, 'z', [date_indices(1)-1, 0, 0], [1, length(y), length(x)]);
for i=1:length(date_indices)
    % assume ordering by date
    disp(['Getting ' datestr(dates(date_indices(i)))])
    newZ = nc_varget(url, 'z', [date_indices(i)-1, 0, 0], [1, length(y), length(x)]);
    newZ(newZ==-9999)=nan;
    Z(~isnan(newZ)) = newZ(~isnan(newZ)); % update non none values
end
d.Z = Z;    
d.X = repmat(x, [1, length(y)])';
d.Y = repmat(y, [1, length(x)]);
d.contour = [min(x), min(y); min(x), max(y); max(x), max(y); max(x), min(y); min(x),min(y)];
d.xllcorner = min(x);
d.yllcorner = min(y);
d.year = datematrix(date_indices,1);
d.cellsize = x(2) - x(1);

end
