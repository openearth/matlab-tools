function varargout = jarkus_plot_transect(varargin)
%JARKUS_PLOT_TRANSECT  Plot JARKUS transect
%
%   Plot one single transect of one year. Specify 'id' and 'year' as
%   propertynam-propertyvalue pairs. The plot handle can be obtained as
%   output argument.
%
%   Syntax:
%   varargout = jarkus_plot_transect(varargin)
%
%   Input:
%   varargin  = propertyname-propertyvalue pairs as suitable for
%               jarkus_transects function
%
%   Output:
%   varargout = plot handle
%
%   Example
%   jarkus_plot_transect('id', 7005375, 'year', 2010)
%
%   See also jarkus_transects

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Feb 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% defaults and input check
% check number of input arguments
error(nargchk(1, Inf, nargin))

if isscalar(varargin) && isstruct(varargin{1})
    % structure input argument is assumed to be created by jarkus_transects
    tr = varargin{1};
else
    if ~all(ismember({'id' 'year'}, varargin(1:2:end)))
        error('At least "id" and "time" should be specified')
    end
    % transect structure is obtained by jarkus_transects
    tr = jarkus_transects(varargin{:});
end

%%
required_fields = {'cross_shore' 'altitude'};
if all(ismember(required_fields, fieldnames(tr)))
    altitude = squeeze(tr.altitude);
    if isempty(altitude)
        error('no data available for selected transect')
    elseif ~isvector(altitude)
        TODO('Implement support for multiple transects/years')
    else
        nnid = ~isnan(altitude);
        ph = plot(tr.cross_shore(nnid), altitude(nnid));
        % create displayname (to be used in legend)
        displayname = '';
        if ismember('id', fieldnames(tr))
            displayname = sprintf('%stransect %i', displayname, tr.id);
        end
        if ismember('time', fieldnames(tr))
            dmy = datevec(tr.time + datenum(1970,1,1));
            displayname = sprintf('%s (%i)', displayname, dmy(1));
        end
        displayname = strtrim(displayname);
        set(ph,...
            'DisplayName', displayname);
    end
else
    error(['The following required fields are not found: ' sprintf('"%s" ', required_fields{~ismember(required_fields, fieldnames(tr))})])
end

if nargout > 0
    varargout = {ph};
end