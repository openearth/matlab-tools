function varargout = plotFORMresult(result, fhandle)
%PLOTFORMRESULT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = plotFORMresult(result, fhandle)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   plotFORMresult
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%%
Nstoch = length(result.Input);
NrFigureColumns = ceil(sqrt(Nstoch));
if NrFigureColumns*(NrFigureColumns-1) >= Nstoch
    NrFigureRows = NrFigureColumns-1;
else
    NrFigureRows = NrFigureColumns;
end

if exist('fhandle', 'var') && ishandle(fhandle) && strcmp(get(fhandle, 'Type'), 'figure')
    fig = fhandle;
else
    fig = figure;
end

for i = 1:Nstoch
    
    subplot(NrFigureRows, NrFigureColumns, i,...
        'Nextplot', 'add',...
        'XLim', [0 size(result.Output.x,1)])
    title(result.Input(i).Name)
    xlabel('Calculations')
    ylabel(result.Input(i).Name)
    
    plot(1:size(result.Output.x,1), result.Output.x(:,i),...
        'DisplayName', result.Input(i).Name)
end

%%
if nargout == 1
    varargout = {fig};
end