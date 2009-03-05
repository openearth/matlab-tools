function t = roundoff_test(t)
%ROUNDOFF_TEST test defintion routine
%
% see also roundoff

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
	return
end

%% create t-structure
t.functionname = @roundoff;
t.logfile = '';
t.resultdir = '';
t.currentcase = [];
t.cases(1).id = 1;
t.cases(1).name = 'roundoff test';
t.cases(1).description = 'round pi at multiples of 10 (mode = normal)';
t.cases(1).settings.settingsfunction = '';
t.cases(1).settings.input = [];
t.cases(1).run.runfunction = @McT_RunFunction;
t.cases(1).run.input.vars(1).name = 'X';
t.cases(1).run.input.vars(1).content = 3.14159;
t.cases(1).run.input.vars(2).name = 'n';
t.cases(1).run.input.vars(2).content = -1;
t.cases(1).run.result.runflag = [];
t.cases(1).run.result.vars.name = '';
t.cases(1).run.result.vars.content = [];
t.cases(1).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(1).evaluation.input.expoutvars.name = 'Xround';
t.cases(1).evaluation.input.expoutvars.content = 0;
t.cases(1).evaluation.result = [];
t.cases(2).id = 2;
t.cases(2).name = 'roundoff test';
t.cases(2).description = 'round pi at 0 decimal digit(s) (mode = normal)';
t.cases(2).settings.settingsfunction = '';
t.cases(2).settings.input = [];
t.cases(2).run.runfunction = @McT_RunFunction;
t.cases(2).run.input.vars(1).name = 'X';
t.cases(2).run.input.vars(1).content = 3.14159;
t.cases(2).run.input.vars(2).name = 'n';
t.cases(2).run.input.vars(2).content = 0;
t.cases(2).run.result.runflag = [];
t.cases(2).run.result.vars.name = '';
t.cases(2).run.result.vars.content = [];
t.cases(2).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(2).evaluation.input.expoutvars.name = 'Xround';
t.cases(2).evaluation.input.expoutvars.content = 3;
t.cases(2).evaluation.result = [];
t.cases(3).id = 3;
t.cases(3).name = 'roundoff test';
t.cases(3).description = 'round pi at 1 decimal digit(s) (mode = normal)';
t.cases(3).settings.settingsfunction = '';
t.cases(3).settings.input = [];
t.cases(3).run.runfunction = @McT_RunFunction;
t.cases(3).run.input.vars(1).name = 'X';
t.cases(3).run.input.vars(1).content = 3.14159;
t.cases(3).run.input.vars(2).name = 'n';
t.cases(3).run.input.vars(2).content = 1;
t.cases(3).run.result.runflag = [];
t.cases(3).run.result.vars.name = '';
t.cases(3).run.result.vars.content = [];
t.cases(3).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(3).evaluation.input.expoutvars.name = 'Xround';
t.cases(3).evaluation.input.expoutvars.content = 3.1;
t.cases(3).evaluation.result = [];
t.cases(4).id = 4;
t.cases(4).name = 'roundoff test';
t.cases(4).description = 'round pi at 2 decimal digit(s) (mode = normal)';
t.cases(4).settings.settingsfunction = '';
t.cases(4).settings.input = [];
t.cases(4).run.runfunction = @McT_RunFunction;
t.cases(4).run.input.vars(1).name = 'X';
t.cases(4).run.input.vars(1).content = 3.14159;
t.cases(4).run.input.vars(2).name = 'n';
t.cases(4).run.input.vars(2).content = 2;
t.cases(4).run.result.runflag = [];
t.cases(4).run.result.vars.name = '';
t.cases(4).run.result.vars.content = [];
t.cases(4).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(4).evaluation.input.expoutvars.name = 'Xround';
t.cases(4).evaluation.input.expoutvars.content = 3.14;
t.cases(4).evaluation.result = [];
t.cases(5).id = 5;
t.cases(5).name = 'roundoff test';
t.cases(5).description = 'round pi at 3 decimal digit(s) (mode = normal)';
t.cases(5).settings.settingsfunction = '';
t.cases(5).settings.input = [];
t.cases(5).run.runfunction = @McT_RunFunction;
t.cases(5).run.input.vars(1).name = 'X';
t.cases(5).run.input.vars(1).content = 3.14159;
t.cases(5).run.input.vars(2).name = 'n';
t.cases(5).run.input.vars(2).content = 3;
t.cases(5).run.result.runflag = [];
t.cases(5).run.result.vars.name = '';
t.cases(5).run.result.vars.content = [];
t.cases(5).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(5).evaluation.input.expoutvars.name = 'Xround';
t.cases(5).evaluation.input.expoutvars.content = 3.142;
t.cases(5).evaluation.result = [];
t.cases(6).id = 6;
t.cases(6).name = 'roundoff test';
t.cases(6).description = 'round pi at 4 decimal digit(s) (mode = normal)';
t.cases(6).settings.settingsfunction = '';
t.cases(6).settings.input = [];
t.cases(6).run.runfunction = @McT_RunFunction;
t.cases(6).run.input.vars(1).name = 'X';
t.cases(6).run.input.vars(1).content = 3.14159;
t.cases(6).run.input.vars(2).name = 'n';
t.cases(6).run.input.vars(2).content = 4;
t.cases(6).run.result.runflag = [];
t.cases(6).run.result.vars.name = '';
t.cases(6).run.result.vars.content = [];
t.cases(6).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(6).evaluation.input.expoutvars.name = 'Xround';
t.cases(6).evaluation.input.expoutvars.content = 3.1416;
t.cases(6).evaluation.result = [];
t.cases(7).id = 7;
t.cases(7).name = 'roundoff test';
t.cases(7).description = 'round pi at 5 decimal digit(s) (mode = normal)';
t.cases(7).settings.settingsfunction = '';
t.cases(7).settings.input = [];
t.cases(7).run.runfunction = @McT_RunFunction;
t.cases(7).run.input.vars(1).name = 'X';
t.cases(7).run.input.vars(1).content = 3.14159;
t.cases(7).run.input.vars(2).name = 'n';
t.cases(7).run.input.vars(2).content = 5;
t.cases(7).run.result.runflag = [];
t.cases(7).run.result.vars.name = '';
t.cases(7).run.result.vars.content = [];
t.cases(7).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(7).evaluation.input.expoutvars.name = 'Xround';
t.cases(7).evaluation.input.expoutvars.content = 3.14159;
t.cases(7).evaluation.result = [];
t.cases(8).id = 8;
t.cases(8).name = 'roundoff test';
t.cases(8).description = 'round pi at multiples of 10 (mode = floor)';
t.cases(8).settings.settingsfunction = '';
t.cases(8).settings.input = [];
t.cases(8).run.runfunction = @McT_RunFunction;
t.cases(8).run.input.vars(1).name = 'X';
t.cases(8).run.input.vars(1).content = 3.14159;
t.cases(8).run.input.vars(2).name = 'n';
t.cases(8).run.input.vars(2).content = -1;
t.cases(8).run.input.vars(3).name = 'varargin';
t.cases(8).run.input.vars(3).content{1} = 'floor';
t.cases(8).run.result.runflag = [];
t.cases(8).run.result.vars.name = '';
t.cases(8).run.result.vars.content = [];
t.cases(8).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(8).evaluation.input.expoutvars.name = 'Xround';
t.cases(8).evaluation.input.expoutvars.content = 0;
t.cases(8).evaluation.result = [];
t.cases(9).id = 9;
t.cases(9).name = 'roundoff test';
t.cases(9).description = 'round pi at 0 decimal digit(s) (mode = floor)';
t.cases(9).settings.settingsfunction = '';
t.cases(9).settings.input = [];
t.cases(9).run.runfunction = @McT_RunFunction;
t.cases(9).run.input.vars(1).name = 'X';
t.cases(9).run.input.vars(1).content = 3.14159;
t.cases(9).run.input.vars(2).name = 'n';
t.cases(9).run.input.vars(2).content = 0;
t.cases(9).run.input.vars(3).name = 'varargin';
t.cases(9).run.input.vars(3).content{1} = 'floor';
t.cases(9).run.result.runflag = [];
t.cases(9).run.result.vars.name = '';
t.cases(9).run.result.vars.content = [];
t.cases(9).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(9).evaluation.input.expoutvars.name = 'Xround';
t.cases(9).evaluation.input.expoutvars.content = 3;
t.cases(9).evaluation.result = [];
t.cases(10).id = 10;
t.cases(10).name = 'roundoff test';
t.cases(10).description = 'round pi at 1 decimal digit(s) (mode = floor)';
t.cases(10).settings.settingsfunction = '';
t.cases(10).settings.input = [];
t.cases(10).run.runfunction = @McT_RunFunction;
t.cases(10).run.input.vars(1).name = 'X';
t.cases(10).run.input.vars(1).content = 3.14159;
t.cases(10).run.input.vars(2).name = 'n';
t.cases(10).run.input.vars(2).content = 1;
t.cases(10).run.input.vars(3).name = 'varargin';
t.cases(10).run.input.vars(3).content{1} = 'floor';
t.cases(10).run.result.runflag = [];
t.cases(10).run.result.vars.name = '';
t.cases(10).run.result.vars.content = [];
t.cases(10).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(10).evaluation.input.expoutvars.name = 'Xround';
t.cases(10).evaluation.input.expoutvars.content = 3.1;
t.cases(10).evaluation.result = [];
t.cases(11).id = 11;
t.cases(11).name = 'roundoff test';
t.cases(11).description = 'round pi at 2 decimal digit(s) (mode = floor)';
t.cases(11).settings.settingsfunction = '';
t.cases(11).settings.input = [];
t.cases(11).run.runfunction = @McT_RunFunction;
t.cases(11).run.input.vars(1).name = 'X';
t.cases(11).run.input.vars(1).content = 3.14159;
t.cases(11).run.input.vars(2).name = 'n';
t.cases(11).run.input.vars(2).content = 2;
t.cases(11).run.input.vars(3).name = 'varargin';
t.cases(11).run.input.vars(3).content{1} = 'floor';
t.cases(11).run.result.runflag = [];
t.cases(11).run.result.vars.name = '';
t.cases(11).run.result.vars.content = [];
t.cases(11).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(11).evaluation.input.expoutvars.name = 'Xround';
t.cases(11).evaluation.input.expoutvars.content = 3.14;
t.cases(11).evaluation.result = [];
t.cases(12).id = 12;
t.cases(12).name = 'roundoff test';
t.cases(12).description = 'round pi at 3 decimal digit(s) (mode = floor)';
t.cases(12).settings.settingsfunction = '';
t.cases(12).settings.input = [];
t.cases(12).run.runfunction = @McT_RunFunction;
t.cases(12).run.input.vars(1).name = 'X';
t.cases(12).run.input.vars(1).content = 3.14159;
t.cases(12).run.input.vars(2).name = 'n';
t.cases(12).run.input.vars(2).content = 3;
t.cases(12).run.input.vars(3).name = 'varargin';
t.cases(12).run.input.vars(3).content{1} = 'floor';
t.cases(12).run.result.runflag = [];
t.cases(12).run.result.vars.name = '';
t.cases(12).run.result.vars.content = [];
t.cases(12).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(12).evaluation.input.expoutvars.name = 'Xround';
t.cases(12).evaluation.input.expoutvars.content = 3.141;
t.cases(12).evaluation.result = [];
t.cases(13).id = 13;
t.cases(13).name = 'roundoff test';
t.cases(13).description = 'round pi at 4 decimal digit(s) (mode = floor)';
t.cases(13).settings.settingsfunction = '';
t.cases(13).settings.input = [];
t.cases(13).run.runfunction = @McT_RunFunction;
t.cases(13).run.input.vars(1).name = 'X';
t.cases(13).run.input.vars(1).content = 3.14159;
t.cases(13).run.input.vars(2).name = 'n';
t.cases(13).run.input.vars(2).content = 4;
t.cases(13).run.input.vars(3).name = 'varargin';
t.cases(13).run.input.vars(3).content{1} = 'floor';
t.cases(13).run.result.runflag = [];
t.cases(13).run.result.vars.name = '';
t.cases(13).run.result.vars.content = [];
t.cases(13).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(13).evaluation.input.expoutvars.name = 'Xround';
t.cases(13).evaluation.input.expoutvars.content = 3.1415;
t.cases(13).evaluation.result = [];
t.cases(14).id = 14;
t.cases(14).name = 'roundoff test';
t.cases(14).description = 'round pi at 5 decimal digit(s) (mode = floor)';
t.cases(14).settings.settingsfunction = '';
t.cases(14).settings.input = [];
t.cases(14).run.runfunction = @McT_RunFunction;
t.cases(14).run.input.vars(1).name = 'X';
t.cases(14).run.input.vars(1).content = 3.14159;
t.cases(14).run.input.vars(2).name = 'n';
t.cases(14).run.input.vars(2).content = 5;
t.cases(14).run.input.vars(3).name = 'varargin';
t.cases(14).run.input.vars(3).content{1} = 'floor';
t.cases(14).run.result.runflag = [];
t.cases(14).run.result.vars.name = '';
t.cases(14).run.result.vars.content = [];
t.cases(14).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(14).evaluation.input.expoutvars.name = 'Xround';
t.cases(14).evaluation.input.expoutvars.content = 3.14159;
t.cases(14).evaluation.result = [];
t.cases(15).id = 15;
t.cases(15).name = 'roundoff test';
t.cases(15).description = 'round pi at multiples of 10 (mode = ceil)';
t.cases(15).settings.settingsfunction = '';
t.cases(15).settings.input = [];
t.cases(15).run.runfunction = @McT_RunFunction;
t.cases(15).run.input.vars(1).name = 'X';
t.cases(15).run.input.vars(1).content = 3.14159;
t.cases(15).run.input.vars(2).name = 'n';
t.cases(15).run.input.vars(2).content = -1;
t.cases(15).run.input.vars(3).name = 'varargin';
t.cases(15).run.input.vars(3).content{1} = 'ceil';
t.cases(15).run.result.runflag = [];
t.cases(15).run.result.vars.name = '';
t.cases(15).run.result.vars.content = [];
t.cases(15).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(15).evaluation.input.expoutvars.name = 'Xround';
t.cases(15).evaluation.input.expoutvars.content = 10;
t.cases(15).evaluation.result = [];
t.cases(16).id = 16;
t.cases(16).name = 'roundoff test';
t.cases(16).description = 'round pi at 0 decimal digit(s) (mode = ceil)';
t.cases(16).settings.settingsfunction = '';
t.cases(16).settings.input = [];
t.cases(16).run.runfunction = @McT_RunFunction;
t.cases(16).run.input.vars(1).name = 'X';
t.cases(16).run.input.vars(1).content = 3.14159;
t.cases(16).run.input.vars(2).name = 'n';
t.cases(16).run.input.vars(2).content = 0;
t.cases(16).run.input.vars(3).name = 'varargin';
t.cases(16).run.input.vars(3).content{1} = 'ceil';
t.cases(16).run.result.runflag = [];
t.cases(16).run.result.vars.name = '';
t.cases(16).run.result.vars.content = [];
t.cases(16).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(16).evaluation.input.expoutvars.name = 'Xround';
t.cases(16).evaluation.input.expoutvars.content = 4;
t.cases(16).evaluation.result = [];
t.cases(17).id = 17;
t.cases(17).name = 'roundoff test';
t.cases(17).description = 'round pi at 1 decimal digit(s) (mode = ceil)';
t.cases(17).settings.settingsfunction = '';
t.cases(17).settings.input = [];
t.cases(17).run.runfunction = @McT_RunFunction;
t.cases(17).run.input.vars(1).name = 'X';
t.cases(17).run.input.vars(1).content = 3.14159;
t.cases(17).run.input.vars(2).name = 'n';
t.cases(17).run.input.vars(2).content = 1;
t.cases(17).run.input.vars(3).name = 'varargin';
t.cases(17).run.input.vars(3).content{1} = 'ceil';
t.cases(17).run.result.runflag = [];
t.cases(17).run.result.vars.name = '';
t.cases(17).run.result.vars.content = [];
t.cases(17).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(17).evaluation.input.expoutvars.name = 'Xround';
t.cases(17).evaluation.input.expoutvars.content = 3.2;
t.cases(17).evaluation.result = [];
t.cases(18).id = 18;
t.cases(18).name = 'roundoff test';
t.cases(18).description = 'round pi at 2 decimal digit(s) (mode = ceil)';
t.cases(18).settings.settingsfunction = '';
t.cases(18).settings.input = [];
t.cases(18).run.runfunction = @McT_RunFunction;
t.cases(18).run.input.vars(1).name = 'X';
t.cases(18).run.input.vars(1).content = 3.14159;
t.cases(18).run.input.vars(2).name = 'n';
t.cases(18).run.input.vars(2).content = 2;
t.cases(18).run.input.vars(3).name = 'varargin';
t.cases(18).run.input.vars(3).content{1} = 'ceil';
t.cases(18).run.result.runflag = [];
t.cases(18).run.result.vars.name = '';
t.cases(18).run.result.vars.content = [];
t.cases(18).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(18).evaluation.input.expoutvars.name = 'Xround';
t.cases(18).evaluation.input.expoutvars.content = 3.15;
t.cases(18).evaluation.result = [];
t.cases(19).id = 19;
t.cases(19).name = 'roundoff test';
t.cases(19).description = 'round pi at 3 decimal digit(s) (mode = ceil)';
t.cases(19).settings.settingsfunction = '';
t.cases(19).settings.input = [];
t.cases(19).run.runfunction = @McT_RunFunction;
t.cases(19).run.input.vars(1).name = 'X';
t.cases(19).run.input.vars(1).content = 3.14159;
t.cases(19).run.input.vars(2).name = 'n';
t.cases(19).run.input.vars(2).content = 3;
t.cases(19).run.input.vars(3).name = 'varargin';
t.cases(19).run.input.vars(3).content{1} = 'ceil';
t.cases(19).run.result.runflag = [];
t.cases(19).run.result.vars.name = '';
t.cases(19).run.result.vars.content = [];
t.cases(19).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(19).evaluation.input.expoutvars.name = 'Xround';
t.cases(19).evaluation.input.expoutvars.content = 3.142;
t.cases(19).evaluation.result = [];
t.cases(20).id = 20;
t.cases(20).name = 'roundoff test';
t.cases(20).description = 'round pi at 4 decimal digit(s) (mode = ceil)';
t.cases(20).settings.settingsfunction = '';
t.cases(20).settings.input = [];
t.cases(20).run.runfunction = @McT_RunFunction;
t.cases(20).run.input.vars(1).name = 'X';
t.cases(20).run.input.vars(1).content = 3.14159;
t.cases(20).run.input.vars(2).name = 'n';
t.cases(20).run.input.vars(2).content = 4;
t.cases(20).run.input.vars(3).name = 'varargin';
t.cases(20).run.input.vars(3).content{1} = 'ceil';
t.cases(20).run.result.runflag = [];
t.cases(20).run.result.vars.name = '';
t.cases(20).run.result.vars.content = [];
t.cases(20).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(20).evaluation.input.expoutvars.name = 'Xround';
t.cases(20).evaluation.input.expoutvars.content = 3.1416;
t.cases(20).evaluation.result = [];
t.cases(21).id = 21;
t.cases(21).name = 'roundoff test';
t.cases(21).description = 'round pi at 5 decimal digit(s) (mode = ceil)';
t.cases(21).settings.settingsfunction = '';
t.cases(21).settings.input = [];
t.cases(21).run.runfunction = @McT_RunFunction;
t.cases(21).run.input.vars(1).name = 'X';
t.cases(21).run.input.vars(1).content = 3.14159;
t.cases(21).run.input.vars(2).name = 'n';
t.cases(21).run.input.vars(2).content = 5;
t.cases(21).run.input.vars(3).name = 'varargin';
t.cases(21).run.input.vars(3).content{1} = 'ceil';
t.cases(21).run.result.runflag = [];
t.cases(21).run.result.vars.name = '';
t.cases(21).run.result.vars.content = [];
t.cases(21).evaluation.evaluationfunction = @McT_ExactMatch;
t.cases(21).evaluation.input.expoutvars.name = 'Xround';
t.cases(21).evaluation.input.expoutvars.content = 3.14159;
t.cases(21).evaluation.result = [];
t.process.processfunction = '';
t.process.input = [];
t.process.result = [];
