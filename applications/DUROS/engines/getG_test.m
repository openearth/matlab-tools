% function t = getG_test(t)
% GETG_TEST test defintion routine
%
% see also getG

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

t.functionname = @getG;
t.logfile = '';
t.resultdir = '';
t.currentcase = [];
t.cases(1).id = 1;
t.cases(1).name = 'getG test';
t.cases(1).description = 'getG test (created on 16-Jul-2008 15:12:15)';
t.cases(1).settings.settingsfunction = '';
t.cases(1).settings.input = [];
t.cases(1).run.runfunction = @McT_RunFunction;
t.cases(1).run.input.vars(1).name = 'TargetVolume';
t.cases(1).run.input.vars(1).content = 100;
t.cases(1).run.input.vars(2).name = 'Hsig_t';
t.cases(1).run.input.vars(2).content = 9;
t.cases(1).run.input.vars(3).name = 'w';
t.cases(1).run.input.vars(3).content = 0.0246782;
t.cases(1).run.input.vars(4).name = 'Bend';
t.cases(1).run.input.vars(4).content = 1;
t.cases(1).run.result.runflag = [];
t.cases(1).run.result.vars.name = '';
t.cases(1).run.result.vars.content = [];
t.cases(1).evaluation.evaluationfunction = @getG_test;
t.cases(1).evaluation.input.expoutvars.name = 'G';
t.cases(1).evaluation.input.expoutvars.content = 0;
t.cases(1).evaluation.result = [];
t.cases(2).id = 2;
t.cases(2).name = 'getG test';
t.cases(2).description = 'getG test (created on 16-Jul-2008 15:12:15)';
t.cases(2).settings.settingsfunction = '';
t.cases(2).settings.input = [];
t.cases(2).run.runfunction = @McT_RunFunction;
t.cases(2).run.input.vars(1).name = 'TargetVolume';
t.cases(2).run.input.vars(1).content = 100;
t.cases(2).run.input.vars(2).name = 'Hsig_t';
t.cases(2).run.input.vars(2).content = 9;
t.cases(2).run.input.vars(3).name = 'w';
t.cases(2).run.input.vars(3).content = 0.0246782;
t.cases(2).run.input.vars(4).name = 'Bend';
t.cases(2).run.input.vars(4).content = 7;
t.cases(2).run.result.runflag = [];
t.cases(2).run.result.vars.name = '';
t.cases(2).run.result.vars.content = [];
t.cases(2).evaluation.evaluationfunction = @getG_test;
t.cases(2).evaluation.input.expoutvars.name = 'G';
t.cases(2).evaluation.input.expoutvars.content = 17.9745;
t.cases(2).evaluation.result = [];
t.cases(3).id = 3;
t.cases(3).name = 'getG test';
t.cases(3).description = 'getG test (created on 16-Jul-2008 15:12:15)';
t.cases(3).settings.settingsfunction = '';
t.cases(3).settings.input = [];
t.cases(3).run.runfunction = @McT_RunFunction;
t.cases(3).run.input.vars(1).name = 'TargetVolume';
t.cases(3).run.input.vars(1).content = 100;
t.cases(3).run.input.vars(2).name = 'Hsig_t';
t.cases(3).run.input.vars(2).content = 9;
t.cases(3).run.input.vars(3).name = 'w';
t.cases(3).run.input.vars(3).content = 0.0246782;
t.cases(3).run.input.vars(4).name = 'Bend';
t.cases(3).run.input.vars(4).content = 13;
t.cases(3).run.result.runflag = [];
t.cases(3).run.result.vars.name = '';
t.cases(3).run.result.vars.content = [];
t.cases(3).evaluation.evaluationfunction = @getG_test;
t.cases(3).evaluation.input.expoutvars.name = 'G';
t.cases(3).evaluation.input.expoutvars.content = 26.9618;
t.cases(3).evaluation.result = [];
t.cases(4).id = 4;
t.cases(4).name = 'getG test';
t.cases(4).description = 'getG test (created on 16-Jul-2008 15:12:15)';
t.cases(4).settings.settingsfunction = '';
t.cases(4).settings.input = [];
t.cases(4).run.runfunction = @McT_RunFunction;
t.cases(4).run.input.vars(1).name = 'TargetVolume';
t.cases(4).run.input.vars(1).content = 100;
t.cases(4).run.input.vars(2).name = 'Hsig_t';
t.cases(4).run.input.vars(2).content = 9;
t.cases(4).run.input.vars(3).name = 'w';
t.cases(4).run.input.vars(3).content = 0.0246782;
t.cases(4).run.input.vars(4).name = 'Bend';
t.cases(4).run.input.vars(4).content = 19;
t.cases(4).run.result.runflag = [];
t.cases(4).run.result.vars.name = '';
t.cases(4).run.result.vars.content = [];
t.cases(4).evaluation.evaluationfunction = @getG_test;
t.cases(4).evaluation.input.expoutvars.name = 'G';
t.cases(4).evaluation.input.expoutvars.content = 35.9491;
t.cases(4).evaluation.result = [];
t.cases(5).id = 5;
t.cases(5).name = 'getG test';
t.cases(5).description = 'getG test (created on 16-Jul-2008 15:12:15)';
t.cases(5).settings.settingsfunction = '';
t.cases(5).settings.input = [];
t.cases(5).run.runfunction = @McT_RunFunction;
t.cases(5).run.input.vars(1).name = 'TargetVolume';
t.cases(5).run.input.vars(1).content = 100;
t.cases(5).run.input.vars(2).name = 'Hsig_t';
t.cases(5).run.input.vars(2).content = 9;
t.cases(5).run.input.vars(3).name = 'w';
t.cases(5).run.input.vars(3).content = 0.0246782;
t.cases(5).run.input.vars(4).name = 'Bend';
t.cases(5).run.input.vars(4).content = 25;
t.cases(5).run.result.runflag = [];
t.cases(5).run.result.vars.name = '';
t.cases(5).run.result.vars.content = [];
t.cases(5).evaluation.evaluationfunction = @getG_test;
t.cases(5).evaluation.input.expoutvars.name = 'G';
t.cases(5).evaluation.input.expoutvars.content = [];
t.cases(5).evaluation.result = [];
t.process.processfunction = '';
t.process.input = [];
t.process.result = [];
