function varargout = mvbLogin(varargin);
%MVBLOGIN Login script for Meetnet Vlaamse Banken API.
%
%   This script logs in into the API of Meetnet Vlaamse Banken (Flemish
%   Banks Monitoring Network API). The login returns a token, which must be
%   sent with every further request. This token is wrapped in a Matlab
%   weboptions struct.
%
%   After login, data can be requested by MVBGETDATA.
%   The catalog of available data can be reqested with MVBCATALOG
%
%   The token is valid for 3600s, after that you must login again.
%
%   A login can be requested freely from: https://meetnetvlaamsebanken.be/
%
%   Syntax:
%   token = mvbLogin(varargin);
%
%   Input: For <keyword,value> pairs call mvbLogin() without arguments.
%   varargin  =
%       username: 'string'
%           Username for meetnetvlaamsebanken.be.
%       password: 'string'
%           Password for meetnetvlaamsebanken.be.
%       apiurl: 'string'
%           URL to the API (should not change)
%
%   Output:
%   varargout =
%       token: <weboptions object>
%           Weboptions object containing the accesstoken. 
%       cred: struct
%           Overview of login parameters.
%
%   Example:
%   token = mvbLogin('username','name@company.org','password','P4ssw0rd');
%
%   See also: MVBCATALOG, MVBGETDATA.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be 
%       l.w.m.roest@tudelft.nl
%
%       KU Leuven campus Bruges,
%       Spoorwegstraat 12,
%       8200 Bruges,
%       Belgium
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
% Created: 02 May 2019
% Created with Matlab version: 9.5.0.1067069 (R2018b) Update 4

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Input arguments
OPT.apiurl='https://api.meetnetvlaamsebanken.be';
OPT.username='user@company.org';
OPT.password='password';

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% Login to API
% Login to API, returns struct with token (valid for 3600 s.)
cred=webwrite([OPT.apiurl,'/Token/'],...
    'grant_type','password',...
    'username',OPT.username,...
    'password',OPT.password);

% Put token into weboptions object for further use.
token=weboptions('HeaderFields',{'Authorization',[cred.token_type,' ',cred.access_token]});

% Ping the API to test login success.
response=webread([OPT.apiurl,'/V2/ping/'],token);

if isempty(response.Customer);
    fprintf(2,'Login failed, try again \n');
elseif response.Customer.Login==OPT.username
    fprintf(1,'Login successful! \n');
end

if nargout==2
    varargout={token, cred};
else
    varargout={token};
end

end
%EOF