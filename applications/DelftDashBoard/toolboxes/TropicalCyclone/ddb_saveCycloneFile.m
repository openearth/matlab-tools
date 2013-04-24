function ddb_saveCycloneFile(filename,storm,varargin)
%DDB_SAVECYCLONEFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveCycloneFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%
%
%
%   Example
%   ddb_saveCycloneFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% DDB - Saves cyclone track to cyc file

vstr='';
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'version'}
                vstr=[' - DelftDashBoard v' varargin{ii+1}];
        end
    end
end

fid = fopen(filename,'w');

% time=clock;
datestring=datestr(datenum(clock),31);

usrstring='- Unknown user';
usr=getenv('username');

if size(usr,1)>0
    usrstring=[' - File created by ' usr];
end

txt=['# Tropical Cyclone Toolbox' vstr ' - ' datestring];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

txt=['Name              "' storm.name '"'];
fprintf(fid,'%s \n',txt);

txt=['Method            ' num2str(storm.method)];
fprintf(fid,'%s \n',txt);

txt=['InitialEyeSpeed   ' num2str(storm.initSpeed)];
fprintf(fid,'%s \n',txt);

txt=['InitialEyeDir     ' num2str(storm.initDir)];
fprintf(fid,'%s \n',txt);

txt=['SpiderwebRadius   ' num2str(storm.radius)];
fprintf(fid,'%s \n',txt);

txt=['NrRadialBins      ' num2str(storm.nrRadialBins)];
fprintf(fid,'%s \n',txt);

txt=['NrDirectionalBins ' num2str(storm.nrDirectionalBins)];
fprintf(fid,'%s \n',txt);

if strcmpi(storm.quadrantOption,'uniform')
    txt='InputPerQuadrant  0';
else
    txt='InputPerQuadrant  1';
end
fprintf(fid,'%s \n',txt);

fprintf(fid,'%s\n','');

%     storm.trackVMax(isnan(storm.trackVMax))=-999;
%     storm.trackRMax(isnan(storm.trackRMax))=-999;
%     storm.trackPDrop(isnan(storm.trackPDrop))=-999;
%     storm.trackA(isnan(storm.trackA))=-999;
%     storm.trackB(isnan(storm.trackB))=-999;
%     storm.trackR100(isnan(storm.trackR100))=-999;
%     storm.trackR65(isnan(storm.trackR65))=-999;
%     storm.trackR50(isnan(storm.trackR50))=-999;
%     storm.trackR35(isnan(storm.trackR35))=-999;

if strcmpi(storm.quadrantOption,'uniform')
    
    % Comment
    switch storm.method
        case 1
            txt1='#             Date   Time      Lat      Lon     Vmax     ParB     ParA';
        case 2
            txt1='#             Date   Time      Lat      Lon     Vmax      R35      R50      R65     R100';
        case 3
            txt1='#             Date   Time      Lat      Lon     Vmax     Rmax    Pdrop';
        case 4
            txt1='#             Date   Time      Lat      Lon     Vmax    Pdrop';
        case 5
            txt1='#             Date   Time      Lat      Lon     Vmax     Rmax';
        case 6
            txt1='#             Date   Time      Lat      Lon     Vmax';
    end
    fprintf(fid,'%s\n',txt1);
    
    for i=1:storm.nrTrackPoints
        txt=['TrackData ' datestr(storm.trackT(i),'yyyymmdd HHMMSS')];
        switch storm.method
            case 1
                fmt='%s %8.3f %8.3f %8.1f %8.3f %8.3f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i),storm.trackVMax(i),storm.trackB(i),storm.trackA(i));
            case 2
                fmt='%s %8.3f %8.3f %8.1f %8.1f %8.1f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i),storm.trackVMax(i),storm.trackR35(i,1),storm.trackR50(i,1),storm.trackR65(i,1),storm.trackR100(i,1));
            case 3
                fmt='%s %8.3f %8.3f %8.1f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i),storm.trackVMax(i,1),storm.trackRMax(i,1),storm.trackPDrop(i,1));
            case 4
                fmt='%s %8.3f %8.3f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i),storm.trackVMax(i,1),storm.trackPDrop(i,1));
            case 5
                fmt='%s %8.3f %8.3f %8.1f %8.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i),storm.trackVMax(i,1),storm.trackRMax(i,1));
            case 6
                fmt='%s %8.3f %8.3f %8.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i),storm.trackVMax(i,1));
        end
    end
    
else
    
    % Comment
    switch storm.method
        case 1
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) ParB (NE) ParB (NW) ParB (SW) ParB (SE) ParA (NE) ParA (NW) ParA (SW) ParA (SE)';
        case 2
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW)  R35 (NE)  R35 (NW)  R35 (SW)  R35 (SE)  R50 (NE)  R50 (NW)  R50 (SW)  R50 (SE)  R65 (NE)  R65 (NW)  R65 (SW)  R65 (SE) R100 (NE) R100 (NW) R100 (SW) R100 (SE)';
        case 3
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) Rmax (NE) Rmax (NW) Rmax (SW) Rmax (SE) Pdrop(NE) Pdrop(NW) Pdrop(SW) Pdrop(SE)';
        case 4
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) Pdrop(NE) Pdrop(NW) Pdrop(SW) Pdrop(SE)';
        case 5
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW) Rmax (NE) Rmax (NW) Rmax (SW) Rmax (SE)';
        case 6
            txt1='#             Date   Time      Lat      Lon Vmax (NE) Vmax (NW) Vmax (SW) Vmax (SW)';
    end
    fprintf(fid,'%s\n',txt1);
    
    for i=1:storm.nrTrackPoints
        txt=['TrackData ' datestr(storm.trackT(i),'yyyymmdd HHMMSS')];
        switch storm.method
            case 1
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i), ...
                    storm.trackVMax(i,1),storm.trackVMax(i,2),storm.trackVMax(i,3),storm.trackVMax(i,4), ...
                    storm.trackB(i,1),storm.trackB(i,2),storm.trackB(i,3),storm.trackB(i,4),storm.trackA(i,1),storm.trackA(i,2),storm.trackA(i,3),storm.trackA(i,4));
            case 2
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i), ...
                    storm.trackVMax(i,1),storm.trackVMax(i,2),storm.trackVMax(i,3),storm.trackVMax(i,4), ...
                    storm.trackR35(i,1),storm.trackR35(i,2),storm.trackR35(i,3),storm.trackR35(i,4), ...
                    storm.trackR50(i,1),storm.trackR50(i,2),storm.trackR50(i,3),storm.trackR50(i,4), ...
                    storm.trackR65(i,1),storm.trackR65(i,2),storm.trackR65(i,3),storm.trackR65(i,4), ...
                    storm.trackR100(i,1),storm.trackR100(i,2),storm.trackR100(i,3),storm.trackR100(i,4));
            case 3
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i), ...
                    storm.trackVMax(i,1),storm.trackVMax(i,2),storm.trackVMax(i,3),storm.trackVMax(i,4), ...
                    storm.trackRMax(i,1),storm.trackRMax(i,2),storm.trackRMax(i,3),storm.trackRMax(i,4), ...
                    storm.trackPDrop(i,1),storm.trackPDrop(i,2),storm.trackPDrop(i,3),storm.trackPDrop(i,4));
            case 4
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i), ...
                    storm.trackVMax(i,1),storm.trackVMax(i,2),storm.trackVMax(i,3),storm.trackVMax(i,4), ...
                    storm.trackPDrop(i,1),storm.trackPDrop(i,2),storm.trackPDrop(i,3),storm.trackPDrop(i,4));
            case 5
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i), ...
                    storm.trackVMax(i,1),storm.trackVMax(i,2),storm.trackVMax(i,3),storm.trackVMax(i,4), ...
                    storm.trackRMax(i,1),storm.trackRMax(i,2),storm.trackRMax(i,3),storm.trackRMax(i,4));
            case 6
                fmt='%s %8.3f %8.3f %9.1f %9.1f %9.1f %9.1f\n';
                fprintf(fid,fmt,txt,storm.trackY(i),storm.trackX(i),storm.trackVMax(i,1),storm.trackVMax(i,2),storm.trackVMax(i,3),storm.trackVMax(i,4));
        end
    end
    
end

fclose(fid);

