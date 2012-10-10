function labels = ticktext_datetime2(ticks)
%TICKTEXT_DATETIME2  Multiline scalable datetime formatting function for ticktext labels
%
%   Multiline scalable datetime formatting function for ticktext labels.
%   This function differs from ticktext_datetime in that it minimizes the
%   number of ticktext label lines.
%   It uses the following formats, but only selects the lowest level
%   distinct value from the resulting labels and uses the entire labels
%   only for the first tick:
%
%       'yyyy'
%       'mmm-yyyy'
%       'dd-mmm-yyyy'
%       {'dd-mmm-yyyy' 'HH:MM'}
%       {'dd-mmm-yyyy' 'HH:MM' 'SS'}
%
%   Syntax:
%   labels = ticktext_datetime2(ticks)
%
%   Input:
%   ticks     = Array with datenum tick values
%
%   Output:
%   labels    = Cell array with ticktext labels
%
%   Example
%   labels = ticktext_datetime2(now+[0:.25:3])
%
%   See also ticktext, ticktext_multiline_scalable, ticktext_datestr

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 10 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% determine ticklabels

formats = {                         ...
    'yyyy',                         ...
    'mmm-yyyy',                     ...
    'dd-mmm-yyyy',                  ...
    {'dd-mmm-yyyy' 'HH:MM'},        ...
    {'dd-mmm-yyyy' 'HH:MM' 'SS'}        };

fcn = @datestr;

labels0 = ticktext_multiline_scalable(ticks, fcn, formats);
labels  = cell(size(labels0));

% flatten ticklabels as much as possible by selecting lowest distinct level
% of ticktext label lines. Include the entire range of ticklabels for the
% first and last tick to set the scope.
for i = 1:length(labels0)
    if i > 1
        j1 = 0;
    else
        j1 = 1;
    end
    
    j2 = length(labels0{i});
    for j = 1:length(labels0{i})
        if j1 == 0
            if ~strcmpi(labels0{i}{j}, labels0{i-1}{j})
                j1 = j;
            end
        else
            if ~isempty(regexp(labels0{i}{j},'^[0:]+$','once'))
                j2 = j-1;
                break;
            end
        end
    end
    labels{i} = labels0{i}(max(j1,1):j2);
end
