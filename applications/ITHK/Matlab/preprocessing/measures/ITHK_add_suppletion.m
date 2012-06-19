function ITHK_add_suppletion(index,phase,sens)
%function ITHK_add_suppletion(index,phase,sens)
%
% Adds nourishments to the SOS file
%
% INPUT:
%      index  number of nourishment ID
%      phase  phase number (of CL-model)
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .settings.outputdir
%              .userinput.suppletion(ss).lat
%              .userinput.suppletion(ss).lon
%              .userinput.suppletion(ss).volume
%              .userinput.suppletion(ss).width
%              .userinput.phase(phase).SOSfile
%              .userinput.phase(phase).supids
%              .userinput.phase(phase).supcat
%              .userinput.suppletion(ss).category
%      MDAfile  'BASIC.MDA'
%      SOSfile  'hotspots1locIT.SOS' file with already defined nourishments
%
% OUTPUT:
%      SOSfile  'hotspots1locIT_cont.SOS' file with already defined and new nourishments
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB.input(sens).suppletion(ss).SOSdata
%              .userinput.suppletion(ss).idRANGE
%              .userinput.suppletion(ss).idNEAREST
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
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
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% code

global S

%% Get info from struct
ss = S.userinput.phase(phase).supids(index);
lat = S.userinput.suppletion(ss).lat;
lon = S.userinput.suppletion(ss).lon;

%% convert coordinates
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_io_readMDA('BASIS.MDA');
[SOSdata0]=ITHK_io_readSOS([S.settings.outputdir S.userinput.phase(phase).SOSfile]);
if strcmp(S.userinput.phase(phase).supcat{index},'cont') || strcmp(S.userinput.phase(phase).supcat{index},'distr')
    if exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')
        SOSdata_cont=ITHK_io_readSOS([S.settings.outputdir '1HOTSPOTSIT_cont.sos']);
    else
        SOSdata_cont=ITHK_io_readSOS([S.settings.outputdir 'BASIS.sos']);
        ITHK_writeSOS([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],SOSdata_cont);
    end
end

%% calculate suppletion information
suppletion          = struct;
suppletion.name     = 'hotspots1locIT';
suppletion.x        = x;
suppletion.y        = y;
suppletion.volume   = S.userinput.suppletion(ss).volume;
suppletion.width    = 0.5*S.userinput.suppletion(ss).width;

%% write a SOS file (sources and sinks)
SOSfilename = [S.settings.outputdir S.userinput.phase(phase).SOSfile];
ITHK_io_writeSOS(SOSfilename,SOSdata0);
%suppletion.volume = volumes;
%suppletion.width  = 0.5*width;%must be radius
if strcmp(S.userinput.suppletion(ss).category,'distr')
    [SOSdata2,idNEAREST,idRANGE] = ITHK_addUNIFORMLYDISTRIBUTEDnourishment(MDAdata,suppletion,SOSfilename);
else
    [SOSdata2,idNEAREST,idRANGE] = ITHK_addTRIANGULARnourishment(MDAdata,suppletion,SOSfilename);
end

S.UB.input(sens).suppletion(ss).SOSdata = suppletion;
S.userinput.suppletion(ss).idRANGE = idRANGE;
S.userinput.suppletion(ss).idNEAREST = idNEAREST;

% Update cont suppletion file
if strcmp(S.userinput.phase(phase).supcat{index},'cont') 
    [SOSdata_cont2,idNEAREST,idRANGE] = ITHK_addTRIANGULARnourishment(MDAdata,suppletion,[S.settings.outputdir '1HOTSPOTSIT_cont.sos']);
elseif strcmp(S.userinput.phase(phase).supcat{index},'distr')
    [SOSdata_cont2,idNEAREST,idRANGE] = ITHK_addUNIFORMLYDISTRIBUTEDnourishment(MDAdata,suppletion,[S.settings.outputdir '1HOTSPOTSIT_cont.sos']);
end

%if strcmp(S.userinput.phase(phase).supcat{index},'cont') || strcmp(S.userinput.phase(phase).supcat{index},'distr')
%    ITHK_io_writeSOS([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],SOSdata2);
%end