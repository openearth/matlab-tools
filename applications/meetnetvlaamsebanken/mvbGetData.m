function varargout = mvbGetData(varargin)
%MVBGETDATA Gets data from Meetnet Vlaamse Banken API
%
%   This script retreives timeseries from the API of Meetnet Vlaamse Banken
%   (Flemish Banks Monitoring Network API). Only one parameter can be
%   retreived per call. The data (including meta-data) is returned in a
%   struct.
%
%   A login token is required, which can be obtained with MVBLOGIN. A login
%   can be requested freely from https://meetnetvlaamsebanken.be/
%
%   The maximum time span per request is 365 days! This is independent from
%   the sampling rate.
%
%   Syntax:
%   Data = mvbGetData(<keyword>, <value>, token);
%
%   Input: For <keyword,value> pairs call mvbGetData() without arguments.
%   varargin  =
%       id: 'string'
%           MeasurementID string, choose one from the catalog list:
%           ctl.AvailableData.ID The catalog can be obtained via
%           mvbCatalog.
%       start: 'string'
%           Start time string in format: 'yyyy-mm-dd HH:MM:SS' (the time
%           part is optional).
%       end: 'string'
%           End time string, same format as start.
%       vector: [true|false]
%           Output as two column vectors [time, value] instead of full
%           struct.
%       token: <weboptions object>
%           Weboptions object containing the accesstoken. Generate this
%           token via mvbLogin. If no token is given or invalid, the user
%           is prompted for credentials.
%
%   Output:
%   varargout = 
%       Data: struct containing data and meta data.
%       OR
%       [t,v]: column vectors containing time in datenum and value.
%       For units see the catalog via mvbCatalog.
%
%   Example:
%   D = mvbGetData('id','BVHGH1','token',token);
%   [t,v]=mvbGetData('id','BVHGH1','start','2017-01-01','end','2017-03-05','vector',true,'token',token);
%
%   See also: MVBLOGIN, MVBCATALOG.

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
OPT.apiurl='https://api.meetnetvlaamsebanken.be'; %Base URL
OPT.token=weboptions;
OPT.id='AKZGH1'; %Akkaert South Buouy, Wave Height
OPT.start='2019-01-01 00:00:00'; % Start time
OPT.end=datestr(now,'yyyy-mm-dd'); % End time
OPT.vector=false; % Output switch

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
elseif odd(nargin);
    OPT.token = varargin{end};
    varargin = varargin(1:end-1);
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
% Check if login is still valid!
response=webread([OPT.apiurl,'/V2/ping/'],OPT.token);
if isempty(response.Customer) %If login has expired.
    fprintf(1,['Your login token is invalid, please login using mvbLogin \n'...
        'Use the obtained token from mvbLogin in this function. \n']);
    varargout=cell(nargout);
    return
end

% Check timespan.
% Maximum time span request = 365 days!!!
try; tstart=datenum(OPT.start); catch; tstart=datenum(OPT.start,'yyyy-mm-dd HH:MM:SS'); end;
try; tend=datenum(OPT.end);     catch; tend=  datenum(OPT.start,'yyyy-mm-dd HH:MM:SS'); end;
if tend-tstart>365 %Time span maximum 365 days.
    OPT.end=datestr(tstart+365,'yyyy-mm-dd');
    fprintf(1,'Maximum request length is 365 days!\n Data only retreived from %s to %s for ID %s!\n',...
        OPT.start,OPT.end,OPT.id);
elseif tend < tstart
    error('OPT.start must be before OPT.end!');
else
    fprintf(1,'Data retreived for ID: %s from %s to %s\n',OPT.id,OPT.start,OPT.end);
end

%% GET data
data=webwrite([OPT.apiurl,'/V2/getData'],'StartTime',OPT.start,'EndTime',OPT.end,'IDs',OPT.id,OPT.token);
if isempty(data.Values) % When ID is not found, data.Values will be empty
    warning('Warning: empty result, ID %s not found! \n',OPT.id);
elseif isempty(data.Values.Values); %When ID is found, but no data is available in the time interval, the values are empty.
    warning('Warning: ID %s was found, but there is no data in the time interval.\n',OPT.id);
end

%% Postprocess output
% In case of OPT.vector==true, only output column vectors with time and
% measurement value. This also automatically happens when two output
% arguments are requested.
if nargout==2 || OPT.vector %Output only time and value vectors!
    if isempty(data.Values) || isempty(data.Values.Values);
        %In case of no data.
        t=[];
        v=[];
    else
        %When there is data.
        t=datenum({data.Values.Values.Timestamp}','yyyy-mm-ddTHH:MM:SS');
        v=[data.Values.Values.Value]';
    end
    varargout={t,v};
else
    varargout={data};
end

end
%EOF