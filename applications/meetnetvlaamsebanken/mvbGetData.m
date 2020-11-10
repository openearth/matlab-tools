function [varargout] = mvbGetData(varargin)
%MVBGETDATA Gets timeseries from Meetnet Vlaamse Banken API.
%
%   mvbGetData retreives timeseries from the API of Meetnet Vlaamse Banken
%   (Flemish Banks Monitoring Network API). Only one parameter can be
%   retreived per call. The data is returned as two vectors: time and value. 
%   Optionally data (including meta-data) is returned in a struct.
%   Meetnet Vlaamse Banken (Flemish Banks Monitoring Network API) only
%   accepts requests for timeseries <=365 days. This script runs several
%   subsequent GET requests to obtain a longer time series.
%
%   A login token is required, which can be obtained with MVBLOGIN. A login
%   can be requested freely from https://meetnetvlaamsebanken.be/
%
%   Syntax:
%   [time, value] = mvbGetLongData(<keyword>, <value>, token);
%
%   Input: For <keyword,value> pairs call mvbGetLongData() without arguments.
%   varargin =
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
%       [t,v]: column vectors containing time in datenum and value.
%       For units see the catalog via mvbCatalog.
%
%   Example
%   [t,v]=mvbGetData('id','BVHGH1','start','2010-01-01','end','2017-03-05','vector',true,'token',token);
%
%   See also: MVBLOGIN, MVBCATALOG, MVBTABLE.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be
%       l.w.m.roest@tudelft.nl
%
%       KU Leuven campus Bruges,
%       Spoorwegstraat 12
%       8200 Bruges
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
% Created: 03 May 2019
% Created with Matlab version: 9.5.0.1067069 (R2018b) Update 4

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.apiurl='https://api.meetnetvlaamsebanken.be/V2/'; %Base URL
OPT.token=weboptions;
OPT.id='AKZGH1'; %Akkaert South Buouy, Wave Height
OPT.start='2018-01-01 00:00:00'; % Start time
OPT.end=datestr(now,'yyyy-mm-dd'); % End time
OPT.vector=true; % Output switch

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
elseif odd(nargin);
    OPT.token = varargin{end}; %Assume token is the last input argument.
    varargin = varargin(1:end-1);
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
% Check if login is still valid!
response=webread([OPT.apiurl,'ping'],OPT.token);
if isempty(response.Customer) %If login has expired.
    fprintf(1,['Your login token is invalid, please login using mvbLogin \n'...
        'Use the obtained token from mvbLogin in this function. \n']);
    varargout=cell(nargout);
    return
end

%% Input check
%Only for vectorised output!!
fprintf(1,'Request %s data from %s to %s\n',OPT.id,OPT.start,OPT.end);

%Verify datestrings
try 
    tstart=datenum(OPT.start); 
catch 
    tstart=datenum(OPT.start,'yyyy-mm-dd HH:MM:SS'); 
end
try
    tend=datenum(OPT.end);   
catch
    tend=datenum(OPT.end,'yyyy-mm-dd HH:MM:SS');
end

if tend < tstart
    error('OPT.start must be before OPT.end!');
else

end

%Vector of start timestamps
t_start=datenum(OPT.start):365:datenum(OPT.end);

for t=1:length(t_start);
    if (t_start(t)+365) <= datenum(OPT.end);
        t_end=t_start(t)+365;
    else%if (t_start+365) > datenum(OPT.end);
        t_end=datenum(OPT.end);
    end
    %data=getData(OPT,t_start,t_end);
    fprintf(1,'Retreiving data for ID: %s from %s to %s\n',OPT.id,datestr(t_start(t)),datestr(t_end));
    tempdata(t)=webwrite([OPT.apiurl,'getData'],...
        'StartTime',datestr(t_start(t),'yyyy-mm-dd HH:MM:SS'),...
        'EndTime',  datestr(t_end     ,'yyyy-mm-dd HH:MM:SS'),...
        'IDs',OPT.id,OPT.token);
    
    if isempty(tempdata(t).Values) % When ID is not found, data.Values will be empty
        warning('Warning: empty result, ID %s not found! \n',OPT.id);
    elseif isempty(tempdata(t).Values.Values); %When ID is found, but no data is available in the time interval, the values are empty.
        fprintf(1,'ID %s was found, but there is no data in the time interval.\n',OPT.id);
    end
    
end

%% Postprocess output
% In case of OPT.vector==true, only output column vectors with time and
% measurement value. This also automatically happens when two output
% arguments are requested.
t=[];
v=[];
if nargout==2 || OPT.vector %Output only time and value vectors!
    for n=1:length(tempdata);
        if isempty(tempdata(n).Values) || isempty(tempdata(n).Values.Values);
            %In case of no data.
            %Do nothing...
        else
            %When there is data.
            t=[t;datenum({tempdata(n).Values.Values.Timestamp}','yyyy-mm-ddTHH:MM:SS')];
            v=[v;[tempdata(n).Values.Values.Value]'];
        end
    end
    varargout={t,v};
else
    % Combine data into single struct
    data.StartTime=datestr(min(datenum([tempdata.StartTime],'yyyy-mm-ddTHH:MM:SS')),'yyyy-mm-ddTHH:MM:SS+00:00');
    data.EndTime=datestr(max(datenum([tempdata.EndTime],'yyyy-mm-ddTHH:MM:SS')),'yyyy-mm-ddTHH:MM:SS+00:00');
    data.Intervals=nanmean([tempdata.Intervals]);

    data.Values.ID=tempdata(end).Values.ID;
    data.Values.StartTime=data.StartTime;
    data.Values.EndTime=data.EndTime;
    temp=[tempdata.Values];
    data.Values.Minvalue=min([temp.MinValue]);
    data.Values.Maxvalue=max([temp.MaxValue]);
    data.Values.Values=struct('Timestamp',[],'Value',[]);
    for k=1:length(tempdata);
        if ~isempty(tempdata(k).Values) && ~isempty(tempdata(k).Values.Values);
            nov=length(tempdata(k).Values.Values);
            data.Values.Values(end+1:end+nov,1)=tempdata(k).Values.Values;
        end
    end
    data.Values.Values=data.Values.Values(2:end);
    varargout={data};
end
end

% function data=getData(OPT,t_start,t_end);
%     data=webwrite([OPT.apiurl,'getData'],'StartTime',t_start,'EndTime',t_end,'IDs',OPT.id,OPT.token);
% 
% end
%EOF