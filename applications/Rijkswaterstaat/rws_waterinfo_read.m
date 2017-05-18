function [Station,Time,Val,EPSG,x,y] = RWS_waterinfo_read(fname)
%RWS_WATERINFO_READ  Function to read .csv files downloaded from waterinfo
%
%   https://waterinfo.rws.nl/. Script assumes a single station per .csv
%   
%   Syntax:
%   [Station,Time,Val,EPSG,x,y] = RWS_waterinfo_read(fname)
%
%   Input:
%   fname           filename of .csv file
%
%   Output:
%   Station         Name of measurement station
%   Time            Time in matlab datenum values. 
%                   Time = [] if no datarow in .csv file!
%   Val             Value of NUMERIEKEWAARDE
%   EPSG            EPSG code of coordinate system
%   x               x-coordinate of station
%   y               y-coordinate  of station
%
%   Example
%   [Station,Time,Val,EPSG,x,y] = RWS_waterinfo_read('d:\waterinfo.csv\')
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       schrijve
%
%       reinier.schrijvershof@deltares.nl
%
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
% Created: 18 May 2017
% Created with Matlab version: 9.0.0.341360 (R2016a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% OPT.keyword=value;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);

%% 1) Read data
delimiter = ';';
startRow = 2;
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s %{dd-MM-yyyy}D %{HH:mm:ss}D %s %q %s %s %s %s %s %s %s %s %s %s %s %s %d %q %*[^\n\r]';
fileID = fopen(fname,'r');
dataArray = textscan(fileID,formatSpec,...
    'Delimiter',delimiter,...
    'HeaderLines',startRow-1,...
    'DateLocale','nl_NL',...
    'ReturnOnError',false);
fclose(fileID);

%% 2) Convert to datenum and values
Time            = datenum([year(dataArray{20}),month(dataArray{20}),day(dataArray{20}),hour(dataArray{21}),minute(dataArray{21}),second(dataArray{21})]);
NUMERIEKEWAARDE = dataArray{23};
NUMERIEKEWAARDE = strrep(NUMERIEKEWAARDE,',','.');
Val             = str2double(NUMERIEKEWAARDE);

% Determine if maximum values should be NaN
Val2 = Val;
Val2(Val == max(Val2)) = NaN;
nnid = isnan(Val2);
Valmean = mean(Val2(~nnid));
Valstd  = std(Val2(~nnid));
if max(Val) > Valmean + 10*Valstd;
    Val = Val2;
end

% Sort dates
[Time,sortID] = sort(Time);
Val           = Val(sortID);

% Multiple date entries on a single date can be present
% TO DO: Averaged values of multiple entries
[Time,IA,IC] = unique(Time);
Val          = Val(IA);


%% 3) Metadata
Station         = dataArray{2}{1};
EPSG            = unique(dataArray{36});
RD              = strsplit(char(unique(dataArray{37})),',');
x               = str2double(RD(1));
y               = str2double(RD(2));

return

