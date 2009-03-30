function t = findCrossings_test(t)
% FINDCROSSINGS_TEST test defintion routine
%
% see also findCrossings

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
	TODO('Write custom evaluation');
	return
end

%% create t-structure
t(1).functionname = @findCrossings;
t(1).logfile = '';
t(1).resultdir = '';
t(1).currentcase = [];
t(1).cases(1).id = 1;
t(1).cases(1).name = 'findCrossings test';
t(1).cases(1).description = 'findCrossings test (created on 16-Jul-2008 13:58:33)';
t(1).cases(1).settings.settingsfunction = '';
t(1).cases(1).settings.input = [];
t(1).cases(1).run.runfunction = @McT_RunFunction;
t(1).cases(1).run.input.vars(1).name = 'x1';
t(1).cases(1).run.input.vars(1).content = [0 2]';
t(1).cases(1).run.input.vars(2).name = 'z1';
t(1).cases(1).run.input.vars(2).content = [1 1]';
t(1).cases(1).run.input.vars(3).name = 'x2';
t(1).cases(1).run.input.vars(3).content = [0 2]';
t(1).cases(1).run.input.vars(4).name = 'z2';
t(1).cases(1).run.input.vars(4).content = [0 2]';
t(1).cases(1).run.input.vars(5).name = 'flag';
t(1).cases(1).run.input.vars(5).content = 'keeporiginalgrid';
t(1).cases(1).run.result.runflag = [];
t(1).cases(1).run.result.vars.name = '';
t(1).cases(1).run.result.vars.content = [];
t(1).cases(1).evaluation.evaluationfunction = @findCrossings_test;
t(1).cases(1).evaluation.input.expoutvars(1).name = 'xcr';
t(1).cases(1).evaluation.input.expoutvars(1).content = 1;
t(1).cases(1).evaluation.input.expoutvars(2).name = 'zcr';
t(1).cases(1).evaluation.input.expoutvars(2).content = 1;
t(1).cases(1).evaluation.input.expoutvars(3).name = 'x1_new_out';
t(1).cases(1).evaluation.input.expoutvars(3).content = [0 1 2]';
t(1).cases(1).evaluation.input.expoutvars(4).name = 'z1_new_out';
t(1).cases(1).evaluation.input.expoutvars(4).content = ones(3,1);
t(1).cases(1).evaluation.input.expoutvars(5).name = 'x2_new_out';
t(1).cases(1).evaluation.input.expoutvars(5).content = [0 1 2]';
t(1).cases(1).evaluation.input.expoutvars(6).name = 'z2_new_out';
t(1).cases(1).evaluation.input.expoutvars(6).content = (0:2)';
t(1).cases(1).evaluation.result = [];
t(1).cases(2).id = 2;
t(1).cases(2).name = 'findCrossings test';
t(1).cases(2).description = 'findCrossings test (created on 16-Jul-2008 13:58:33)';
t(1).cases(2).settings.settingsfunction = '';
t(1).cases(2).settings.input = [];
t(1).cases(2).run.runfunction = @McT_RunFunction;
t(1).cases(2).run.input.vars(1).name = 'x1';
t(1).cases(2).run.input.vars(1).content = [0 2]';
t(1).cases(2).run.input.vars(2).name = 'z1';
t(1).cases(2).run.input.vars(2).content = [1 1]';
t(1).cases(2).run.input.vars(3).name = 'x2';
t(1).cases(2).run.input.vars(3).content = [0 2]';
t(1).cases(2).run.input.vars(4).name = 'z2';
t(1).cases(2).run.input.vars(4).content = [2 2]';
t(1).cases(2).run.input.vars(5).name = 'flag';
t(1).cases(2).run.input.vars(5).content = 'keeporiginalgrid';
t(1).cases(2).run.result.runflag = [];
t(1).cases(2).run.result.vars.name = '';
t(1).cases(2).run.result.vars.content = [];
t(1).cases(2).evaluation.evaluationfunction = @findCrossings_test;
t(1).cases(2).evaluation.input.expoutvars(1).name = 'xcr';
t(1).cases(2).evaluation.input.expoutvars(1).content = [];
t(1).cases(2).evaluation.input.expoutvars(2).name = 'zcr';
t(1).cases(2).evaluation.input.expoutvars(2).content = [];
t(1).cases(2).evaluation.input.expoutvars(3).name = 'x1_new_out';
t(1).cases(2).evaluation.input.expoutvars(3).content = [0 2]';
t(1).cases(2).evaluation.input.expoutvars(4).name = 'z1_new_out';
t(1).cases(2).evaluation.input.expoutvars(4).content = [1 1]';
t(1).cases(2).evaluation.input.expoutvars(5).name = 'x2_new_out';
t(1).cases(2).evaluation.input.expoutvars(5).content = [0 2]';
t(1).cases(2).evaluation.input.expoutvars(6).name = 'z2_new_out';
t(1).cases(2).evaluation.input.expoutvars(6).content = [2 2]';
t(1).cases(2).evaluation.result = [];
t(1).cases(3).id = 3;
t(1).cases(3).name = 'findCrossings test';
t(1).cases(3).description = 'findCrossings test (created on 16-Jul-2008 13:58:34)';
t(1).cases(3).settings.settingsfunction = '';
t(1).cases(3).settings.input = [];
t(1).cases(3).run.runfunction = @McT_RunFunction;
t(1).cases(3).run.input.vars(1).name = 'x1';
t(1).cases(3).run.input.vars(1).content = [0 2]';
t(1).cases(3).run.input.vars(2).name = 'z1';
t(1).cases(3).run.input.vars(2).content = [1 1]';
t(1).cases(3).run.input.vars(3).name = 'x2';
t(1).cases(3).run.input.vars(3).content = [2 4]';
t(1).cases(3).run.input.vars(4).name = 'z2';
t(1).cases(3).run.input.vars(4).content = [0 2]';
t(1).cases(3).run.input.vars(5).name = 'flag';
t(1).cases(3).run.input.vars(5).content = 'keeporiginalgrid';
t(1).cases(3).run.result.runflag = [];
t(1).cases(3).run.result.vars.name = '';
t(1).cases(3).run.result.vars.content = [];
t(1).cases(3).evaluation.evaluationfunction = @findCrossings_test;
t(1).cases(3).evaluation.input.expoutvars(1).name = 'xcr';
t(1).cases(3).evaluation.input.expoutvars(1).content = [];
t(1).cases(3).evaluation.input.expoutvars(2).name = 'zcr';
t(1).cases(3).evaluation.input.expoutvars(2).content = [];
t(1).cases(3).evaluation.input.expoutvars(3).name = 'x1_new_out';
t(1).cases(3).evaluation.input.expoutvars(3).content = [0 2]';
t(1).cases(3).evaluation.input.expoutvars(4).name = 'z1_new_out';
t(1).cases(3).evaluation.input.expoutvars(4).content = [1 1]';
t(1).cases(3).evaluation.input.expoutvars(5).name = 'x2_new_out';
t(1).cases(3).evaluation.input.expoutvars(5).content = [2 4]';
t(1).cases(3).evaluation.input.expoutvars(6).name = 'z2_new_out';
t(1).cases(3).evaluation.input.expoutvars(6).content = [0 2]';
t(1).cases(3).evaluation.result = [];
t(1).process.processfunction = '';
t(1).process.input = [];
t(1).process.result = [];
t(2).functionname = @findCrossings;
t(2).logfile = '';
t(2).resultdir = '';
t(2).currentcase = [];
t(2).cases(1).id = 1;
t(2).cases(1).name = 'findCrossings test';
t(2).cases(1).description = 'findCrossings test (created on 16-Jul-2008 13:58:34)';
t(2).cases(1).settings.settingsfunction = '';
t(2).cases(1).settings.input = [];
t(2).cases(1).run.runfunction = @McT_RunFunction;
t(2).cases(1).run.input.vars(1).name = 'x1';
t(2).cases(1).run.input.vars(1).content = [0 2]';
t(2).cases(1).run.input.vars(2).name = 'z1';
t(2).cases(1).run.input.vars(2).content = [1 1]';
t(2).cases(1).run.input.vars(3).name = 'x2';
t(2).cases(1).run.input.vars(3).content = [0 2]';
t(2).cases(1).run.input.vars(4).name = 'z2';
t(2).cases(1).run.input.vars(4).content = [0 2]';
t(2).cases(1).run.input.vars(5).name = 'flag';
t(2).cases(1).run.input.vars(5).content = 'synchronizegrids';
t(2).cases(1).run.result.runflag = [];
t(2).cases(1).run.result.vars.name = '';
t(2).cases(1).run.result.vars.content = [];
t(2).cases(1).evaluation.evaluationfunction = @findCrossings_test;
t(2).cases(1).evaluation.input.expoutvars(1).name = 'xcr';
t(2).cases(1).evaluation.input.expoutvars(1).content = 1;
t(2).cases(1).evaluation.input.expoutvars(2).name = 'zcr';
t(2).cases(1).evaluation.input.expoutvars(2).content = 1;
t(2).cases(1).evaluation.input.expoutvars(3).name = 'x1_new_out';
t(2).cases(1).evaluation.input.expoutvars(3).content = [0 1 2]';
t(2).cases(1).evaluation.input.expoutvars(4).name = 'z1_new_out';
t(2).cases(1).evaluation.input.expoutvars(4).content = ones(3,1);
t(2).cases(1).evaluation.input.expoutvars(5).name = 'x2_new_out';
t(2).cases(1).evaluation.input.expoutvars(5).content = [0 1 2]';
t(2).cases(1).evaluation.input.expoutvars(6).name = 'z2_new_out';
t(2).cases(1).evaluation.input.expoutvars(6).content = (0:2)';
t(2).cases(1).evaluation.result = [];
t(2).cases(2).id = 2;
t(2).cases(2).name = 'findCrossings test';
t(2).cases(2).description = 'findCrossings test (created on 16-Jul-2008 13:58:34)';
t(2).cases(2).settings.settingsfunction = '';
t(2).cases(2).settings.input = [];
t(2).cases(2).run.runfunction = @McT_RunFunction;
t(2).cases(2).run.input.vars(1).name = 'x1';
t(2).cases(2).run.input.vars(1).content = [0 2]';
t(2).cases(2).run.input.vars(2).name = 'z1';
t(2).cases(2).run.input.vars(2).content = [1 1]';
t(2).cases(2).run.input.vars(3).name = 'x2';
t(2).cases(2).run.input.vars(3).content = [0 2]';
t(2).cases(2).run.input.vars(4).name = 'z2';
t(2).cases(2).run.input.vars(4).content = [2 2]';
t(2).cases(2).run.input.vars(5).name = 'flag';
t(2).cases(2).run.input.vars(5).content = 'synchronizegrids';
t(2).cases(2).run.result.runflag = [];
t(2).cases(2).run.result.vars.name = '';
t(2).cases(2).run.result.vars.content = [];
t(2).cases(2).evaluation.evaluationfunction = @findCrossings_test;
t(2).cases(2).evaluation.input.expoutvars(1).name = 'xcr';
t(2).cases(2).evaluation.input.expoutvars(1).content = [];
t(2).cases(2).evaluation.input.expoutvars(2).name = 'zcr';
t(2).cases(2).evaluation.input.expoutvars(2).content = [];
t(2).cases(2).evaluation.input.expoutvars(3).name = 'x1_new_out';
t(2).cases(2).evaluation.input.expoutvars(3).content = [0 2]';
t(2).cases(2).evaluation.input.expoutvars(4).name = 'z1_new_out';
t(2).cases(2).evaluation.input.expoutvars(4).content = [1 1]';
t(2).cases(2).evaluation.input.expoutvars(5).name = 'x2_new_out';
t(2).cases(2).evaluation.input.expoutvars(5).content = [0 2]';
t(2).cases(2).evaluation.input.expoutvars(6).name = 'z2_new_out';
t(2).cases(2).evaluation.input.expoutvars(6).content = [2 2]';
t(2).cases(2).evaluation.result = [];
t(2).cases(3).id = 3;
t(2).cases(3).name = 'findCrossings test';
t(2).cases(3).description = 'findCrossings test (created on 16-Jul-2008 13:58:34)';
t(2).cases(3).settings.settingsfunction = '';
t(2).cases(3).settings.input = [];
t(2).cases(3).run.runfunction = @McT_RunFunction;
t(2).cases(3).run.input.vars(1).name = 'x1';
t(2).cases(3).run.input.vars(1).content = [0 2]';
t(2).cases(3).run.input.vars(2).name = 'z1';
t(2).cases(3).run.input.vars(2).content = [1 1]';
t(2).cases(3).run.input.vars(3).name = 'x2';
t(2).cases(3).run.input.vars(3).content = [2 4]';
t(2).cases(3).run.input.vars(4).name = 'z2';
t(2).cases(3).run.input.vars(4).content = [0 2]';
t(2).cases(3).run.input.vars(5).name = 'flag';
t(2).cases(3).run.input.vars(5).content = 'synchronizegrids';
t(2).cases(3).run.result.runflag = [];
t(2).cases(3).run.result.vars.name = '';
t(2).cases(3).run.result.vars.content = [];
t(2).cases(3).evaluation.evaluationfunction = @findCrossings_test;
t(2).cases(3).evaluation.input.expoutvars(1).name = 'xcr';
t(2).cases(3).evaluation.input.expoutvars(1).content = [];
t(2).cases(3).evaluation.input.expoutvars(2).name = 'zcr';
t(2).cases(3).evaluation.input.expoutvars(2).content = [];
t(2).cases(3).evaluation.input.expoutvars(3).name = 'x1_new_out';
t(2).cases(3).evaluation.input.expoutvars(3).content = (0:2:4)';
t(2).cases(3).evaluation.input.expoutvars(4).name = 'z1_new_out';
t(2).cases(3).evaluation.input.expoutvars(4).content = [1 1 NaN]';
t(2).cases(3).evaluation.input.expoutvars(5).name = 'x2_new_out';
t(2).cases(3).evaluation.input.expoutvars(5).content = (0:2:4)';
t(2).cases(3).evaluation.input.expoutvars(6).name = 'z2_new_out';
t(2).cases(3).evaluation.input.expoutvars(6).content = [NaN 0 2]';
t(2).cases(3).evaluation.result = [];
t(2).process.processfunction = '';
t(2).process.input = [];
t(2).process.result = [];
