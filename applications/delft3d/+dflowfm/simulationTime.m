function [TStartOut,TStopOut] = simulationTime(TStart,TStop,Tunit,RefDate,mode)
%DFLOWFM  One line description goes here.
%
%   Calculate TStart and TStop values w.r.t RefDate (all input in datenum)
%
%   Syntax:
%   varargout = dflowfm(varargin)
%
%   Input: 
%   TStart      datenum value or Tunit
%   TStop       datenum value or Tunit
%   Tunit       'S' (seconds), 'M' (minutes), or 'H' (hours)
%   RefDate     datenum value
%
%   Optional
%   mode        'datenum' (datenum to Tunit) or 'Tunit' (Tunit to datenum)
                
%
%   Output:
%   TStart and TStop in Tunit w.r.t. RefDate
%
%   Example
%   dflowfm
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2023 <COMPANY>
%       schrijve
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 22 Jun 2023
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Calculate

% Conversion factor
if strcmpi(Tunit,'S')
    Tfac = 24*60*60;
elseif strcmpi(Tunit,'M')
    Tfac = 24*60;
elseif strcmpi(Tunit,'H')
    Tfac = 24;
end

if strcmpi(mode,'datenum')
    TStartOut = (TStart-RefDate)*Tfac;
    TStopOut = (TStop-RefDate)*Tfac;
elseif strcmpi(mode,'Tunit')
    TStartOut = RefDate+(TStart/Tfac);
    TStopOut = RefDate+(TStop/Tfac);
end

%% Display

if strcmpi(mode,'datenum')
    fprintf('\tRefDate = %s\n',datestr(RefDate,'yyyy-mm-dd HH:MM:SS'));
    fprintf('\tTStart = %.2f\n',TStartOut);
    fprintf('\tTStop = %.2f\n',TStopOut);
elseif strcmpi(mode,'Tunit')
    fprintf('\tRefDate = %s\n',datestr(RefDate,'yyyy-mm-dd HH:MM:SS'));
    fprintf('\tTStart = %s\n',datestr(TStartOut));
    fprintf('\tTStop = %s\n',datestr(TStopOut));
end

return


