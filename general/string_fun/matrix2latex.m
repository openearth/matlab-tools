function varargout = matrix2latex(x, varargin)
%MATRIX2LATEX  creates a LaTeX table based on a matrix
%
%   Transforms a matrix (double) to a LaTeX table.
%
%   Syntax:
%   varargout = matrix2latex(varargin)
%
%   Input:
%   x         = matrix (double)
%   varargin  = propertyName-propertyValue pairs as available in OPT
%               structure
%
%   Output:
%   varargout =
%
%   Example
%   matrix2latex
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'title', 'table',...
    'filename', 'table.tex',...
    'where', '!tbp',...
    'rowlabel', '',...
    'rowjustification', 'l',...
    'collabel', '',...
    'caption', '',...
    'justification', 'center');

OPT = setProperty(OPT, varargin{:});

%% build table
% table preamble 
texcell = {};
texcell{end+1} = sprintf('%s', '\begin{table}[', OPT.where, ']');
texcell{end+1} = sprintf('%s', ' \caption{', OPT.caption, '\label{', OPT.title, '}}'); 
texcell{end+1} = sprintf('%s', ' \begin{', OPT.justification, '}');
texcell{end+1} = sprintf('%s', ' \begin{tabular}{', repmat(OPT.rowjustification, 1, size(x,2)), '}\hline\hline');
% table header
if ~isempty(OPT.collabel)
    columnheader = '';
    for i = 1:size(x,2)-1
        columnheader = sprintf('%s', columnheader, '\multicolumn{1}{c}{', OPT.collabel{i}, '}', '&');
    end
    columnheader = sprintf('%s', columnheader, '\multicolumn{1}{c}{', OPT.collabel{i+1}, '}', '\tabularnewline');
    texcell{end+1} = columnheader;
    texcell{end+1} = sprintf('%s', '\hline');
end

% table contents
for i = 1:size(x,1)
    tabrow = '';
    for j = 1:size(x,2)-1
        tabrow = sprintf('%s', tabrow, num2str(x(i,j)), '&');
    end
    tabrow = sprintf('%s', tabrow, num2str(x(i,j+1)), '\tabularnewline');
    texcell{end+1} = tabrow;
end

% table closure
texcell{end+1} = sprintf('%s', '\hline');

texcell{end+1} = sprintf('%s', '\end{tabular}');

texcell{end+1} = sprintf('%s', '\end{', OPT.justification, '}');

texcell{end+1} = sprintf('%s', '\end{table}');

%% write table to file
fid = fopen(OPT.filename, 'w');
tex = fprintf(fid, '%s\n', texcell{:});
fclose(fid);