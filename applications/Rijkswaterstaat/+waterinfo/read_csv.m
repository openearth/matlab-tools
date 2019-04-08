function [OUT] = read_csv(fname)
%read_csv  Function to read .csv files downloaded from waterinfo
%
%   Script can deal with multiple variables in csv file, these are added as
%   GROOTHEID_OMSCHRJVING_1, GROOTHEID_OMSCHRJVING_2, GROOTHEID_OMSCHRJVING_n
%   and the values as
%   NUMERIEKEWAARDE_1, NUMERIEKEWAARDE_2, NUMERIEKEWAARDE_n
%
%   NOTE: Function is not suitable (yet) for csv files with multiple stations!
%
%   csv files downloaded from https://waterinfo.rws.nl/.
%
%   Syntax:
%   OUT = waterinfo.read_csv(fname)
%
%   Input:
%   fname           filename of .csv file
%
%   Output:
%   OUT             struct with fieldnames from the header of csv file
%
%   Example
%   [OUT] = waterinfo.read_csv('d:\waterinfo.csv\')
%
%   See also
%   waterinfo.read_waterlevel

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       schrijve
%
%       reinier.schrijvershof@deltares.nl
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
% Created: 08 Apr 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: $
% $Date: 8 Apr 2019
% $Author: schrijve
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% OPT.keyword=value;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);

%% 1) Read header

% Header
delimiter   = ';';
frmt        = repmat('%s',1,50);
fid         = fopen(fname,'r');
header      = textscan(fid,frmt,1,...
    'Delimiter',delimiter);
fclose(fid);
header      = vertcat(header{:});
ncols       = find(contains(header,'TAXON_NAME'));
header(ncols+1:end) = [];
header      = strrep(header,' ',''); % Remove whitespaces in header fields

%% 2) Read data
clear OUT; clc;
% Empty struct
OUT        = cell2struct(num2cell(NaN(size(header))),header',1);

% Format specification
frmt        = cellstr(repmat('%s',length(header),1));


id1       = find(strcmp(header,'WAARNEMINGDATUM'));
id2       = find(strcmp(header,'WAARNEMINGTIJD'));
id3       = find(strcmp(header,'NUMERIEKEWAARDE'));
frmt{id1} = '%{dd-MM-yyyy}D';
frmt{id2} = '%{HH:mm:ss}D';
frmt{id3} = '%q';
frmt        = horzcat(frmt{:});

delimiter = ';';
startRow = 2;
fid = fopen(fname,'r');
data = textscan(fid,frmt,...
    'Delimiter',delimiter,...
    'HeaderLines',startRow-1,...
    'DateLocale','nl_NL',...
    'ReturnOnError',false);
fclose(fid);


flds = fieldnames(OUT);
for i = 1:length(flds)
    f = flds{i};
    tmp = data{i};
    
    if length(unique(tmp)) == 1
        if cellfun('isempty',unique(tmp))
            OUT.(f) = [];
        elseif iscellstr(unique(tmp))
            OUT.(f) = unique(tmp);
        end
    elseif length(unique(tmp)) > 1
        
        
        if strcmp(f,'WAARNEMINGDATUM') || strcmp(f,'WAARNEMINGTIJD') % Time array
            OUT = rmfield(OUT,f);
            if ~isfield(OUT,'datenum')
                OUT.datenum = datenum([year(data{id1}),month(data{id1}),day(data{id1}),...
                    hour(data{id2}),minute(data{id2}),second(data{id2})]);
            end
        elseif strcmp(f,'NUMERIEKEWAARDE') % Values
            flds2 = fieldnames(OUT);
            ids = ~cellfun('isempty',strfind(flds2,'GROOTHEID_OMSCHRIJVING'));
            vars = flds2(ids);
            nvars = length(vars);
            for j = 1:nvars
                fnew = sprintf('%s_%d',f,j);
                v = vars{j};
                id      = strcmp(header,'GROOTHEID_OMSCHRIJVING');
                locs    = strcmp(data{id},OUT.(v));
                OUT.(fnew) = str2double(data{i}(locs));
            end
        else
            OUT = rmfield(OUT,f);
            tmp2 = unique(tmp);
            for j = 1:length(tmp2)
                fnew = sprintf('%s_%d',f,j);
                OUT.(fnew) = tmp2(j);
            end
        end
    end
    
end




%% 3) Calculations

% Replace dummy values with NaN
% Note: dummy value changes with variable
for i = 1:nvars
    v = sprintf('NUMERIEKEWAARDE_%d',i);
    OUT.(v)(OUT.(v) == 99999) = NaN;
    OUT.(v)(OUT.(v) == 999999999) = NaN;
end

% Check if time is sorted and sort otherwise
if diff(OUT.datenum) < 0
    [OUT.datenum,sid] = sort(OUT.datenum);
    for j = 1:nvars
        v = sprintf('NUMERIEKEWAARDE_%d',j);
        OUT.(v) = OUT.(v)(ids);
    
        % To Do: add unique statement to find double entries on a single
        % date and average the data at the multiple time stamps
%         OUT.datenum = unique(OUT.datenum); % Multiple date stamps in file for different variables
%         OUT.datestr = cellstr(datestr(OUT.datenum));
    end
end

%% 4) Write information
clc;
[fpath,name,ext] = fileparts(fname);

fprintf('\tDone reading %s%s\n',name,ext);
fprintf('\t%d variables were found and processed:\n',nvars);
for i = 1:nvars
    v = vars{i};
    fprintf('\t- %s\n',OUT.(v){:});
end
fprintf('\n');

return

