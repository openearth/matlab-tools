function [result equivFORMResult] = plotMCResult(result, varargin)
% plotMCResult: Plots data from result structure of MC routine and optionally approximates corresponding Design Point
%
%   Creates a figure with subplots for each combination of active stochasts
%   found in the provided result structure. Optionally the Design Point is
%   approximated based on the Monte Carlo results and plotted in the
%   subplots. In case a result structure from the FORM routine is provided
%   the Design Point approximation from the FORM routine is plotted in the
%   subplots as well.
%
%   Syntax:
%   [result equivFORMResult] = plotMCResult(result, varargin)
%
%   Input:
%   result      = result structure from MC routine
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%   
%                 'figureID'        = handle number of figure object
%                                       (default: 1)
%                 'space'           = variable space in which data is
%                                       plotted (u or x, default: u)
%                 'plotDP'          = determines whether Design Point is
%                                       plotted and, if necessary,
%                                       approximated (true or false,
%                                       default: true)
%                 'printDP'         = determines whether Design Point is
%                                       printed in the command window and,
%                                       if necessary, approximated (true or
%                                       false, default: true)
%                 'precisionDP'     = see approxMCDesignPoint function
%                 'methodDP'        = see approxMCDesignPoint function
%                 'thresholdDP'     = see approxMCDesignPoint function
%                 'optimizeDP'      = see approxMCDesignPoint function
%                 'equivFORMResult'	= result structure from FORM routine
%                                       from calculation with same
%                                       stochast. Resulting Design Point is
%                                       plotted for comparison.
%                 'forceDP'         = force approximation of Design Point,
%                                       even if provided result structure
%                                       already contains a Design Point
%                                       description (true or false,
%                                       default:false)
%
%   Output:
%   result          = original result structure from MC routine with Design
%                       Point description added
%   equivFORMResult = original result structure from FORM routine with
%                       Design Point description added
%
%   Example
%   result = plotMCResult(result)
%
%   See also MC approxMCDesignPoint printDesignPoint FORM

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
OPT = struct(...
    'figureID', [], ...
    'space', 'u', ...
    'plotDP', false, ...
    'printDP', false, ...
    'precisionDP', 0, ...
    'methodDP', '', ...
    'thresholdDP', 0, ...
    'optimizeDP', '', ...
    'equivFORMResult', [], ...
    'forceDP', false, ...
    'no3D', false ...
);

OPT = setproperty(OPT, varargin{:});

% do not plot design point in other space than u
if ~strcmp(OPT.space, 'u')
    OPT.plotDP = false;
end

%% approximate design point

if OPT.plotDP || OPT.printDP || OPT.forceDP
    if OPT.forceDP || (~isfield(result.Output, 'designPoint') && ~isfield(result.Output, 'designPointOptimized'))
        result = approxMCDesignPoint(result, 'method', OPT.methodDP, 'threshold', OPT.thresholdDP, 'optimize', OPT.optimizeDP, 'precision', OPT.precisionDP);
    end

    if ~isempty(OPT.equivFORMResult) && (OPT.forceDP || ~isfield(OPT.equivFORMResult.Output, 'designPoint'))
        OPT.equivFORMResult = getFORMDesignPoint(OPT.equivFORMResult);
    end
end

%% print design point

if OPT.printDP
    printDesignPoint(result, 'types', {'designPoint'});
    
    if ~isempty(OPT.equivFORMResult)
        printDesignPoint(OPT.equivFORMResult);
    elseif isfield(result.Output, 'equivFORMResult')
        printDesignPoint(result.Output.equivFORMResult);
    end
end

%% create scatter plots

if isempty(OPT.figureID)
    % create full screen window
    fullscreen = get(0, 'ScreenSize');
    figure('OuterPosition', [0 0 fullscreen(3) fullscreen(4)]);
else
    figure(OPT.figureID);
end

% retrieve stochast names and indexes from result
varIdxs = [1:length(result.Input)];
varNames = {result.Input.Name};

% determine which stochasts are active
distributions = {result.Input.Distr};
for i = 1:length(distributions)
    if strcmp(func2str(distributions{i}), 'deterministic')
        distributions{i} = [];
    end
end
activeVars = ~cellfun(@isempty, distributions);

% determine indexes failure and non-failure points
idxFail = find(result.Output.idFail==1);
idxNoFail = find(result.Output.idFail==0);

% split failure and non-failure data points
fail = [];
noFail = [];

if strcmp(OPT.space, 'x')
    fail = [result.Output.x(idxFail, :)];
    noFail = [result.Output.x(idxNoFail, :)];
else
    fail = [result.Output.u(idxFail, :)];
    noFail = [result.Output.u(idxNoFail, :)];
end

if sum(activeVars) == 3 && ~OPT.no3D
    
    % plot scatter points
    scatter3(fail(:, 1), fail(:, 2), fail(:, 3),...
        'SizeData', 9,...
        'MarkerFaceColor', [0 0 0],...
        'MarkerEdgeColor', [0 0 0],...
        'DisplayName', 'Failure');
    hold on;
    scatter3(noFail(:, 1), noFail(:, 2), noFail(:, 3),...
        'SizeData', 9,...
        'MarkerFaceColor', [1 1 1],...
        'MarkerEdgeColor', [0 0 0],...
        'DisplayName', 'Non-failure');
    
    % style scatter plot
    xlabel(varNames{1}); ylabel(varNames{2}); zlabel(varNames{3});
    legend('toggle')
    
else
    
    % calculate combinations of stochasts
    varCombs = combnk_p(varIdxs(activeVars));

    % calculate dimensions of plots
    dimPlots = ceil(sqrt(size(varCombs, 1)));

    dimPlots1 = dimPlots;
    dimPlots2 = ceil(size(varCombs, 1) / dimPlots);

    for i = 1:size(varCombs, 1)
        subplot(dimPlots2, dimPlots1, i);

        % get variable indexes
        idxXVar = varCombs(i,1);
        idxYVar = varCombs(i,2);

        % get variable names
        nameXVar = varNames{idxXVar};
        nameYVar = varNames{idxYVar};

        % plot scatter points
        scatter(fail(:, idxXVar), fail(:, idxYVar),...
            'SizeData', 9,...
            'MarkerFaceColor', [0 0 0],...
            'MarkerEdgeColor', [0 0 0],...
            'DisplayName', 'Failure');
        hold on;
        scatter(noFail(:, idxXVar), noFail(:, idxYVar),...
            'SizeData', 9,...
            'MarkerFaceColor', [1 1 1],...
            'MarkerEdgeColor', [0 0 0],...
            'DisplayName', 'Non-failure');

        % plot design point
        if OPT.plotDP && strcmp(OPT.space, 'u')

            % plot design point according to FORM method
            if ~isempty(OPT.equivFORMResult)
                scatter(OPT.equivFORMResult.Output.designPoint.u(idxXVar), OPT.equivFORMResult.Output.designPoint.u(idxYVar),...
                    'SizeData', 25,...
                    'MarkerFaceColor', [0 1 0],...
                    'MarkerEdgeColor', [0 0 0],...
                    'DisplayName', 'FORM designpoint');
                hold on;
            end

            % plot first estimation of design point
            if ~isempty(result.Output.designPoint.a) && ~isempty(result.Output.designPoint.c)
                line([result.Output.designPoint.a(idxXVar) result.Output.designPoint.c(idxXVar)], [result.Output.designPoint.a(idxYVar) result.Output.designPoint.c(idxYVar)],...
                    'LineWidth', 1,...
                    'Color', [1 0 0]);
                if ~isempty(result.Output.designPoint.u)
                    scatter(result.Output.designPoint.u(idxXVar), result.Output.designPoint.u(idxYVar),...
                        'SizeData', 25,...
                        'MarkerFaceColor', [1 0 0],...
                        'MarkerEdgeColor', [0 0 0],...
                        'DisplayName', 'Designpoint');
                    hold on;
                end
            end

            % plot optimized design point
            if isfield(result.Output, 'designPointOptimized') && ~isempty(result.Output.designPointOptimized.u)
                scatter(result.Output.designPointOptimized.u(idxXVar), result.Output.designPointOptimized.u(idxYVar),...
                    'SizeData', 25,...
                    'MarkerFaceColor', [1 .5 0],...
                    'MarkerEdgeColor', [0 0 0],...
                    'DisplayName', 'Optimized designpoint');
                hold on;
            end
        end

        % style scatter plot
        xlabel(nameXVar); ylabel(nameYVar);
        legend('toggle')
    end
end

%% return variable
equivFORMResult = OPT.equivFORMResult;

function c = combnk_p(vec)

c = [];

n = length(vec);

for i = 1:n
    for j = i+1:n
        c = [c;i j];
    end
end

c = vec(c);