function outputKML = ITHK(measure,lat,lon,impl,len,vol,fill,tin,varNameIn,slr,coast,eco,dunes,costs,economy,safety,recreation,residency,web)

% function outputKML =  UnibestInteractiveTool(lat,lon,mag,time,name,measure,implementation)
%UNIBESTINTERACTIVETOOL  Backbone function of Unibest Interactive Tool for the Holland Coast
%
%   The Unibest Interactive Tool for the Holland Coast is developed in the Building with Nature program
%   by the working packages HK4.1 and DM1.3. This function is the backbone of the tool in which simulates 
%   the effects of a number of (pre-defined) coastal measures on the coastline development of the Holland
%   Coast by means of a UNIBEST model. The Unibest Interactive Tool can only run, when the user has a
%   license of the UNIBEST software. The tool can be called either direclty from Matlab or from a web
%   application.
%
%   Syntax:
%   outputKML = UnibestInteractiveTool(lat,lon,mag,time,name,measure,implementation)
%
%   Input:
%   measure       = code indicating the type of coastal intervention:
%                   [0] Continuous triangular nourishment (from year of implementation to end)
%                   [1] Single triangular nourishment (only in year of implementation) 
%                   [2] Groyne
%                   [3] Revetment
%				    [4] Evenly distributed nourishment (from year of implementation to end)
%   lat           = 1xN array with the latitudes of coastal interventions
%   lon           = 1xN array with the longitudes of coastal interventions
%   impl          = 1xN array with the years of implementation of coastal intervention (measured from base year)
%   len           = 1xN array with the (spreading) length of coastal interventions (0.5*len = radius around lat,lon)
%   vol           = 1xN array with the nourishment volumes
%   fill          = 1xN array with the fillup behind revetments (0=no fillup, 1=fillup)
%   tin           = string specifying the timespan for the Unibest calculations in years
%   varNameIn     = string specifying the name of the scenario
%   coast         = string specifying whether coastline output will be generated
%   eco           = string specifying whether ecology output will be generated
%   dunes         = string specifying whether dunes output will be generated
%   slr           = string specifying whether sea level rise will be taken into account
%
%   Output:
%   outputKML = contents of the KML-file (filename = varNameIn.kml) containing the model results of the Unibest calculations
%
%   Example
%   measure = [1, 2, 2, 3, 4, 3];
%   lat = [52.0295, 52.0716, 52.1167, 52.2049, 52.1078, 52.2444];
%   lon = [4.1588, 4.2209, 4.2824, 4.3912, 4.2693, 4.4269];
%   impl = [10, 15, 5, 1, 5, 15];
%   len = [2500, 500, 500, 2500, 1000, 2500];
%   vol = [10000000, 0, 0, 0, 1000000, 0];
%   fill = [0, 0, 0, 0, 0, 0];
%   tin = '20';
%   varNameIn = 'example';
%   coast = '1';
%   eco = '0';
%   dunes = '0';
%   slr = '1';
%   outputKML = UnibestInteractiveTool(measure,lat,lon,impl,len,vol,fill,tin,varNameIn,coast,eco,dunes,slr)

%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Wiebe de Boer
%
%       wiebe.deboer@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 22 Sep 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Unibest Interactive Tool
global S
disp('Matlab called by Interactive Tool')

%% Add relevant paths
basepath='.';

if ispc
    [a,b]=system(['dir /b /ad /s ' '"' basepath '"']); % "'s added to enable spaces in directory and filenames
else
    [a,b]=system(['find ' basepath ' -type d']);
end
b = [basepath char(10) b];

%% Exclude the .svn directories from the path
%  -------------------------------------------
s = strread(b, '%s', 'delimiter', char(10)); % read path as cell
% clear cells which contain [filesep '.svn']
s = s(cellfun('isempty', regexp(s, [filesep '.svn'])))'; % keep only paths not containing [filesep '.svn']

%% create string with remaining paths
%  -------------------------------------------
s = [s; repmat({pathsep}, size(s))];
newpath = [s{:}];
% add newpath to path
path(newpath, path);

%% Create structure
S = struct;
S.EPSG = load('EPSG.mat');

%Read settings
S.settings = xml_load('ITHK_settings.xml');%d:\2011\InteractiveTool_Kustatelier\Matlab\settings2.xml
baseDir = S.settings.basedir;

% directory
% workdir = pwd;
% if strcmp(workdir(end),'\')
%     baseDir = [fileparts(workdir(1:end-1)) '\'];
% else
%     baseDir = [fileparts(workdir) '\'];
% end

% subdirectories
%S.settings.basedir             = baseDir;
S.settings.inputdir            = [baseDir 'Matlab\preprocessing\input\'];
S.settings.outputdir           = [baseDir 'UB model\'];

% Process web input
%S.userinput = process_webinput(lat,lon,mag,time,name,measure,implementation);
S.userinput = ITHK_process_webinput(measure,lat,lon,impl,len,vol,fill,tin,varNameIn,slr,coast,eco,dunes,costs,economy,safety,recreation,residency,web);

%% Preprocessing Unibest Interactive Tool
for ii=1:1%length(sensitivities)
    ITHK_preprocessing(ii);
    disp('preprocessing Unibest Interactive Tool completed')

    %% Running Unibest Interactive Tool
    ITHK_runUB;
    disp('running Unibest completed');
    
    %% Create output dir
    if ~isdir([S.settings.outputdir 'output\' S.userinput.name])
       mkdir([S.settings.outputdir 'output\' S.userinput.name]);
    end 

    %% Extract UB (PRN) results for current & reference scenario
    PRNfileName = [S.userinput.name,'.PRN']; 
    S.UB(ii).results.PRNdata = ITHK_io_readPRN([S.settings.outputdir PRNfileName]);
    S.UB(ii).data_ref.PRNdata = ITHK_io_readPRN([S.settings.outputdir 'Natural_development.PRN']);%REFERENCE_IT.PRN

    %% Postprocessing Unibest Interactive Tool
    ITHK_postprocessing(ii);
    ITHK_cleanup(ii)
end
save([S.settings.outputdir filesep 'output' filesep S.userinput.name filesep S.userinput.name,'.mat'],'-struct','S')
outputKML=fileread(S.PP.output.kmlFileName);
disp('postprocessing Unibest Interactive Tool completed');
%}