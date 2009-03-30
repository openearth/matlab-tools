function t = getParabolicProfile_test(t)
% GETPARABOLICPROFILE_TEST test defintion routine
%
% see also getParabolicProfile

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl
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

%%
if nargout ~= 1
	% run test
	evalin('caller', ['[result t] = mc_test(''' mfilename ''');']);
	return
end

if nargin == 1
    % optional custom evaluation of test
    % evaluation 1: McT_ExactMatch
    % round t similar to the one written in the test definition file
    evalstr = var2evalstr(t);
    eval(evalstr);
    % run McT_ExactMatch
    t = feval(@McT_ExactMatch, t);

    if ~isempty(t(t.currentcase).cases.run.input.vars(5).content)
        % evaluation 2: plot the input and results
        % prepare variables
        x = t(t.currentcase).cases.run.input.vars(5).content;
        y = t(t.currentcase).cases.run.result.vars(2).content;

        % find/create figure
        h = findobj('Tag', mfilename); % find figure with the mfilename in the Tag
        if isempty(h)
            % create figure with the mfilename in the Tag
            figure('Tag', mfilename, 'Name', mfilename);
        end

        % plot, create legend and set axis limits and labels
        plot(...
            x, y, '-o' ...
            )
        xlabel('x')
        ylabel('y')
        set(gca, 'YDir', 'reverse');
    end
    return
end

%% create t-structure
t(1).functionname = @getParabolicProfile;
t(1).logfile = '';
t(1).resultdir = '';
t(1).currentcase = [];
t(1).cases.id = 1;
t(1).cases.name = 'getParabolicProfile test';
t(1).cases.description = 'getParabolicProfile test: derive xmax (created on 23-Jul-2008 16:24:38)';
t(1).cases.settings.settingsfunction = @DuneErosionSettings;
t(1).cases.settings.input.vars.name = 'varargin';
t(1).cases.settings.input.vars.content{1} = 'set';
t(1).cases.settings.input.vars.content{2} = 'n_d';
t(1).cases.settings.input.vars.content{3} = 1;
t(1).cases.settings.input.vars.content{4} = 'Plus';
t(1).cases.settings.input.vars.content{5} = '-plus';
t(1).cases.run.runfunction = @McT_RunFunction;
t(1).cases.run.input.vars(1).name = 'Hsig_t';
t(1).cases.run.input.vars(1).content = 9;
t(1).cases.run.input.vars(2).name = 'Tp_t';
t(1).cases.run.input.vars(2).content = 12;
t(1).cases.run.input.vars(3).name = 'w';
t(1).cases.run.input.vars(3).content = 0.0246782;
t(1).cases.run.input.vars(4).name = 'x0';
t(1).cases.run.input.vars(4).content = 0;
t(1).cases.run.input.vars(5).name = 'x';
t(1).cases.run.input.vars(5).content = [];
t(1).cases.run.result.runflag = [];
t(1).cases.run.result.vars.name = '';
t(1).cases.run.result.vars.content = [];
t(1).cases.evaluation.evaluationfunction = @getParabolicProfile_test;
t(1).cases.evaluation.input.expoutvars(1).name = 'xmax';
t(1).cases.evaluation.input.expoutvars(1).content = 325.079;
t(1).cases.evaluation.input.expoutvars(2).name = 'y';
t(1).cases.evaluation.input.expoutvars(2).content = [];
t(1).cases.evaluation.input.expoutvars(3).name = 'Tp_t';
t(1).cases.evaluation.input.expoutvars(3).content = 12;
t(1).cases.evaluation.result = [];
t(1).process.processfunction = '';
t(1).process.input = [];
t(1).process.result = [];
t(2).functionname = @getParabolicProfile;
t(2).logfile = '';
t(2).resultdir = '';
t(2).currentcase = [];
t(2).cases.id = 1;
t(2).cases.name = 'getParabolicProfile test';
t(2).cases.description = 'getParabolicProfile test: derive y (created on 23-Jul-2008 16:24:38)';
t(2).cases.settings.settingsfunction = @DuneErosionSettings;
t(2).cases.settings.input.vars.name = 'varargin';
t(2).cases.settings.input.vars.content{1} = 'set';
t(2).cases.settings.input.vars.content{2} = 'n_d';
t(2).cases.settings.input.vars.content{3} = 1;
t(2).cases.settings.input.vars.content{4} = 'Plus';
t(2).cases.settings.input.vars.content{5} = '-plus';
t(2).cases.run.runfunction = @McT_RunFunction;
t(2).cases.run.input.vars(1).name = 'Hsig_t';
t(2).cases.run.input.vars(1).content = 9;
t(2).cases.run.input.vars(2).name = 'Tp_t';
t(2).cases.run.input.vars(2).content = 12;
t(2).cases.run.input.vars(3).name = 'w';
t(2).cases.run.input.vars(3).content = 0.0246782;
t(2).cases.run.input.vars(4).name = 'x0';
t(2).cases.run.input.vars(4).content = 0;
t(2).cases.run.input.vars(5).name = 'x';
t(2).cases.run.input.vars(5).content = [0 16.254 32.5079 48.7619 65.0158 81.2698 97.5237 113.778 130.032 146.286 162.54 178.793 195.047 211.301 227.555 243.809 260.063 276.317 292.571 308.825 325.079]';
t(2).cases.run.result.runflag = [];
t(2).cases.run.result.vars.name = '';
t(2).cases.run.result.vars.content = [];
t(2).cases.evaluation.evaluationfunction = @getParabolicProfile_test;
t(2).cases.evaluation.input.expoutvars(1).name = 'xmax';
t(2).cases.evaluation.input.expoutvars(1).content = 325.079;
t(2).cases.evaluation.input.expoutvars(2).name = 'y';
t(2).cases.evaluation.input.expoutvars(2).content = [0 0.714567 1.29221 1.79037 2.23494 2.6402 3.01504 3.36544 3.69561 4.00872 4.30715 4.59279 4.86717 5.13152 5.38687 5.63407 5.87387 6.10688 6.33365 6.55466 6.77033]';
t(2).cases.evaluation.input.expoutvars(3).name = 'Tp_t';
t(2).cases.evaluation.input.expoutvars(3).content = 12;
t(2).cases.evaluation.result = [];
t(2).process.processfunction = '';
t(2).process.input = [];
t(2).process.result = [];
