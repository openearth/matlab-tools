function TeamCity_waterbase(varargin)
%TEAMCITYRUNOETTESTS  Function that runs all tests available in the OpenEarthTools repository.
%
%   This function gathers and runs all tests in the OpenEarthTools repository.
%
%   Syntax:
%   teamcityrunoettests;
%
%   See also mtestengine mtest oetruntests

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
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
% Created: 15 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

try %#ok<TRYNC>
    mlock;

    %% First load oetsettings
    try
        TeamCity_initialize;

    catch me
        TeamCity.postmessage('message', 'text', 'Matlab was unable to run oetsettings.',...
            'errorDetails',me.getReport,...
            'status','ERROR');
        TeamCity.postmessage('progressFinish','Run Oetsettings');
        TeamCity.postmessage('buildStatus',...
                'status','FAILURE',...
                'text', 'FAILURE: Matlab was unable to run oetsettings.');
%            rethrow(me);
         exit;
    end

    try
        TeamCity.postmessage('message', 'text', ['Run ' ...
                            'waterbase']);
        rws_waterbase_all('download', 1, 'make_nc', 1, ...
                          'make_catalog', 1, 'make_kml', 1)
        TeamCity.postmessage('message', 'text', ['Finished ' ...
                                'running waterbase '])
    catch me
        TeamCity.postmessage('message', 'text', 'Matlab was unable to run waterbase.',...
                'errorDetails',me.getReport,...
                             'status','ERROR');
        TeamCity.postmessage('buildStatus',...
                             'status','FAILURE',...
                             'text', ['FAILURE: Matlab was unable ' ...
                            'to create the waterbase dataset.']);
    end
    exit;
end

end
