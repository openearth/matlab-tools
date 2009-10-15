function t = getCumVolume_test(t)
% GETCUMVOLUME_TEST test defintion routine
%
% see also getCumVolume

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
	return
end

%% create t-structure
t.functionname = @getCumVolume;
t.logfile = '';
t.resultdir = '';
t.currentcase = [];
t.cases.id = 1;
t.cases.name = 'getCumVolume test';
t.cases.description = 'getCumVolume test (created on 16-Jul-2008 14:39:35)';
t.cases.settings.settingsfunction = '';
t.cases.settings.input = [];
t.cases.run.runfunction = @McT_RunFunction;
t.cases.run.input.vars(1).name = 'x';
t.cases.run.input.vars(1).content = [0 2]';
t.cases.run.input.vars(2).name = 'z';
t.cases.run.input.vars(2).content = [1 1]';
t.cases.run.input.vars(3).name = 'z2';
t.cases.run.input.vars(3).content = [0 2]';
t.cases.run.result.runflag = [];
t.cases.run.result.vars.name = '';
t.cases.run.result.vars.content = [];
t.cases.evaluation.evaluationfunction = @getCumVolume_test;
t.cases.evaluation.input.expoutvars(1).name = 'volumes';
t.cases.evaluation.input.expoutvars(1).content = 0;
t.cases.evaluation.input.expoutvars(2).name = 'CumVolume';
t.cases.evaluation.input.expoutvars(2).content = 0;
t.cases.evaluation.result = [];
t.process.processfunction = '';
t.process.input = [];
t.process.result = [];
