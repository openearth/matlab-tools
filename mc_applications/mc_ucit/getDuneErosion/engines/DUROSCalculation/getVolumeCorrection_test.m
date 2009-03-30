function t = getVolumeCorrection_test(t)
% GETVOLUMECORRECTION_TEST test defintion routine
%
% see also getVolumeCorrection

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       <author>
%
%       <email>	
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
	return
end

%% create t-structure
t.functionname = @getVolumeCorrection;
t.logfile = '';
t.resultdir = '';
t.currentcase = [];
t.cases(1).id = 1;
t.cases(1).name = 'getVolumeCorrection test';
t.cases(1).description = 'getVolumeCorrection test (created on 23-Jul-2008 08:54:22)';
t.cases(1).settings.settingsfunction = '';
t.cases(1).settings.input = [];
t.cases(1).run.runfunction = @McT_RunFunction;
t.cases(1).run.input.vars(1).name = 'x';
t.cases(1).run.input.vars(1).content = [0 0.314159 0.628319 0.942478 1.25664 1.5708 1.88496 2.19911 2.51327 2.82743 3.14159 3.41812]';
t.cases(1).run.input.vars(2).name = 'z';
t.cases(1).run.input.vars(2).content = [0 -0.025 -0.05 -0.075 -0.1 -0.125 -0.15 -0.175 -0.2 -0.225 -0.25 -0.272006]';
t.cases(1).run.input.vars(3).name = 'z2';
t.cases(1).run.input.vars(3).content = [0 0.309017 0.587785 0.809017 0.951057 1 0.951057 0.809017 0.587785 0.309017 1.22465e-016 -0.272006]';
t.cases(1).run.input.vars(4).name = 'WL';
t.cases(1).run.input.vars(4).content = 1;
t.cases(1).run.result.runflag = [];
t.cases(1).run.result.vars.name = '';
t.cases(1).run.result.vars.content = [];
t.cases(1).evaluation.evaluationfunction = '';
t.cases(1).evaluation.input.expoutvars(1).name = 'Volume';
t.cases(1).evaluation.input.expoutvars(1).content = 2.41079;
t.cases(1).evaluation.input.expoutvars(2).name = 'Volumechange';
t.cases(1).evaluation.input.expoutvars(2).content = 0;
t.cases(1).evaluation.input.expoutvars(3).name = 'CorrectionApplied';
t.cases(1).evaluation.input.expoutvars(3).content = false;
t.cases(1).evaluation.input.expoutvars(4).name = 'DuneCorrected';
t.cases(1).evaluation.input.expoutvars(4).content = false;
t.cases(1).evaluation.input.expoutvars(5).name = 'x';
t.cases(1).evaluation.input.expoutvars(5).content = [0 0.314159 0.628319 0.942478 1.25664 1.5708 1.88496 2.19911 2.51327 2.82743 3.14159 3.41812]';
t.cases(1).evaluation.input.expoutvars(6).name = 'z';
t.cases(1).evaluation.input.expoutvars(6).content = [0 -0.025 -0.05 -0.075 -0.1 -0.125 -0.15 -0.175 -0.2 -0.225 -0.25 -0.272006]';
t.cases(1).evaluation.input.expoutvars(7).name = 'z2';
t.cases(1).evaluation.input.expoutvars(7).content = [0 0.309017 0.587785 0.809017 0.951057 1 0.951057 0.809017 0.587785 0.309017 1.22465e-016 -0.272006]';
t.cases(1).evaluation.result = [];
t.cases(2).id = 1;
t.cases(2).name = 'getVolumeCorrection test';
t.cases(2).description = 'getVolumeCorrection test (created on 23-Jul-2008 08:54:22)';
t.cases(2).settings.settingsfunction = '';
t.cases(2).settings.input = [];
t.cases(2).run.runfunction = @McT_RunFunction;
t.cases(2).run.input.vars(1).name = 'x';
t.cases(2).run.input.vars(1).content = [0 0.314159 0.628319 0.942478 1.25664 1.5708 1.88496 2.19911 2.51327 2.82743 3.14159 3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
t.cases(2).run.input.vars(2).name = 'z';
t.cases(2).run.input.vars(2).content = [0 -0.025 -0.05 -0.075 -0.1 -0.125 -0.15 -0.175 -0.2 -0.225 -0.25 -0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
t.cases(2).run.input.vars(3).name = 'z2';
t.cases(2).run.input.vars(3).content = [0 0.309017 0.587785 0.809017 0.951057 1 0.951057 0.809017 0.587785 0.309017 1.22465e-016 -0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
t.cases(2).run.input.vars(4).name = 'WL';
t.cases(2).run.input.vars(4).content = 1;
t.cases(2).run.result.runflag = [];
t.cases(2).run.result.vars.name = '';
t.cases(2).run.result.vars.content = [];
t.cases(2).evaluation.evaluationfunction = '';
t.cases(2).evaluation.input.expoutvars(1).name = 'Volume';
t.cases(2).evaluation.input.expoutvars(1).content = 1.45193;
t.cases(2).evaluation.input.expoutvars(2).name = 'Volumechange';
t.cases(2).evaluation.input.expoutvars(2).content = 0;
t.cases(2).evaluation.input.expoutvars(3).name = 'CorrectionApplied';
t.cases(2).evaluation.input.expoutvars(3).content = false;
t.cases(2).evaluation.input.expoutvars(4).name = 'DuneCorrected';
t.cases(2).evaluation.input.expoutvars(4).content = false;
t.cases(2).evaluation.input.expoutvars(5).name = 'x';
t.cases(2).evaluation.input.expoutvars(5).content = [0 0.314159 0.628319 0.942478 1.25664 1.5708 1.88496 2.19911 2.51327 2.82743 3.14159 3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
t.cases(2).evaluation.input.expoutvars(6).name = 'z';
t.cases(2).evaluation.input.expoutvars(6).content = [0 -0.025 -0.05 -0.075 -0.1 -0.125 -0.15 -0.175 -0.2 -0.225 -0.25 -0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
t.cases(2).evaluation.input.expoutvars(7).name = 'z2';
t.cases(2).evaluation.input.expoutvars(7).content = [0 0.309017 0.587785 0.809017 0.951057 1 0.951057 0.809017 0.587785 0.309017 1.22465e-016 -0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
t.cases(2).evaluation.result = [];
t.cases(3).id = 1;
t.cases(3).name = 'getVolumeCorrection test';
t.cases(3).description = 'getVolumeCorrection test (created on 23-Jul-2008 08:54:22)';
t.cases(3).settings.settingsfunction = '';
t.cases(3).settings.input = [];
t.cases(3).run.runfunction = @McT_RunFunction;
t.cases(3).run.input.vars(1).name = 'x';
t.cases(3).run.input.vars(1).content = [3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
t.cases(3).run.input.vars(2).name = 'z';
t.cases(3).run.input.vars(2).content = [-0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
t.cases(3).run.input.vars(3).name = 'z2';
t.cases(3).run.input.vars(3).content = [-0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
t.cases(3).run.input.vars(4).name = 'WL';
t.cases(3).run.input.vars(4).content = -0.272006;
t.cases(3).run.result.runflag = [];
t.cases(3).run.result.vars.name = '';
t.cases(3).run.result.vars.content = [];
t.cases(3).evaluation.evaluationfunction = '';
t.cases(3).evaluation.input.expoutvars(1).name = 'Volume';
t.cases(3).evaluation.input.expoutvars(1).content = -0.958854;
t.cases(3).evaluation.input.expoutvars(2).name = 'Volumechange';
t.cases(3).evaluation.input.expoutvars(2).content = 0;
t.cases(3).evaluation.input.expoutvars(3).name = 'CorrectionApplied';
t.cases(3).evaluation.input.expoutvars(3).content = false;
t.cases(3).evaluation.input.expoutvars(4).name = 'DuneCorrected';
t.cases(3).evaluation.input.expoutvars(4).content = false;
t.cases(3).evaluation.input.expoutvars(5).name = 'x';
t.cases(3).evaluation.input.expoutvars(5).content = [3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
t.cases(3).evaluation.input.expoutvars(6).name = 'z';
t.cases(3).evaluation.input.expoutvars(6).content = [-0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
t.cases(3).evaluation.input.expoutvars(7).name = 'z2';
t.cases(3).evaluation.input.expoutvars(7).content = [-0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
t.cases(3).evaluation.result = [];
t.process.processfunction = '';
t.process.input = [];
t.process.result = [];
