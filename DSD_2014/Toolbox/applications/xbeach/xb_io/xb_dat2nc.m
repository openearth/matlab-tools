function ncfile = xb_dat2nc(fname, ncfile, varargin)
%XB_DAT2NC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_dat2nc(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_dat2nc
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 17 Nov 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_dat2nc.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_io/xb_dat2nc.m $
% $Keywords: $

%% read options

OPT = struct(...
    'vars', {{}},...
    'verbose',true);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.vars); OPT.vars = {OPT.vars}; end;

%% Gather dat files
if ~exist(fname, 'file')
    error(['File does not exist [' fname ']'])
end

% get filelist
if length(fname) > 3 && strcmpi(fname(end-3:end), '.dat')
    names = dir(fname);
    fdir = fileparts(fname);
else
    names = dir([fname filesep '*.dat']);
    fdir = fname;
end

if isempty(fdir); fdir = fullfile('.', ''); end;

%% get dimensions
if OPT.verbose
    disp('Reading dimensions');
end

dims = xb_read_dims(fdir);

%% Initiate NcFile
if OPT.verbose
    disp('Creating nc-file');
end
nc_create_empty(ncfile);  
globalAttributes = struct(...
    'Name',{'Conventions','Producer','Build-Revision','Build-Date','URL'},...
    'Value',{'CF-1.4','XBeach littoral zone wave model (http://www.xbeach.org)',[],[],'URL: https://repos.deltares.nl/repos/XBeach/trunk'});
if OPT.verbose
    disp('Adding global attributes');
end
for i = 1:length(globalAttributes)
    nc_attput(ncfile,nc_global,globalAttributes(i).Name,globalAttributes(i).Value);
end

%% CReate dimensions
if OPT.verbose
    disp('Adding dimensions');
end
dimnames = {'globalx','globaly','wave_angle','bed_layers','sediment_classes','inout',...
    'globaltime','points','pointtime','meantime','tidetime','tidecorners','windtime'};
f = fieldnames(dims);
for i = 1:length(dimnames)
    if ismember(dimnames{i},f)
        value = dims.(dimnames{i});
        if ~isnan(value)
            nc_adddim(ncfile,dimnames{i},value);
        end
    end
end

%% Create dimension related variables
if OPT.verbose
    disp('Adding dimension variables');
end
nc_addvar(ncfile,...
    struct(...
    'Name','globalx',...
    'Datatype','double',...
    'Dimension',{{'globalx','globaly'}}));
nc_varput(ncfile,'globalx',dims.x');
nc_attput(ncfile,'globalx','units','m');
nc_attput(ncfile,'globalx','long_name','local x coordinate');
nc_attput(ncfile,'globalx','standard_name','projection_x_coordinate');
nc_attput(ncfile,'globalx','axis','X');
nc_addvar(ncfile,struct(...
    'Name','globaly',...
    'Datatype','double',...
    'Dimension',{{'globalx','globaly'}}));
nc_varput(ncfile,'globaly',dims.y');
nc_attput(ncfile,'globaly','units','m');
nc_attput(ncfile,'globaly','long_name','local y coordinate');
nc_attput(ncfile,'globaly','standard_name','projection_y_coordinate');
nc_attput(ncfile,'globaly','axis','Y');

for i = 1:length(dimnames)
    if ismember(dimnames{i},f) && ~isempty(strfind(dimnames{i},'time'))
        value = dims.(dimnames{i});
        if ~isnan(value) && value ~= 0
            d = dimnames(i);
            varStruct = struct(...
                'Name',dimnames{i},...
                'Datatype','double',...
                'Dimension',{d});
            nc_addvar(ncfile,varStruct);
            nc_varput(ncfile,dimnames{i},dims.([dimnames{i} '_DATA']));
            nc_attput(ncfile,dimnames{i},'units','s');
            nc_attput(ncfile,dimnames{i},'axis','T');
            nc_attput(ncfile,dimnames{i},'standard_name','time');
        end
    end
end

%% Read XBeach variable props
varinfo = xb_get_varinfo;

%% read dat files one-by-one and create variables
if OPT.verbose
    disp('Adding variables from dat files:');
end
for i = 1:length(names)
    varname = names(i).name(1:length(names(i).name)-4);
    
    % skip, if not requested
    if any(strcmpi(varname, {'xy', 'dims'})) ||...
            ~isempty(OPT.vars) && ~any(strfilter(varname, OPT.vars));
        continue; 
    end;
        
    if OPT.verbose
        disp(['...' varname]);
    end
    
    filename = [varname '.dat'];
    fpath = fullfile(fdir, filename);
    
    % check if file is binary
    if isbinary(fpath)
        
        % determine dimensions
        [d variableDimNames] = xb_dat_dims(fpath);
        
        % read dat file
        dat = xb_dat_read(fpath, d);

        %% Write to ncfile
        varstruct = struct(...
            'Name',varname,...
            'Datatype','double',...
            'Dimension',{constructdims(fliplr(variableDimNames),varname)});
        nc_addvar(ncfile,varstruct);
        nc_varput(ncfile,varname,dat);
        
        attstruct = getvariableattributes(varname,varinfo);
        if ~isempty(attstruct)
            for iatt = 1:length(attstruct)
                nc_attput(ncfile,varname,attstruct(iatt).Name,attstruct(iatt).Value);
            end
        end
    end
end
end

function attstruct = getvariableattributes(varname,varinfo)
basevar = strrep(varname,'_max','');
basevar = strrep(basevar,'_min','');
basevar = strrep(basevar,'_mean','');
basevar = strrep(basevar,'_var','');

attstruct = [];
if ismember(basevar,{varinfo.Name})
    attstruct = struct('Name','coordinates','Value','globalx globaly');attstruct(1) = [];
    
    in = varinfo(find(strcmp({varinfo.Name},basevar),1,'first'));
    if ~isempty(in.Unit)
        attstruct(end+1).Name = 'units';
        attstruct(end).Value = in.Unit;
    end
    if ~isempty(in.Description)
        add = '';
        if ~isempty(strfind(varname,'_max'))
            add = ': max';
        elseif ~isempty(strfind(varname,'_min'))
            add = ': min';
        elseif ~isempty(strfind(varname,'_mean'))
            add = ': mean';
        elseif ~isempty(strfind(varname,'_var'))
            add = ': var';
        end
        attstruct(end+1).Name = 'long_name';
        attstruct(end).Value = in.Description;
        if ~isempty(add)
            attstruct(end+1).Name = 'cell_methods';
            attstruct(end).Value = ['meantime' add];
        end
    end
    if ~isempty(in.StandardName)
        attstruct(end+1).Name = 'standard_name';
        attstruct(end).Value = in.StandardName;
    end
end
end

function [variableDimNames] = constructdims(variableDimNames,varName)

variableDimNames = strrep(variableDimNames,'x','globalx');
variableDimNames = strrep(variableDimNames,'y','globaly');
variableDimNames = strrep(variableDimNames,'theta','wave_angle');
variableDimNames = strrep(variableDimNames,'gd','bed_layers');
variableDimNames = strrep(variableDimNames,'d','sediment_classes');

if regexp(varName, '_(mean|max|min|var)$')
    variableDimNames = strrep(variableDimNames,'t','meantime');
elseif regexp(varName, '^(point|rugau)\d+$')
    variableDimNames = strrep(variableDimNames,'t','pointtime');
else
    variableDimNames = strrep(variableDimNames,'t','globaltime');
end

end