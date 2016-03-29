function writeSCOts(SCOfilename,varargin)
%write SCO : Writes an SCO file
%
%   Syntax:
%     function writeSCOts(SCOfilename,waterlevel,waveheight,waveperiod,direction,duration,X,Y,numOfDays)
% 
%   Input:
%     SCOfilename   string
%     SCOdata       Structure with SCO information
%                     .isWavecurrent   (optional) wave current interaction switch 0 to 8 (=0 by default)
%                     .isDynamicBND    (optional) Switch for dynamic boundary (=0 by default, 1=on)
%                     .prctDynamicBND  (optional) Location of dynamic boundary defined as the landward percentage of QS (80 = capturing 80% of the transport)
%                     .isWind          (optional) switch for wind conditions (=0 by default, 1=on)
%                     .isTideoffset    (optional) switch for computing tide offset of S-Phi curve (=0 by default, 1=on)
%                     .isTimeseries    (optional) Switch for time-series (=0 by default, 1=on)
%                     .time            (optional) time point of each wave condition [hours] (specify for time-series only!)
%                     .h0              Surge height per wave condition [m]
%                     .hs              Significant wave height [m]
%                     .tp              Peak wave period [s]
%                     .xdir            Wave direction [Nautical degrees]
%                     .Htide           Water level elevation for each tidal condition [m]
%                     .Vtide           Alongshore veolcity for each tidal condition [m/s]
%                     .RefDep          Reference depth of tide for each tidal condition [m]
%                     .Ptide           Occurrence of each tidal condition [% of time] (i.e. 0 to 100)
%                     .WS              (optional) Wind speed in m/s at 10 m (Only used if .isWind==1)
%                     .Wdir            (optional) Wind direction in Nautical degrees (Only used if .isWind==1)
%                     .Wdrag           (optional) Wind drag coefficient (Only used if .isWind==1)
%
%   Input (alternative):
%     SCOfilename   string
%     waterlevel    [1xN] matrix
%     waveheight    [1xN] matrix
%     waveperiod    [1xN] matrix
%     direction     [1xN] matrix
%     duration      [1xN] matrix
%     X             number
%     Y             number
%     numOfDays     number
%
%   Output:
%     .sco files
% 
%   Example:
%     writeSCO('test.sco',[0;0],[1.2;2.3],[6;9],[284;312],[10;1],576230,3457282,365)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
if nargin>2
    SCOdata    = struct;
    SCOdata.h0         = varargin{1}; %waterlevel;
    SCOdata.hs         = varargin{2}; %waveheight;
    SCOdata.tp         = varargin{3}; %waveperiod;
    SCOdata.xdir       = varargin{4}; %direction;
    SCOdata.dur        = varargin{5}; %duration;
    SCOdata.x          = varargin{6}; %X;
    SCOdata.y          = varargin{7}; %Y;
    SCOdata.numOfDays  = varargin{8}; %numOfDays;
else
    SCOdata = varargin{1};
end

%% INITIALISE NON-SPECIFIED FIELDS
settingFLDS = {'isTimeseries','isWavecurrent','isDynamicBND','isWind','isTideoffset'};
for kk=1:length(settingFLDS)
if ~isfield(SCOdata,settingFLDS{kk})
    SCOdata.(settingFLDS{kk})=0;
end
end
if ~isfield(SCOdata,'prctDynamicBND')
    SCOdata.prctDynamicBND=100;
end

%% WRITE REGULAR SCO FILE (CLIMATE CONDITIONS)
fid = fopen(SCOfilename,'wt');
if SCOdata.isTimeseries~=1
    fprintf(fid,'%5.2f',SCOdata.numOfDays);
    fprintf(fid,'             (Number of days)\n');
    fprintf(fid,'%3.0f',length(SCOdata.hs));
    fprintf(fid,'             (Number of waves   Location: X= ');
    fprintf(fid,'%11.2f',SCOdata.x);
    fprintf(fid,' Y= ');
    fprintf(fid,'%11.2f',SCOdata.y);
    fprintf(fid,'  )\n');
    fprintf(fid,'WAVM      H0            wave height   period   direction   Duration\n');
    fprintf(fid,'   %14.3f%14.3f%14.3f%14.3f%14.5f\n',[SCOdata.h0(:),SCOdata.hs(:),SCOdata.tp(:),SCOdata.xdir(:),SCOdata.dur(:)]');
    writedummyTIDE=0;
    if writedummyTIDE==1
        fprintf(fid,'  1    (Number of Tide condition\n');
        fprintf(fid,'          DH            Vgety         Ref.depth   Perc\n');
        fprintf(fid,'             0.00          0.00          3.00        100.00\n');
    elseif writedummyTIDE~=0
        fprintf(fid,' %2.0f    (Number of Tide condition\n',length(SCOdata.Htide));
        fprintf(fid,'     %9s %9s %9s %9s\n','DH','Vgety','Ref.depth','Perc');
        fprintf(fid,'     %9.3f %9.3f %9.3f %9.5f\n',[SCOdata.Htide(:), SCOdata.Vtide(:), SCOdata.RefDep(:), SCOdata.Ptide(:)]');
    end
    fclose(fid);
   
%% WRITE TIME-SERIES SCO FILE
elseif SCOdata.isTimeseries==1
    fprintf(fid,'%4.0f     (Time Instances per Year) (minutes=525600, hours=8760, days=365)\n',8760);
    fprintf(fid,'%4.0f     (Number of Wave Conditions)\n',length(SCOdata.time));
    fprintf(fid,'%2.0f       (Model for wave-current interaction 0..8)\n',SCOdata.isWavecurrent);
    fprintf(fid,'%2.0f      %3.0f      (Use Dynamic boundary (on=1/off=0))\n',SCOdata.isDynamicBND,SCOdata.prctDynamicBND);
    fprintf(fid,'%2.0f       (Use Wind Driven Currents (on=1/off=0))\n',SCOdata.isWind);
    fprintf(fid,'%2.0f       (Use Tide offset for schematisation (on=1/off=0))\n',SCOdata.isTideoffset);
    fprintf(fid,'%2.0f       (Use timeseries)\n',SCOdata.isTimeseries);

    if SCOdata.isWind~=1
        fprintf(fid,'      Time         H0       Hsig       Tper       Alf        Tide       Vtide     RefDep\n');
        fprintf(fid,'%10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f\n',...
        [SCOdata.time(:), SCOdata.h0(:), SCOdata.hs(:), SCOdata.tp(:), SCOdata.xdir(:), SCOdata.Htide(:), SCOdata.Vtide(:), SCOdata.RefDep(:)]');
    else
        SCOdata.WS
        SCOdata.Wdir
        SCOdata.Wdrag
    end
    fclose(fid);
end

