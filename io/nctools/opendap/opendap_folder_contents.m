function contents = opendap_folder_contents(url)
%OPENDAP_FOLDER_CONTENTS   get links to all nc. files in a folder on OpenDap
%
%    contents = opendap_folder_contents(url)
%
% url is the full path to the folder. Returns a structure with all full
% links to nc files. Works for http://dtvirt5.deltares.nl:8080/ and
% http://opendap.deltares.nl url's
%
% Example 1:
%
% url = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen';
% contents = opendap_folder_contents(url);
%
% Example 2:
%
% url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids';
% contents = opendap_folder_contents(url);

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% 

%% check which serever:

switch url(1:26)
    case 'http://dtvirt5.deltares.nl'
        varopendap = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap';
        string = urlread([url '/catalog.html']);
        startPos = strfind(string, 'varopendap');
        endPos = strfind(string, '.nc">');
        for ii = 1 :length(endPos)
            contents{ii} = [varopendap string(startPos(ii+1)+11:endPos(ii)+2)];
        end
    case 'http://opendap.deltares.nl'
        varopendap =  'http://opendap.deltares.nl:8080/opendap';
        string = urlread([url '/contents.html']);
        startPos = strfind(string, '.nc.html">');
        endPos = strfind(string, '.nc</a>');
         for ii = 1 :length(endPos)
           contents{ii} = [url '/' string(startPos(ii*2-1)+10:endPos(ii)+2)];
         end
end

