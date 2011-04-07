function xb_reference(filename, varargin)
%XB_REFERENCE  Creates a WIKI page with a params.txt reference
%
%   Creates a WIKI page with a params.txt reference
%
%   Syntax:
%   xb_reference(filename, varargin)
%
%   Input:
%   filename  = Filename of generated file
%   varargin  = type:       Type of file (wiki)
%
%   Output:
%   none
%
%   Example
%   xb_reference('reference.txt')
%
%   See also xb_get_params

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct(...
    'type', 'wiki' ...
);

OPT = setproperty(OPT, varargin{:});

%% read parameters

[params params_array] = xb_get_params;

parname = {params_array.name};
partype = {params_array.partype};
upartype = unique(partype);

%% write file

fid = fopen(filename, 'w');

for i = 1:length(upartype)
    ipars = find(strcmpi(upartype{i}, partype));
    
    if ~isempty(ipars) && sum([params_array(ipars).noinstances]) > 0
        
        % create type header
        fprintf(fid, 'h3.%s\n', esc(upartype{i}));

        fprintf(fid, '{table-plus:width=1200}\n');
        fprintf(fid, '||Name||Units||Advanced||Deprecated||Affects||Description||Required||Default||Min||Max||Condition||\n');

        for j = ipars
            for k = 1:params_array(j).noinstances
                if k == 1
                    fprintf(fid, '|%s|%s|%s|%s|%s|%s|', ...
                        esc(params_array(j).name), ...
                        esc(params_array(j).units), ...
                        bin(params_array(j).advanced), ...
                        bin(params_array(j).deprecated), ...
                        esc(params_array(j).affects), ...
                        esc(params_array(j).comment)            );
                else
                    fprintf(fid, '| | | | | | |');
                end

                fprintf(fid, '%s|%s|%s|%s|%s|\n', ...
                    bin(params_array(j).required{k}), ...
                    esc(params_array(j).default{k}), ...
                    esc(params_array(j).minval{k}), ...
                    esc(params_array(j).maxval{k}), ...
                    esc(params_array(j).condition{k})           );

            end
        end

        fprintf(fid, '{table-plus}\n');
    end
end

fclose(fid);

function str = esc(str)
    if ~iscell(str); str = {str}; end;
    
    r = '|()[]{}-';
    
    for i = 1:length(str)
        if isnumeric(str{i}); str{i} = num2str(str{i}); end;
        
        for ii = 1:length(r)
            str{i} = strrep(str{i}, r(ii), ['\' r(ii)]);
        end
    end
    
    str = [' ' sprintf('%s ', str{:})];
end

function str = bin(str)
    if iscell(str); str = str{1}; end;
    
    if str
        str = '(/)';
    else
        str = '(x)';
    end
end

end
