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
stochast = result.Input;   % all variables, including deterministic ones
active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr},...
    'UniformOutput', false));
Nstoch = sum(active);   % number of random variables (deterministic ones excuded)

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

% dimensions: number of calculations and number of iterations. Each
% iteration consists of Nstoch+1 calculations of the z-variable, i.e.
% a computations for the current state vector x and Nstoch perturbations,
% (1 for each random variable)
Nx = size(result.Output.x,1);
xnums = 1:Nx;
Ndv = result.settings.DerivativeSides; % 1 or 2 sided derivatives
if mod(Nx-1, Ndv*Nstoch+1) ~=0
    error('length of resultvector x no multiple of number of random variables');
end
IterIndex = [(Ndv*Nstoch+1:Ndv*Nstoch+1:Nx-1) Nx];

% make subplots for each active stochast
activeInd = find(active);
for i = activeInd
    % prepare subplot and add title and axis labels
    subplot(NrFigureRows, NrFigureColumns, find(activeInd == i),...
        'Nextplot', 'add',...
        'XLim', [0 Nx])
    title(result.Input(i).Name)
    xlabel('Calculations')
    ylabel(result.Input(i).Name)
        
    xi = result.Output.x(:,i);
    % plot FORM iterations
    plot(xnums(IterIndex), xi(IterIndex),...
        'DisplayName', 'FORM iterations',...
        'LineWidth', 2);
    % plot individual calculations
    plot(xnums, xi, 'b:',...
        'DisplayName', 'all computations');
    % add legend
    leg = legend('toggle');
    set(leg,...
        'location', 'best');
end

%%
if nargout == 1
    varargout = {fig};
end