function OpenDAPinfo = getOpenDAPinfo(varargin) %#ok<STOUT>
%GETOPENDAPINFO  Routine returns a struct of all datafiles available from an OpenDAP url.
%
%   The routine returns a structure containing all information about a user
%   specified OpenDAP url based on parsing the information contained in
%   catalog.xml. The url entered is expected to refer to a location that
%   includes catalog.xml information.  The routine should work starting at
%   any level. 
%   
%   The routine assumes the variables at the level of the specified OpenDAP
%   url to start with a letter. To prevent crashing in case a datasetname
%   or a datafile should start with a number the prefix 'temp_' is glued to
%   all deeper levels. This prefix may of course be removed later (e.g.
%   when reconstructing urls from the struct). 
%
%   To prevent the occurence of undesired sublevels in the info structure
%   all points in dataset names (e.g. waterbase.nl) have been replaced by
%   '_dot_'. This replacement may also be undone later (e.g. when
%   reconstructing urls from the struct).
%
%   NB: routine works only on the recent Hyrax version of OpenDAP as
%   xml catalog information needs to be present for this to work.
%
%   Syntax:
%       OpenDAPinfo = getOpenDAPinfo(varargin)
%
%   Input:
%       For the following keywords, values are accepted (values indicated are the current default settings):
%           'url', 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/catalog.xml' % default is OpenDAP test server url
%
%   Output:
%       OpenDAPinfo = cell array with info about the user specified url
%
%   Example:
%       url     = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/catalog.xml'; % base url to use
%       OpenDAPinfo = getOpenDAPinfo('url', url)
%
%       url     = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/catalog.xml'; % base url to use
%       OpenDAPinfo = getOpenDAPinfo('url', url)
%
%       url     = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/waterbase.nl/concentration_of_suspended_matter_in_sea_water/catalog.xml';
%       OpenDAPinfo = getOpenDAPinfo('url', url)
%
%       url     = 'http://micore.wldelft.nl/opendap/catalog.xml'
%       OpenDAPinfo = getOpenDAPinfo('url', url)
%
%   See also getOpenDAPlinks

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl	
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% Created: 26 Apr 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%  TODO: make routine more generic
%        - should also work if you start at a level where there are only datafiles
%        - should also be possible to choose only to find the institute and datasets levels (find datafiles only on demand to save time)

%%
OPT = struct(...
    'url', 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/catalog.xml' ... % default is OpenDAP test server url
    );

OPT = setProperty(OPT, varargin{:});

%% initialise 
url1     = OPT.url;
catpat   = 'catalog.xml';                                                         % catalog string pattern to use

%% preset test settings
datacell = getOpenDAPlinks('url', url1, 'pattern', ' xlink:title="');
tst      = cellfun(@strfind, datacell, repmat({'.nc'}, size(datacell)), 'UniformOutput', 0);

clc
disp(['Analysing OpenDAP url: ' OPT.url])
disp(' ')
disp('This may take several seconds depending on:')
disp('... the speed of your internet connection')
disp('... the depth of your request')
tic
i = 1;
while any(cellfun(@isempty, tst))
    if isempty(strfind(datacell{i},'.nc')) % if this entry is not an nc-file already add levels
        newurl       = [url1(1:strfind(url1, 'catalog.xml')-1) datacell{i} '/' catpat];
        add2cell     = [];
        %% add datafiles
        Datafiles    = getOpenDAPlinks('url', newurl, 'pattern', 'dataset name="');
        Datafiles    = Datafiles(~cellfun(@isempty, strfind(Datafiles,'.nc')));
        if ~isempty(Datafiles)
            for j = 1:length(Datafiles)
                startid = strfind(url1,catpat);
                stopid  = strfind(newurl,catpat)-2;
                pathstr = newurl(startid:stopid);
                add2cell{length(add2cell)+1, 1}= [pathstr '/' Datafiles{j}]; %#ok<*AGROW>
            end
        end
        
        %% add deeper levels
        Deeperlevels = getOpenDAPlinks('url', newurl, 'pattern', ' xlink:title="');
        if ~isempty(Deeperlevels)
            for j = 1:length(Deeperlevels)
                startid = strfind(url1,catpat);
%                 startid = strfind(newurl,'opendap/')+length('opendap/');
                stopid  = strfind(newurl,catpat)-2;
                pathstr = newurl(startid:stopid);
                add2cell{length(add2cell)+1, 1}= [pathstr '/' Deeperlevels{j}];
            end
        end
        if ~isempty(add2cell)
            if i==1
                datacell = {add2cell{:} datacell{i+1:end}}';
            else
                datacell = {datacell{1:i-1}  add2cell{:} datacell{i+1:end}}';
            end
            i = 1;
        else
            i = i + 1;
            if i > length(datacell)
                % if i is greater than de length of the variable apparently
                % we are ready so tst can be set to 1 to exit the while
                % loop
                tst = 1; %#ok<NASGU>
            end
        end
        clear add2cell
        tst = cellfun(@strfind, datacell, repmat({'.nc'}, size(datacell)), 'UniformOutput', 0);
        
    else
        i = i + 1;
        if i > length(datacell)
            tst = 1;
        end
    end
end

[structpath, filename, ext] = cellfun(@fileparts, datacell, 'UniformOutput', 0);
structpath = cellfun(@strrep, structpath, repmat({'.'}, size(structpath)), repmat({'_dot_'}, size(structpath)), 'UniformOutput', 0);
structpath = cellfun(@strrep, structpath, repmat({'/'}, size(structpath)), repmat({'.temp_'}, size(structpath)), 'UniformOutput', 0);
structpath = cellfun(@horzcat, repmat({'OpenDAPinfo.'}, size(structpath)), structpath, 'UniformOutput', 0);

tempo = unique(structpath);
for i = 1 : length(tempo)
    ids = find(ismember(structpath,tempo(i)));
    for j = 1:length(ids)
        eval([tempo{i} '(' num2str(j) ',1)={''' filename{ids(j)}  ext{ids(j)} '''};']);
    end
end

disp(' ')
disp(['Analysis finished in ' num2str(toc) ' seconds'])