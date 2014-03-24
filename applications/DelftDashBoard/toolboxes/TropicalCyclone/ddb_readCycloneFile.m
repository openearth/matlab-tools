function handles = ddb_readCycloneFile(handles, filename)
%DDB_READCYCLONEFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readCycloneFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_readCycloneFile
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

%% DDB - reads cyclone file

inp=handles.toolbox.tropicalcyclone;

txt=ReadTextFile(filename);
npoi = 0;

inp.name='';
inp.initSpeed=0;
inp.initDir=0;

inp.trackT = floor(now);
inp.trackY = 0;
inp.trackX = 0;
inp.trackB=0;
inp.trackA=0;
inp.trackR35=0;
inp.trackR50=0;
inp.trackR65=0;
inp.trackR100=0;
inp.trackVMax=0;
inp.trackRMax=0;
inp.trackPDrop=0;

inp.radius = 1000;

try
    
    for i=1:length(txt)
        switch(lower(txt{i})),
            case{'name'}
                inp.name=txt{i+1};
            case{'method'}
                inp.method=str2double(txt{i+1});
            case{'initialeyespeed'}
                inp.initSpeed=str2double(txt{i+1});
            case{'initialeyedir'}
                inp.initDir=str2double(txt{i+1});
            case{'spiderwebradius'}
                inp.radius=str2double(txt{i+1});
            case{'nrradialbins'}
                inp.nrRadialBins=str2double(txt{i+1});
            case{'nrdirectionalbins'}
                inp.nrDirectionalBins=str2double(txt{i+1});
            case{'inputperquadrant'}
                if str2double(txt{i+1})==1
                    inp.quadrantOption='perquadrant';
                else
                    inp.quadrantOption='uniform';
                end
                
            case{'trackdata'}
                npoi=npoi+1;
                dat=txt{i+1};
                tim=txt{i+2};
                inp.trackT(npoi) = datenum([dat tim],'yyyymmddHHMMSS');
                inp.trackY(npoi) = str2double(txt{i+3});
                inp.trackX(npoi) = str2double(txt{i+4});
                
                inp.trackB(npoi,1:4)=0;
                inp.trackA(npoi,1:4)=0;
                inp.trackR35(npoi,1:4)=0;
                inp.trackR50(npoi,1:4)=0;
                inp.trackR65(npoi,1:4)=0;
                inp.trackR100(npoi,1:4)=0;
                inp.trackVMax(npoi,1:4)=0;
                inp.trackRMax(npoi,1:4)=0;
                inp.trackPDrop(npoi,1:4)=0;
                
                if strcmpi(inp.quadrantOption,'uniform')
                    
                    switch inp.method
                        case 1
                            inp.trackVMax(npoi,1:4)=str2double(txt{i+5});
                            inp.trackB(npoi,1:4)=str2double(txt{i+6});
                            inp.trackA(npoi,1:4)=str2double(txt{i+7});
                        case 2
                            inp.trackVMax(npoi,1:4)=str2double(txt{i+5});
                            inp.trackR35(npoi,1:4)=str2double(txt{i+6});
                            inp.trackR50(npoi,1:4)=str2double(txt{i+7});
                            inp.trackR65(npoi,1:4)=str2double(txt{i+8});
                            inp.trackR100(npoi,1:4)=str2double(txt{i+9});
                        case 3
                            inp.trackVMax(npoi,1:4)=str2double(txt{i+5});
                            inp.trackRMax(npoi,1:4)=str2double(txt{i+6});
                            inp.trackPDrop(npoi,1:4)=str2double(txt{i+7});
                        case 4
                            inp.trackVMax(npoi,1:4)=str2double(txt{i+5});
                            inp.trackPDrop(npoi,1:4)=str2double(txt{i+6});
                        case 5
                            inp.trackVMax(npoi,1:4)=str2double(txt{i+5});
                            inp.trackRMax(npoi,1:4)=str2double(txt{i+6});
                        case 6
                            inp.trackVMax(npoi,1:4)=str2double(txt{i+5});
                    end
                    
                else
                    
                    switch inp.method
                        case 1
                            inp.trackVMax(npoi,1)=str2double(txt{i+5});
                            inp.trackVMax(npoi,2)=str2double(txt{i+6});
                            inp.trackVMax(npoi,3)=str2double(txt{i+7});
                            inp.trackVMax(npoi,4)=str2double(txt{i+8});
                            inp.trackB(npoi,1)=str2double(txt{i+9});
                            inp.trackB(npoi,2)=str2double(txt{i+10});
                            inp.trackB(npoi,3)=str2double(txt{i+11});
                            inp.trackB(npoi,4)=str2double(txt{i+12});
                            inp.trackA(npoi,1)=str2double(txt{i+13});
                            inp.trackA(npoi,2)=str2double(txt{i+14});
                            inp.trackA(npoi,3)=str2double(txt{i+15});
                            inp.trackA(npoi,4)=str2double(txt{i+16});
                        case 2
                            inp.trackVMax(npoi,1)=str2double(txt{i+5});
                            inp.trackVMax(npoi,2)=str2double(txt{i+6});
                            inp.trackVMax(npoi,3)=str2double(txt{i+7});
                            inp.trackVMax(npoi,4)=str2double(txt{i+8});
                            inp.trackR35(npoi,1)=str2double(txt{i+9});
                            inp.trackR35(npoi,2)=str2double(txt{i+10});
                            inp.trackR35(npoi,3)=str2double(txt{i+11});
                            inp.trackR35(npoi,4)=str2double(txt{i+12});
                            inp.trackR50(npoi,1)=str2double(txt{i+13});
                            inp.trackR50(npoi,2)=str2double(txt{i+14});
                            inp.trackR50(npoi,3)=str2double(txt{i+15});
                            inp.trackR50(npoi,4)=str2double(txt{i+16});
                            inp.trackR65(npoi,1)=str2double(txt{i+17});
                            inp.trackR65(npoi,2)=str2double(txt{i+18});
                            inp.trackR65(npoi,3)=str2double(txt{i+19});
                            inp.trackR65(npoi,4)=str2double(txt{i+20});
                            inp.trackR100(npoi,1)=str2double(txt{i+21});
                            inp.trackR100(npoi,2)=str2double(txt{i+22});
                            inp.trackR100(npoi,3)=str2double(txt{i+23});
                            inp.trackR100(npoi,4)=str2double(txt{i+24});
                        case 3
                            inp.trackVMax(npoi,1)=str2double(txt{i+5});
                            inp.trackVMax(npoi,2)=str2double(txt{i+6});
                            inp.trackVMax(npoi,3)=str2double(txt{i+7});
                            inp.trackVMax(npoi,4)=str2double(txt{i+8});
                            inp.trackRMax(npoi,1)=str2double(txt{i+9});
                            inp.trackRMax(npoi,2)=str2double(txt{i+10});
                            inp.trackRMax(npoi,3)=str2double(txt{i+11});
                            inp.trackRMax(npoi,4)=str2double(txt{i+12});
                            inp.trackPDrop(npoi,1)=str2double(txt{i+13});
                            inp.trackPDrop(npoi,2)=str2double(txt{i+14});
                            inp.trackPDrop(npoi,3)=str2double(txt{i+15});
                            inp.trackPDrop(npoi,4)=str2double(txt{i+16});
                        case 4
                            inp.trackVMax(npoi,1)=str2double(txt{i+5});
                            inp.trackVMax(npoi,2)=str2double(txt{i+6});
                            inp.trackVMax(npoi,3)=str2double(txt{i+7});
                            inp.trackVMax(npoi,4)=str2double(txt{i+8});
                            inp.trackPDrop(npoi,1)=str2double(txt{i+9});
                            inp.trackPDrop(npoi,2)=str2double(txt{i+10});
                            inp.trackPDrop(npoi,3)=str2double(txt{i+11});
                            inp.trackPDrop(npoi,4)=str2double(txt{i+12});
                        case 5
                            inp.trackVMax(npoi,1)=str2double(txt{i+5});
                            inp.trackVMax(npoi,2)=str2double(txt{i+6});
                            inp.trackVMax(npoi,3)=str2double(txt{i+7});
                            inp.trackVMax(npoi,4)=str2double(txt{i+8});
                            inp.trackRMax(npoi,1)=str2double(txt{i+9});
                            inp.trackRMax(npoi,2)=str2double(txt{i+10});
                            inp.trackRMax(npoi,3)=str2double(txt{i+11});
                            inp.trackRMax(npoi,4)=str2double(txt{i+12});
                        case 6
                            inp.trackVMax(npoi,1)=str2double(txt{i+5});
                            inp.trackVMax(npoi,2)=str2double(txt{i+6});
                            inp.trackVMax(npoi,3)=str2double(txt{i+7});
                            inp.trackVMax(npoi,4)=str2double(txt{i+8});
                    end
                    
                end
                
        end
    end
    
    %     inp.trackVMax(inp.trackVMax==-999)=NaN;
    %     inp.trackRMax(inp.trackRMax==-999)=NaN;
    %     inp.trackPDrop(inp.trackPDrop==-999)=NaN;
    %     inp.trackA(inp.trackA==-999)=NaN;
    %     inp.trackB(inp.trackB==-999)=NaN;
    %     inp.trackR100(inp.trackR100==-999)=NaN;
    %     inp.trackR65(inp.trackR65==-999)=NaN;
    %     inp.trackR50(inp.trackR50==-999)=NaN;
    %     inp.trackR35(inp.trackR35==-999)=NaN;
    
    inp.nrTrackPoints=npoi;
    
    handles.toolbox.tropicalcyclone=inp;
    
catch
    ddb_giveWarning('text','An error occured while loading cyclone file! Please check the input.')
end

