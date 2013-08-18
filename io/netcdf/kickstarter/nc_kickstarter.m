function varargout = nc_kickstart(varargin)
%NETCDFKICKSTARTER  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = netcdfKickstarter(varargin)
%
%   Input: For <keyword,value> pairs call netcdfKickstarter() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   netcdfKickstarter
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 14 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct( ...
    'host','http://127.0.0.1:65433', ...
    'template','');
    
OPT = setproperty(OPT, varargin);

%% choose a template

if isempty(OPT.template)
    
    templates = json.load(urlread(OPT.host));

    for i = 1:length(templates)
        fprintf('[%2d] %s\n',i,templates{i});
    end

    fprintf('\n');

    template_id = input('Choose template [1]:','s');

    if isempty(template_id)
        template_id = 1;
    elseif regexp(template_id,'^\d+$')
        template_id = str2num(template_id);
        if template_id <= 0 || template_id > length(templates)
            error('Invalid template number [%d]',template_id);
        end
    else
        error('Invalid template sepcification [%s]',template_id);
    end

    OPT.template = templates{template_id};
    
end

query_string = sprintf('t=%s', urlencode(OPT.template));

%% define variables

fprintf('\n');

var = nan;

n = 1;
while ~isempty(var)
    var = input(sprintf('Name of variable #%d (press enter to skip):\n',n),'s');
    
    if isempty(var)
        break;
    end
    
    fprintf('\n');
    fprintf('----------------------------------------\n');
    fprintf('%s\n',upper(var));
    fprintf('----------------------------------------\n');
    fprintf('\n');
    
    m = json.load(urlread(fullfile(OPT.host,'templates',[OPT.template '?category=var'])));
    
    for j = 1:length(m)
        v = input(sprintf('%s:\n',m(j).description),'s');
        
        query_string = sprintf('%s&m[%s.%s]=%s',query_string,m(j).category,m(j).key,urlencode(v));
        
        fprintf('\n');
    end
    
    n = n + 1;
end

%% load categories

categories = setdiff(json.load(urlread(fullfile(OPT.host,'categories'))),{'var'});

%% show other markers

pref_group = 'netcdfKickstarter';

for i = 1:length(categories)
    
    fprintf('----------------------------------------\n');
    fprintf('%s\n',upper(categories{i}));
    fprintf('----------------------------------------\n');
    fprintf('\n');
    
    m = json.load(urlread(fullfile(OPT.host,'templates',[OPT.template '?category=' categories{i}])));
    
    for j = 1:length(m)        
        if m(j).save
            pref_key = sprintf('%s_%s',m(j).category,m(j).key);

            if ispref(pref_group,pref_key)
                v = getpref(pref_group,pref_key);
            else
                v = '';
            end
            
            v_new = input(sprintf('%s [%s]:\n',m(j).description,v),'s');
            
            if ~isempty(v_new)
                v = v_new;
            end
            
            setpref('netcdfKickstarter',pref_key,v);
        else
            v = input(sprintf('%s:\n',m(j).description),'s');
        end
        
        query_string = sprintf('%s&m[%s.%s]=%s',query_string,m(j).category,m(j).key,urlencode(v));
        
        fprintf('\n');
    end
    
end

%% download netcdf

[fname, fpath] = uiputfile( ...
    {'*.nc';'*.*'}, ...
    'Save netCDF file', ...
    regexprep(OPT.template,'\.cdl$','.nc'));

if fname > 0
    fprintf('Downloading file... ');
    
    urlwrite(fullfile(OPT.host,['netcdf?' query_string]),fullfile(fpath,fname));
    
    fprintf('done\n');
    fprintf('Saved file to %s\n', fullfile(fpath,fname));
    fprintf('\n');
    fprintf('To add data to the newly created netCDF file, use the following commands:\n');
    fprintf('>> ncfile = ''%s''\n', fullfile(fpath,fname));
    fprintf('>> nc_varput(ncfile,''x'',x);\n');
    fprintf('>> nc_varput(ncfile,''y'',y);\n');
    fprintf('>> nc_varput(ncfile,''z'',z);\n');
end