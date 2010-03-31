function varargout = params2XB(varargin)
%PARAMS2XB  create XBeach communication structure out of params-file
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = params2XB(varargin)
%
%   Input:
%   varargin  = filename (fullpath) of params file
%
%   Output:
%   varargout = XBeach communication structure
%
%   Example
%   XB = params2XB('params.txt')
%
%   See also CreateEmptyXBeachVar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 17 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%% default filename
OPT = struct(...
    'filename', fullfile(cd, 'params.txt'));

if isvector(varargin)
    OPT = setProperty(OPT, 'filename', varargin{end});
end

pathstr = fileparts(OPT.filename);

%%
if exist(OPT.filename, 'file')
    % read file
    fid = fopen(OPT.filename);
    str = fread(fid, '*char')';
    fclose(fid);

    strcell = strread(str, '%s',...
        'delimiter', char(10));
    cellstr = cellfun(@(x) strread(x, '%s'), strcell,...
        'UniformOutput', false);

    Inputargs = {};
    for i = 1:length(cellstr)
        % convert text elements to propertyname-propertyvalue pairs as
        % input for CreateEmptyXBeachVar
        if any(strcmp(cellstr{i}, '='))
            Inputargs{end+1} = cellstr{i}{1}; %#ok<AGROW>
            if ~isnan(str2double(cellstr{i}{3}))
                cellstr{i}{3} = str2double(cellstr{i}{3});
            end
            if strcmp(Inputargs{end}, 'nglobalvar')
                Inputargs{end} = 'OutVars'; %#ok<AGROW>
                Inputargs{end+1} = {}; %#ok<AGROW>
                for j = 1:cellstr{i}{3}
                    Inputargs{end}{end+1} = cellstr{i+j}{1}; %#ok<AGROW>
                end
            else
                Inputargs{end+1} = cellstr{i}{3}; %#ok<AGROW>
            end
        elseif ~isempty(cellstr{i}) && ~isempty(strfind(cellstr{i}{1},'='))
            % User did not specify any space characters before and after
            % the = sign
            id = strfind(cellstr{i}{1},'=');
            if length(id)>1
                % multiple =-signs on one line
                continue
            end
            Inputargs{end+1} = cellstr{i}{1}(1:id-1); %#ok<AGROW>
            cellstr{i}{3} = cellstr{i}{1}(id+1:end);
            if ~isnan(str2double(cellstr{i}{3}))
                cellstr{i}{3} = str2double(cellstr{i}{3});
            end
            if strcmp(Inputargs{end}, 'nglobalvar')
                Inputargs{end} = 'OutVars'; %#ok<AGROW>
                Inputargs{end+1} = {}; %#ok<AGROW>
                for j = 1:cellstr{i}{3}
                    Inputargs{end}{end+1} = cellstr{i+j}{1}; %#ok<AGROW>
                end
            else
                Inputargs{end+1} = cellstr{i}{3}; %#ok<AGROW>
            end
        end
    end
    % create XB-structure using PropertyName-propertyValue pairs as
    % specified in file
    XB = CreateEmptyXBeachVar(Inputargs{:}, 'empty');
    % read depfile if available
    depfile = fullfile(pathstr, XB.settings.Grid.depfile);
    depfileExists = exist(depfile, 'file');
    if depfileExists
        XB.Input.zInitial = load(depfile);
    end
    if XB.settings.Grid.vardx
        % read depfile if available
        xfile = fullfile(pathstr, XB.settings.Grid.xfile);
        xfileExists = exist(xfile, 'file');
        if xfileExists
            XB.Input.xInitial = load(xfile);
        end
        % read depfile if available
        yfile = fullfile(pathstr, XB.settings.Grid.yfile);
        yfileExists = exist(yfile, 'file');
        if yfileExists
            XB.Input.yInitial = load(yfile);
        end
    end
    % read bcfile if available
    bcfile = fullfile(pathstr, XB.settings.Waves.bcfile);
    bcfileExists = exist(bcfile, 'file');
    if bcfileExists
        XB = XB_read_bcfile(XB,...
            'path', pathstr);
    end
    % read zs0file if available
    zs0file = fullfile(pathstr, XB.settings.Flow.zs0file);
    zs0fileExists = exist(zs0file, 'file');
    if zs0fileExists
        XB.settings.Flow.zs0 = load(zs0file);
    end
    
    varargout = {XB Inputargs};
else
    warning('PARAMS2XB:FileNotFound', ['File ' OPT.filename ' not found.'])
end