function t = addXvaluesExactCrossings_test(t)
% ADDXVALUESEXACTCROSSINGS_TEST test defintion routine
%
% see also addXvaluesExactCrossings

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
    % evaluation 1: McT_ExactMatch
    % round t similar to one written in the test definition file
    evalstr = var2evalstr(t);
    eval(evalstr);
    % run McT_ExactMatch
    t = feval(@McT_ExactMatch, t);
    
    % evaluation 2: plot the input and results
    % prepare variables
    x_new = t.cases(t.currentcase).run.input.vars(1).content;
    z1_new = t.cases(t.currentcase).run.input.vars(2).content;
    z2_new = t.cases(t.currentcase).run.input.vars(3).content;
    x2add = t.cases(t.currentcase).run.result.vars(1).content;
    
    % find/create figure
    h = findobj('Tag', mfilename); % find figure with the mfilename in the Tag
    if isempty(h)
        % create figure with the mfilename in the Tag
        h = figure(...
            'Tag', mfilename,...
            'Name', mfilename);
    end
    
    % plot, create legend and set axis limits and labels
    subplot(2, 2, t.currentcase, 'Parent', h);
    set(gca,...
        'XLim', [0 4],...
        'YLim', [0 3])
    hold on
    plot(x_new, z1_new, '-ob',...
        'DisplayName', 'line 1')
    plot(x_new, z2_new, '-.o',...
        'Color', [0 .5 0],...
        'DisplayName', 'line 2')
    plot(x2add, zeros(size(x2add)), '*r',...
        'DisplayName', 'x2add') %added x-values (if available), plotted on x-axis
    hold off
    legend(gca, 'toggle');
    
    title(sprintf('Case %i', t.currentcase))
    xlabel('x')
    ylabel('z')
    return
end

%% create t-structure
t.functionname = @addXvaluesExactCrossings;
t.logfile = '';
t.resultdir = '';
t.currentcase = [];
t.cases(1).id = 1;
t.cases(1).name = 'addXvaluesExactCrossings test';
t.cases(1).description = 'addXvaluesExactCrossings test (created on 16-Jul-2008 12:05:19)';
t.cases(1).settings.settingsfunction = '';
t.cases(1).settings.input = [];
t.cases(1).run.runfunction = @McT_RunFunction;
t.cases(1).run.input.vars(1).name = 'x_new';
t.cases(1).run.input.vars(1).content = [0 2]';
t.cases(1).run.input.vars(2).name = 'z1_new';
t.cases(1).run.input.vars(2).content = [1 1]';
t.cases(1).run.input.vars(3).name = 'z2_new';
t.cases(1).run.input.vars(3).content = [0 2]';
t.cases(1).run.result.runflag = [];
t.cases(1).run.result.vars.name = '';
t.cases(1).run.result.vars.content = [];
t.cases(1).evaluation.evaluationfunction = @addXvaluesExactCrossings_test;
t.cases(1).evaluation.input.expoutvars.name = 'x2add';
t.cases(1).evaluation.input.expoutvars.content = 1;
t.cases(1).evaluation.result = [];
t.cases(2).id = 2;
t.cases(2).name = 'addXvaluesExactCrossings test';
t.cases(2).description = 'addXvaluesExactCrossings test (created on 16-Jul-2008 12:05:19)';
t.cases(2).settings.settingsfunction = '';
t.cases(2).settings.input = [];
t.cases(2).run.runfunction = @McT_RunFunction;
t.cases(2).run.input.vars(1).name = 'x_new';
t.cases(2).run.input.vars(1).content = [0 2]';
t.cases(2).run.input.vars(2).name = 'z1_new';
t.cases(2).run.input.vars(2).content = [1 1]';
t.cases(2).run.input.vars(3).name = 'z2_new';
t.cases(2).run.input.vars(3).content = [2 2]';
t.cases(2).run.result.runflag = [];
t.cases(2).run.result.vars.name = '';
t.cases(2).run.result.vars.content = [];
t.cases(2).evaluation.evaluationfunction = @addXvaluesExactCrossings_test;
t.cases(2).evaluation.input.expoutvars.name = 'x2add';
t.cases(2).evaluation.input.expoutvars.content = [];
t.cases(2).evaluation.result = [];
t.cases(3).id = 3;
t.cases(3).name = 'addXvaluesExactCrossings test';
t.cases(3).description = 'addXvaluesExactCrossings test (created on 16-Jul-2008 12:05:19)';
t.cases(3).settings.settingsfunction = '';
t.cases(3).settings.input = [];
t.cases(3).run.runfunction = @McT_RunFunction;
t.cases(3).run.input.vars(1).name = 'x_new';
t.cases(3).run.input.vars(1).content = (0:2:4)';
t.cases(3).run.input.vars(2).name = 'z1_new';
t.cases(3).run.input.vars(2).content = [1 1 NaN]';
t.cases(3).run.input.vars(3).name = 'z2_new';
t.cases(3).run.input.vars(3).content = [NaN 0 2]';
t.cases(3).run.result.runflag = [];
t.cases(3).run.result.vars.name = '';
t.cases(3).run.result.vars.content = [];
t.cases(3).evaluation.evaluationfunction = @addXvaluesExactCrossings_test;
t.cases(3).evaluation.input.expoutvars.name = 'x2add';
t.cases(3).evaluation.input.expoutvars.content = [];
t.cases(3).evaluation.result = [];
t.process.processfunction = '';
t.process.input = [];
t.process.result = [];
