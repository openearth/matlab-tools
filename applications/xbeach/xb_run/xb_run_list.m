function varargout = xb_run_list(varargin)
%XB_RUN_LIST  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_run_list(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_run_list
%
%   See also 

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
% Created: 15 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'n', 5 ...
);

OPT = setproperty(OPT, varargin{:});

%% list runs

runs = xb_getpref('runs');

formatstr = '%8s %-15s %-6s %-25s %-7s %-50s';

if ~isempty(runs) && iscell(runs)
    hdr = sprintf(formatstr, 'ID', 'Name', 'Nodes', 'Binary', 'Remote', 'Log');
    
    disp(hdr);
    fprintf([repmat('-',1,length(hdr)) '\n']);
    
    for i = 1:length(runs)
        xb = xb_peel(runs{i});
        if exist(xb.path, 'dir')
            line = '';
            logfile = fullfile(xb.path, 'XBlog.txt');
            if exist(logfile, 'file')
                line = tail(logfile, 'n', OPT.n);
            end
            
            for j = 1:max([size(line,1) 1])
                if j == 1
                    fprintf([formatstr '\n'], ...
                        num2str(xb.id), ...
                        xb.name, ...
                        num2str(xb.nodes), ...
                        xb.binary, ...
                        num2str(isfield(xb, 'ssh')), ...
                        line(j,:) );
                else
                    fprintf([formatstr '\n'], ...
                        '', ...
                        '', ...
                        '', ...
                        '', ...
                        '', ...
                        line(j,:) );
                end
            end
            
            disp(' ');
        else
            runs(i) = [];
        end
    end
end

xb_setpref('runs', runs);
