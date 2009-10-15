function t = getIterationBoundaries_test(t)
% GETITERATIONBOUNDARIES_TEST test defintion routine
%
% see also getIterationBoundaries

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
	evalin('caller', '[result t] = mc_test(''getIterationBoundaries_test'');');
	return
end

if nargin == 1
	% optional custom evaluation of test
    
    % evaluation 1: McT_ExactMatch
    t.cases(t.currentcase).run.result.vars(end+1).name = 'outp';
    t.cases(t.currentcase).run.result.vars(end).content = writemessage('get');
    % round t similar to one written in the test definition file
    evalstr = var2evalstr(t);
    eval(evalstr);
    % run McT_ExactMatch
    t = feval(@McT_ExactMatch, t);
    % display messages
    disp(t.cases(t.currentcase).description)
    disp(var2evalstr(writemessage('get'), 'basevarname', ''))
	return
end

%% create t-structure
t.functionname = @getIterationBoundaries;
t.logfile = '';
t.resultdir = '';
t.currentcase = [];
t.cases(1).id = 1;
t.cases(1).name = 'getIterationBoundaries test';
t.cases(1).description = 'Standard simplified profile';
t.cases(1).settings.settingsfunction = @writemessage;
t.cases(1).settings.input.vars.name = 'code';
t.cases(1).settings.input.vars.content = 'init';
t.cases(1).run.runfunction = @McT_RunFunction;
t.cases(1).run.input.vars(1).name = 'xInitial';
t.cases(1).run.input.vars(1).content = [-250 -24.375 5.625 55.725 230.625 1950]';
t.cases(1).run.input.vars(2).name = 'zInitial';
t.cases(1).run.input.vars(2).content = [15 15 3 0 -3 -14.4625]';
t.cases(1).run.input.vars(3).name = 'xparab';
t.cases(1).run.input.vars(3).content = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
t.cases(1).run.input.vars(4).name = 'zparab';
t.cases(1).run.input.vars(4).content = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
t.cases(1).run.input.vars(5).name = 'Hsig_t';
t.cases(1).run.input.vars(5).content = 9;
t.cases(1).run.input.vars(6).name = 'Tp_t';
t.cases(1).run.input.vars(6).content = 12;
t.cases(1).run.input.vars(7).name = 'WL_t';
t.cases(1).run.input.vars(7).content = 5;
t.cases(1).run.input.vars(8).name = 'w';
t.cases(1).run.input.vars(8).content = 0.0246782;
t.cases(1).run.result.runflag = [];
t.cases(1).run.result.vars.name = '';
t.cases(1).run.result.vars.content = [];
t.cases(1).evaluation.evaluationfunction = @getIterationBoundaries_test;
t.cases(1).evaluation.input.expoutvars(1).name = 'x00min';
t.cases(1).evaluation.input.expoutvars(1).content = -240;
t.cases(1).evaluation.input.expoutvars(2).name = 'x0min';
t.cases(1).evaluation.input.expoutvars(2).content = -166.144;
t.cases(1).evaluation.input.expoutvars(3).name = 'x0max';
t.cases(1).evaluation.input.expoutvars(3).content = 0.625;
t.cases(1).evaluation.input.expoutvars(4).name = 'x0except';
t.cases(1).evaluation.input.expoutvars(4).content = [];
t.cases(1).evaluation.input.expoutvars(5).name = 'xInitial';
t.cases(1).evaluation.input.expoutvars(5).content = [-250 -24.375 0.625 5.625 55.725 230.625 351.116 1950]';
t.cases(1).evaluation.input.expoutvars(6).name = 'zInitial';
t.cases(1).evaluation.input.expoutvars(6).content = [15 15 5 3 0 -3 -3.80327 -14.4625]';
t.cases(1).evaluation.input.expoutvars(7).name = 'SeawardBoundaryofInterest';
t.cases(1).evaluation.input.expoutvars(7).content = 1950;
t.cases(1).evaluation.input.expoutvars(8).name = 'chpoints_new';
t.cases(1).evaluation.input.expoutvars(8).content = [];
t.cases(1).evaluation.input.expoutvars(9).name = 'outp';
t.cases(1).evaluation.input.expoutvars(9).content = {20 'Landward boundary x00min based on 1:1 slope from most landward profile point'
	11 'Landward boundary based on crossing of lowest point of parabolic profile with initial profile'
	14 'Seaward boundary based on crossing of highest point of parabolic profile with initial profile'};
t.cases(1).evaluation.result = [];
t.cases(2).id = 2;
t.cases(2).name = 'getIterationBoundaries test';
t.cases(2).description = 'Profile not above water level';
t.cases(2).settings.settingsfunction = @writemessage;
t.cases(2).settings.input.vars.name = 'code';
t.cases(2).settings.input.vars.content = 'init';
t.cases(2).run.runfunction = @McT_RunFunction;
t.cases(2).run.input.vars(1).name = 'xInitial';
t.cases(2).run.input.vars(1).content = [-250 1.875 5.625 55.725 230.625 1950]';
t.cases(2).run.input.vars(2).name = 'zInitial';
t.cases(2).run.input.vars(2).content = [4.5 4.5 3 0 -3 -14.4625]';
t.cases(2).run.input.vars(3).name = 'xparab';
t.cases(2).run.input.vars(3).content = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
t.cases(2).run.input.vars(4).name = 'zparab';
t.cases(2).run.input.vars(4).content = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
t.cases(2).run.input.vars(5).name = 'Hsig_t';
t.cases(2).run.input.vars(5).content = 9;
t.cases(2).run.input.vars(6).name = 'Tp_t';
t.cases(2).run.input.vars(6).content = 12;
t.cases(2).run.input.vars(7).name = 'WL_t';
t.cases(2).run.input.vars(7).content = 5;
t.cases(2).run.input.vars(8).name = 'w';
t.cases(2).run.input.vars(8).content = 0.0246782;
t.cases(2).run.result.runflag = [];
t.cases(2).run.result.vars.name = '';
t.cases(2).run.result.vars.content = [];
t.cases(2).evaluation.evaluationfunction = @getIterationBoundaries_test;
t.cases(2).evaluation.input.expoutvars(1).name = 'x00min';
t.cases(2).evaluation.input.expoutvars(1).content = [];
t.cases(2).evaluation.input.expoutvars(2).name = 'x0min';
t.cases(2).evaluation.input.expoutvars(2).content = [];
t.cases(2).evaluation.input.expoutvars(3).name = 'x0max';
t.cases(2).evaluation.input.expoutvars(3).content = [];
t.cases(2).evaluation.input.expoutvars(4).name = 'x0except';
t.cases(2).evaluation.input.expoutvars(4).content = [];
t.cases(2).evaluation.input.expoutvars(5).name = 'xInitial';
t.cases(2).evaluation.input.expoutvars(5).content = [-250 1.875 5.625 55.725 230.625 1950]';
t.cases(2).evaluation.input.expoutvars(6).name = 'zInitial';
t.cases(2).evaluation.input.expoutvars(6).content = [4.5 4.5 3 0 -3 -14.4625]';
t.cases(2).evaluation.input.expoutvars(7).name = 'SeawardBoundaryofInterest';
t.cases(2).evaluation.input.expoutvars(7).content = [];
t.cases(2).evaluation.input.expoutvars(8).name = 'chpoints_new';
t.cases(2).evaluation.input.expoutvars(8).content = [];
t.cases(2).evaluation.input.expoutvars(9).name = 'outp';
t.cases(2).evaluation.input.expoutvars(9).content = {18 'No result possible, total profile is below water level'};
t.cases(2).evaluation.result = [];
t.cases(3).id = 3;
t.cases(3).name = 'getIterationBoundaries test';
t.cases(3).description = 'Profile cropped at landward side';
t.cases(3).settings.settingsfunction = @writemessage;
t.cases(3).settings.input.vars.name = 'code';
t.cases(3).settings.input.vars.content = 'init';
t.cases(3).run.runfunction = @McT_RunFunction;
t.cases(3).run.input.vars(1).name = 'xInitial';
t.cases(3).run.input.vars(1).content = [-150 -24.375 5.625 55.725 230.625 1950]';
t.cases(3).run.input.vars(2).name = 'zInitial';
t.cases(3).run.input.vars(2).content = [15 15 3 0 -3 -14.4625]';
t.cases(3).run.input.vars(3).name = 'xparab';
t.cases(3).run.input.vars(3).content = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
t.cases(3).run.input.vars(4).name = 'zparab';
t.cases(3).run.input.vars(4).content = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
t.cases(3).run.input.vars(5).name = 'Hsig_t';
t.cases(3).run.input.vars(5).content = 9;
t.cases(3).run.input.vars(6).name = 'Tp_t';
t.cases(3).run.input.vars(6).content = 12;
t.cases(3).run.input.vars(7).name = 'WL_t';
t.cases(3).run.input.vars(7).content = 5;
t.cases(3).run.input.vars(8).name = 'w';
t.cases(3).run.input.vars(8).content = 0.0246782;
t.cases(3).run.result.runflag = [];
t.cases(3).run.result.vars.name = '';
t.cases(3).run.result.vars.content = [];
t.cases(3).evaluation.evaluationfunction = @getIterationBoundaries_test;
t.cases(3).evaluation.input.expoutvars(1).name = 'x00min';
t.cases(3).evaluation.input.expoutvars(1).content = -140;
t.cases(3).evaluation.input.expoutvars(2).name = 'x0min';
t.cases(3).evaluation.input.expoutvars(2).content = -140;
t.cases(3).evaluation.input.expoutvars(3).name = 'x0max';
t.cases(3).evaluation.input.expoutvars(3).content = 0.625;
t.cases(3).evaluation.input.expoutvars(4).name = 'x0except';
t.cases(3).evaluation.input.expoutvars(4).content = [];
t.cases(3).evaluation.input.expoutvars(5).name = 'xInitial';
t.cases(3).evaluation.input.expoutvars(5).content = [-150 -24.375 0.625 5.625 55.725 230.625 351.116 1950]';
t.cases(3).evaluation.input.expoutvars(6).name = 'zInitial';
t.cases(3).evaluation.input.expoutvars(6).content = [15 15 5 3 0 -3 -3.80327 -14.4625]';
t.cases(3).evaluation.input.expoutvars(7).name = 'SeawardBoundaryofInterest';
t.cases(3).evaluation.input.expoutvars(7).content = 1950;
t.cases(3).evaluation.input.expoutvars(8).name = 'chpoints_new';
t.cases(3).evaluation.input.expoutvars(8).content = [];
t.cases(3).evaluation.input.expoutvars(9).name = 'outp';
t.cases(3).evaluation.input.expoutvars(9).content = {20 'Landward boundary x00min based on 1:1 slope from most landward profile point'
	21 'Landward boundary based on limited data at landward side (x0min=x00min)'
	14 'Seaward boundary based on crossing of highest point of parabolic profile with initial profile'};
t.cases(3).evaluation.result = [];
t.cases(4).id = 4;
t.cases(4).name = 'getIterationBoundaries test';
t.cases(4).description = 'Channel slope';
t.cases(4).settings.settingsfunction = @writemessage;
t.cases(4).settings.input.vars.name = 'code';
t.cases(4).settings.input.vars.content = 'init';
t.cases(4).run.runfunction = @McT_RunFunction;
t.cases(4).run.input.vars(1).name = 'xInitial';
t.cases(4).run.input.vars(1).content = [-250 -24.375 5.625 55.725 290 300 400]';
t.cases(4).run.input.vars(2).name = 'zInitial';
t.cases(4).run.input.vars(2).content = [15 15 3 0 -3 -14.4625 -14.4625]';
t.cases(4).run.input.vars(3).name = 'xparab';
t.cases(4).run.input.vars(3).content = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
t.cases(4).run.input.vars(4).name = 'zparab';
t.cases(4).run.input.vars(4).content = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
t.cases(4).run.input.vars(5).name = 'Hsig_t';
t.cases(4).run.input.vars(5).content = 9;
t.cases(4).run.input.vars(6).name = 'Tp_t';
t.cases(4).run.input.vars(6).content = 12;
t.cases(4).run.input.vars(7).name = 'WL_t';
t.cases(4).run.input.vars(7).content = 5;
t.cases(4).run.input.vars(8).name = 'w';
t.cases(4).run.input.vars(8).content = 0.0246782;
t.cases(4).run.result.runflag = [];
t.cases(4).run.result.vars.name = '';
t.cases(4).run.result.vars.content = [];
t.cases(4).evaluation.evaluationfunction = @getIterationBoundaries_test;
t.cases(4).evaluation.input.expoutvars(1).name = 'x00min';
t.cases(4).evaluation.input.expoutvars(1).content = -240;
t.cases(4).evaluation.input.expoutvars(2).name = 'x0min';
t.cases(4).evaluation.input.expoutvars(2).content = -147.416;
t.cases(4).evaluation.input.expoutvars(3).name = 'x0max';
t.cases(4).evaluation.input.expoutvars(3).content = -50.4499;
t.cases(4).evaluation.input.expoutvars(4).name = 'x0except';
t.cases(4).evaluation.input.expoutvars(4).content = [];
t.cases(4).evaluation.input.expoutvars(5).name = 'xInitial';
t.cases(4).evaluation.input.expoutvars(5).content = [-250 -24.375 0.625 5.625 55.725 290 300 400]';
t.cases(4).evaluation.input.expoutvars(6).name = 'zInitial';
t.cases(4).evaluation.input.expoutvars(6).content = [15 15 5 3 0 -3 -14.4625 -14.4625]';
t.cases(4).evaluation.input.expoutvars(7).name = 'SeawardBoundaryofInterest';
t.cases(4).evaluation.input.expoutvars(7).content = 400;
t.cases(4).evaluation.input.expoutvars(8).name = 'chpoints_new';
t.cases(4).evaluation.input.expoutvars(8).content = [-50.4499 290 -3];
t.cases(4).evaluation.input.expoutvars(9).name = 'outp';
t.cases(4).evaluation.input.expoutvars(9).content = {44 'Steep points could influence the accuracy of the solution.'
	20 'Landward boundary x00min based on 1:1 slope from most landward profile point'
	12 'Landward boundary based on point of contact of parabolic profile with initial profile'
	15 'Seaward boundary based on 1:12.5 slope, i.e. non-erodible channel slope'};
t.cases(4).evaluation.result = [];
t.cases(5).id = 5;
t.cases(5).name = 'getIterationBoundaries test';
t.cases(5).description = 'Profile cropped at seaward side';
t.cases(5).settings.settingsfunction = @writemessage;
t.cases(5).settings.input.vars.name = 'code';
t.cases(5).settings.input.vars.content = 'init';
t.cases(5).run.runfunction = @McT_RunFunction;
t.cases(5).run.input.vars(1).name = 'xInitial';
t.cases(5).run.input.vars(1).content = [-250 -24.375 5.625 55.725 230.625 300]';
t.cases(5).run.input.vars(2).name = 'zInitial';
t.cases(5).run.input.vars(2).content = [15 15 3 0 -3 -3.4625]';
t.cases(5).run.input.vars(3).name = 'xparab';
t.cases(5).run.input.vars(3).content = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
t.cases(5).run.input.vars(4).name = 'zparab';
t.cases(5).run.input.vars(4).content = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
t.cases(5).run.input.vars(5).name = 'Hsig_t';
t.cases(5).run.input.vars(5).content = 9;
t.cases(5).run.input.vars(6).name = 'Tp_t';
t.cases(5).run.input.vars(6).content = 12;
t.cases(5).run.input.vars(7).name = 'WL_t';
t.cases(5).run.input.vars(7).content = 5;
t.cases(5).run.input.vars(8).name = 'w';
t.cases(5).run.input.vars(8).content = 0.0246782;
t.cases(5).run.result.runflag = [];
t.cases(5).run.result.vars.name = '';
t.cases(5).run.result.vars.content = [];
t.cases(5).evaluation.evaluationfunction = @getIterationBoundaries_test;
t.cases(5).evaluation.input.expoutvars(1).name = 'x00min';
t.cases(5).evaluation.input.expoutvars(1).content = -240;
t.cases(5).evaluation.input.expoutvars(2).name = 'x0min';
t.cases(5).evaluation.input.expoutvars(2).content = -166.144;
t.cases(5).evaluation.input.expoutvars(3).name = 'x0max';
t.cases(5).evaluation.input.expoutvars(3).content = -46.2311;
t.cases(5).evaluation.input.expoutvars(4).name = 'x0except';
t.cases(5).evaluation.input.expoutvars(4).content = [];
t.cases(5).evaluation.input.expoutvars(5).name = 'xInitial';
t.cases(5).evaluation.input.expoutvars(5).content = [-250 -24.375 0.625 5.625 55.725 230.625 300]';
t.cases(5).evaluation.input.expoutvars(6).name = 'zInitial';
t.cases(5).evaluation.input.expoutvars(6).content = [15 15 5 3 0 -3 -3.4625]';
t.cases(5).evaluation.input.expoutvars(7).name = 'SeawardBoundaryofInterest';
t.cases(5).evaluation.input.expoutvars(7).content = 300;
t.cases(5).evaluation.input.expoutvars(8).name = 'chpoints_new';
t.cases(5).evaluation.input.expoutvars(8).content = [];
t.cases(5).evaluation.input.expoutvars(9).name = 'outp';
t.cases(5).evaluation.input.expoutvars(9).content = {20 'Landward boundary x00min based on 1:1 slope from most landward profile point'
	11 'Landward boundary based on crossing of lowest point of parabolic profile with initial profile'
	16 'Seaward boundary based on the lack of data at seaward side'};
t.cases(5).evaluation.result = [];
t.cases(6).id = 6;
t.cases(6).name = 'getIterationBoundaries test';
t.cases(6).description = 'Profile in which landward boundary depends on point of contact';
t.cases(6).settings.settingsfunction = @writemessage;
t.cases(6).settings.input.vars.name = 'code';
t.cases(6).settings.input.vars.content = 'init';
t.cases(6).run.runfunction = @McT_RunFunction;
t.cases(6).run.input.vars(1).name = 'xInitial';
t.cases(6).run.input.vars(1).content = [-250 -24.375 0.625 5.625 55.725 75 230.625 351.116 1950]';
t.cases(6).run.input.vars(2).name = 'zInitial';
t.cases(6).run.input.vars(2).content = [15 15 5 3 0 -1 -3 -3.80327 -14.4625]';
t.cases(6).run.input.vars(3).name = 'xparab';
t.cases(6).run.input.vars(3).content = [0 5.625 22.325 39.025 55.725 71.625 87.525 103.425 119.325 135.225 151.125 167.025 182.925 198.825 214.725 230.625 246.367 262.11 277.852 293.594 309.337 325.079]';
t.cases(6).run.input.vars(4).name = 'zparab';
t.cases(6).run.input.vars(4).content = [5 4.73071 4.05787 3.50034 3.01362 2.59612 2.21232 1.85517 1.51979 1.20262 0.900995 0.61282 0.336445 0.070529 -0.186033 -0.434162 -0.672292 -0.903569 -1.12855 -1.34773 -1.56153 -1.77033]';
t.cases(6).run.input.vars(5).name = 'Hsig_t';
t.cases(6).run.input.vars(5).content = 9;
t.cases(6).run.input.vars(6).name = 'Tp_t';
t.cases(6).run.input.vars(6).content = 12;
t.cases(6).run.input.vars(7).name = 'WL_t';
t.cases(6).run.input.vars(7).content = 5;
t.cases(6).run.input.vars(8).name = 'w';
t.cases(6).run.input.vars(8).content = 0.0246782;
t.cases(6).run.result.runflag = [];
t.cases(6).run.result.vars.name = '';
t.cases(6).run.result.vars.content = [];
t.cases(6).evaluation.evaluationfunction = @getIterationBoundaries_test;
t.cases(6).evaluation.input.expoutvars(1).name = 'x00min';
t.cases(6).evaluation.input.expoutvars(1).content = -240;
t.cases(6).evaluation.input.expoutvars(2).name = 'x0min';
t.cases(6).evaluation.input.expoutvars(2).content = -193.805;
t.cases(6).evaluation.input.expoutvars(3).name = 'x0max';
t.cases(6).evaluation.input.expoutvars(3).content = 0.625;
t.cases(6).evaluation.input.expoutvars(4).name = 'x0except';
t.cases(6).evaluation.input.expoutvars(4).content = [];
t.cases(6).evaluation.input.expoutvars(5).name = 'xInitial';
t.cases(6).evaluation.input.expoutvars(5).content = [-250 -24.375 0.625 5.625 55.725 75 230.625 351.116 351.116 1950]';
t.cases(6).evaluation.input.expoutvars(6).name = 'zInitial';
t.cases(6).evaluation.input.expoutvars(6).content = [15 15 5 3 0 -1 -3 -3.80327 -3.80327 -14.4625]';
t.cases(6).evaluation.input.expoutvars(7).name = 'SeawardBoundaryofInterest';
t.cases(6).evaluation.input.expoutvars(7).content = 1950;
t.cases(6).evaluation.input.expoutvars(8).name = 'chpoints_new';
t.cases(6).evaluation.input.expoutvars(8).content = [];
t.cases(6).evaluation.input.expoutvars(9).name = 'outp';
t.cases(6).evaluation.input.expoutvars(9).content = {20 'Landward boundary x00min based on 1:1 slope from most landward profile point'
	12 'Landward boundary based on point of contact of parabolic profile with initial profile'
	14 'Seaward boundary based on crossing of highest point of parabolic profile with initial profile'};
t.cases(6).evaluation.result = [];
t.process.processfunction = '';
t.process.input = [];
t.process.result = [];
