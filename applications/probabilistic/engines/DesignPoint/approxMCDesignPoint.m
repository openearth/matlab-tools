function result = approxMCDesignPoint(result, varargin)
% approxMCDesignPoint: Approximates Design Point based on result structure from MC routine
%
%   Approximates the Design Point based on the centre of gravity of the
%   failure points of the Monte Carlo results. The routine searches for the
%   crossing of the line between the origin in u-space and the centre of
%   gravity of the failure points and the limit state line by bifurcation.
%   The crossing found is the first approximation of the Design Point.
%   Optionally the result is optimized using an optimization routine. Both
%   the original and the optimized results are added to the original result
%   structure and returned.
%
%   Syntax:
%   [result] = approxMCDesignPoint(result, varargin)
%
%   Input:
%   result      = result structure from MC routine
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%   
%                 'precision'   = precision of Desing Point approximation,
%                                   which is the maximum Z value of
%                                   approximation. The square of this value
%                                   is used as epsZ value for FORM routine
%                                   (default: 0.05)
%                 'optimize'    = identifier of optimization routine to be
%                                   used (default: FORM)
%
%   Output:
%   result      = original result structure with Design Point
%                   description(s) added
%
%   Example
%   result = approxMCDesignPoint(result)
%
%   See also MC FORM printDesignPoint plotMCResult

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
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

% Created: 13 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% settings

OPT = struct( ...
    'precision', 0.05, ...
    'optimize', 'FORM' ...
);

OPT = setProperty(OPT, varargin{:});

%% approximate design point

% determine stochast names
varNames = {result.Input.Name};

% determine failure indexes
idxFail = find(result.Output.idFail);

tDP = tic;

    % calculate mode and centre of gravity
    a = zeros(1, length(varNames));
    c = mean(result.Output.u(idxFail, :));
%    c = mean(result.Output.u(idxFail, :) .* result.Output.P(idxFail, :)) ./ mean(result.Output.P(idxFail, :));

    % calculate limit crossing along line between mode and centre of gravity
    designPoint = getLimitCrossing(result, a, c, 'precision', OPT.precision);

    % calculate probability of failure
    designPoint.P = 1 - norm_cdf(sqrt(sum((designPoint.u).^2)), 0, 1);
    
designPoint.time = toc(tDP);

%% optimize result

designPointOptimized = struct('u', [], 'x', [], 'z', Inf, 'P', 0);

% if first estimation of design point is available, try to optimize
if ~isempty(designPoint.u) && ~any(isnan(designPoint.u)) && ~isempty(OPT.optimize)
    
    tDPO = tic;
        switch OPT.optimize
            case 'FORM'
                try
                    resultOptimized = FORM(result.Input, ...
                        'startU', designPoint.u, ...
                        'epsZ', OPT.precision^2, ...
                        'P2xFunction', result.settings.P2xFunction, ...
                        'x2zFunction', result.settings.x2zFunction, ...
                        'Resistance', result.settings.Resistance, ...
                        'variables', result.settings.variables ...
                    );

                    designPointOptimized.z = resultOptimized.Output.z(end);
                    designPointOptimized.u = resultOptimized.Output.u(end, :);
                    designPointOptimized.x = resultOptimized.Output.x(end, :);
                    designPointOptimized.iterations = resultOptimized.Output.Iter;
                    designPointOptimized.calculations = resultOptimized.Output.Calc;
                    designPointOptimized.converged = resultOptimized.Output.Converged;

                    % calculate probability of failure
                    designPointOptimized.P = resultOptimized.Output.P_f;
                catch
                    % throw error
                    error = lasterror;
                    disp(['ERROR: ' error.message]);
                end
        end
    designPointOptimized.time = toc(tDPO) + designPoint.time;
    
end

%% return variable

% construct return variable
result.Output.designPoint = designPoint;
result.Output.designPointOptimized = designPointOptimized;