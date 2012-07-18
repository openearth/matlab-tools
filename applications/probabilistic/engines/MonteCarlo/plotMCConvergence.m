function plotMCConvergence(result, varargin)
%PLOTMCCONVERGENCE  Plot convergence diagram based on MC result structure
%
%   Plot convergence diagram based on MC result structure.
%
%   Syntax:
%   plotMCConvergence(result, varargin)
%
%   Input:
%   result    = result structure from MC routine
%   varargin  = confidence:     confidence used in computation of accuracy
%               naccuracy:      number of locations where accuracy is
%                               computed
%
%   Output:
%   none
%
%   Example
%   plotMCConvergence(result)
%
%   See also MC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Dorothea Kaste
%
%       dorothea.kaste@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       Netherlands
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
% Created: 21 May 2012
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct(...
    'confidence',       .95,    ...
    'naccuracy',        100     ...
);

OPT = setproperty(OPT, varargin{:});

%% check input

if ~isstruct(result)
    error('No structure given');
end

if ~isfield(result,'Output')
    error('No output field found');
end

if ~isstruct(result.Output)
    error('No output structure found');
end

if ~isfield(result.Output,'idFail') || ~isfield(result.Output,'Calc') || ~isfield(result.Output,'P_corr')
    error('No data found');
end

%% compute accuracy

n = result.Output.Calc;
Pf = result.Output.P_f;

x = [1:n]';
%y = cumsum(result.Output.idFail.*result.Output.P_corr)./x;
y=cumsum(mean(result.Output.idFail,2).*result.Output.P_corr)./x;


p = round(logspace(0,log10(n),OPT.naccuracy));
a = nan(size(p))';
for i = 1:length(a)
    ii   = p(i);
    COV  = sqrt(mean((y(1:ii)-y(ii)).^2))/y(ii);
    a(i) = norm_inv((OPT.confidence+1)/2,0,1)*COV*y(ii);
end

Acy = a(end);
Acy_rel = Acy/Pf*100;
nf = sum(result.Output.idFail);

%% plot convergence

figure; hold on;

plot(x,y,'-b');
plot([1 n],Pf*[1 1],'-r');
plot(p,y(p)+a,'-g');
plot(p,y(p)-a,'-g');

xlabel('Number of samples [-]');
ylabel('Probability [-]');


legend({ ...
    'Convergence of probability of failure' ...
    'Estimated probability of failure' ...
    sprintf('%1.0f%% confidence interval', OPT.confidence*100)},'Location','SouthEast');

grid on;
set(gca,'XScale','log');
set(gca,'YScale','log');

title(sprintf('P_f = %2.1e ; Accuracy = %2.1e (%2.1f%%) ; N = %d ; N_f = %d', ...
        Pf, Acy, Acy_rel, n, nf));
        