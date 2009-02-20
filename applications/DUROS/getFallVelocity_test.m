function t = getFallVelocity_test(t)
%GETFALLVELOCITY_TEST  test definition for getFallVelocity
%
%   More detailed description goes here.
%
%   Syntax:
%   t = getFallVelocity_test(t)
%
%   Input:
%   t =
%
%   Output:
%   t =
%
%   Example
%   getFallVelocity_test
%
%   See also getFallVelocity

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% Created: 20 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%%
if nargout ~= 1
	% run test
	evalin('caller', ['[result t] = mc_test(''' mfilename ''');']);
	return
end

if nargin == 1
    % optional custom evaluation of test
    % evaluation 1: McT_ExactMatch
    % round t similar to one written in the test definition file
    evalstr = var2evalstr(t);
    eval(evalstr);
    % run McT_ExactMatch
    t = feval(@McT_ExactMatch, t);
    return
end

%% create t-structure
t(1).functionname = @getFallVelocity;
t(1).logfile = '';
t(1).resultdir = '';
t(1).currentcase = [];
t(1).cases(1).id = 1;
t(1).cases(1).name = 'getFallVelocity test';
t(1).cases(1).description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(1).cases(1).settings.settingsfunction = '';
t(1).cases(1).settings.input = [];
t(1).cases(1).run.runfunction = @McT_RunFunction;
t(1).cases(1).run.input.vars.name = 'D50';
t(1).cases(1).run.input.vars.content = 0.00015;
t(1).cases(1).run.result.runflag = [];
t(1).cases(1).run.result.vars.name = '';
t(1).cases(1).run.result.vars.content = [];
t(1).cases(1).evaluation.evaluationfunction = @getFallVelocity_test;
t(1).cases(1).evaluation.input.expoutvars.name = 'w';
t(1).cases(1).evaluation.input.expoutvars.content = 0.0141227;
t(1).cases(1).evaluation.result = [];
t(1).cases(2).id = 2;
t(1).cases(2).name = 'getFallVelocity test';
t(1).cases(2).description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(1).cases(2).settings.settingsfunction = '';
t(1).cases(2).settings.input = [];
t(1).cases(2).run.runfunction = @McT_RunFunction;
t(1).cases(2).run.input.vars.name = 'D50';
t(1).cases(2).run.input.vars.content = 0.000175;
t(1).cases(2).run.result.runflag = [];
t(1).cases(2).run.result.vars.name = '';
t(1).cases(2).run.result.vars.content = [];
t(1).cases(2).evaluation.evaluationfunction = @getFallVelocity_test;
t(1).cases(2).evaluation.input.expoutvars.name = 'w';
t(1).cases(2).evaluation.input.expoutvars.content = 0.0176015;
t(1).cases(2).evaluation.result = [];
t(1).cases(3).id = 3;
t(1).cases(3).name = 'getFallVelocity test';
t(1).cases(3).description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(1).cases(3).settings.settingsfunction = '';
t(1).cases(3).settings.input = [];
t(1).cases(3).run.runfunction = @McT_RunFunction;
t(1).cases(3).run.input.vars.name = 'D50';
t(1).cases(3).run.input.vars.content = 0.0002;
t(1).cases(3).run.result.runflag = [];
t(1).cases(3).run.result.vars.name = '';
t(1).cases(3).run.result.vars.content = [];
t(1).cases(3).evaluation.evaluationfunction = @getFallVelocity_test;
t(1).cases(3).evaluation.input.expoutvars.name = 'w';
t(1).cases(3).evaluation.input.expoutvars.content = 0.0211321;
t(1).cases(3).evaluation.result = [];
t(1).cases(4).id = 4;
t(1).cases(4).name = 'getFallVelocity test';
t(1).cases(4).description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(1).cases(4).settings.settingsfunction = '';
t(1).cases(4).settings.input = [];
t(1).cases(4).run.runfunction = @McT_RunFunction;
t(1).cases(4).run.input.vars.name = 'D50';
t(1).cases(4).run.input.vars.content = 0.000225;
t(1).cases(4).run.result.runflag = [];
t(1).cases(4).run.result.vars.name = '';
t(1).cases(4).run.result.vars.content = [];
t(1).cases(4).evaluation.evaluationfunction = @getFallVelocity_test;
t(1).cases(4).evaluation.input.expoutvars.name = 'w';
t(1).cases(4).evaluation.input.expoutvars.content = 0.0246782;
t(1).cases(4).evaluation.result = [];
t(1).cases(5).id = 5;
t(1).cases(5).name = 'getFallVelocity test';
t(1).cases(5).description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(1).cases(5).settings.settingsfunction = '';
t(1).cases(5).settings.input = [];
t(1).cases(5).run.runfunction = @McT_RunFunction;
t(1).cases(5).run.input.vars.name = 'D50';
t(1).cases(5).run.input.vars.content = 0.00025;
t(1).cases(5).run.result.runflag = [];
t(1).cases(5).run.result.vars.name = '';
t(1).cases(5).run.result.vars.content = [];
t(1).cases(5).evaluation.evaluationfunction = @getFallVelocity_test;
t(1).cases(5).evaluation.input.expoutvars.name = 'w';
t(1).cases(5).evaluation.input.expoutvars.content = 0.0282143;
t(1).cases(5).evaluation.result = [];
t(1).cases(6).id = 6;
t(1).cases(6).name = 'getFallVelocity test';
t(1).cases(6).description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(1).cases(6).settings.settingsfunction = '';
t(1).cases(6).settings.input = [];
t(1).cases(6).run.runfunction = @McT_RunFunction;
t(1).cases(6).run.input.vars.name = 'D50';
t(1).cases(6).run.input.vars.content = 0.000275;
t(1).cases(6).run.result.runflag = [];
t(1).cases(6).run.result.vars.name = '';
t(1).cases(6).run.result.vars.content = [];
t(1).cases(6).evaluation.evaluationfunction = @getFallVelocity_test;
t(1).cases(6).evaluation.input.expoutvars.name = 'w';
t(1).cases(6).evaluation.input.expoutvars.content = 0.0317219;
t(1).cases(6).evaluation.result = [];
t(1).cases(7).id = 7;
t(1).cases(7).name = 'getFallVelocity test';
t(1).cases(7).description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(1).cases(7).settings.settingsfunction = '';
t(1).cases(7).settings.input = [];
t(1).cases(7).run.runfunction = @McT_RunFunction;
t(1).cases(7).run.input.vars.name = 'D50';
t(1).cases(7).run.input.vars.content = 0.0003;
t(1).cases(7).run.result.runflag = [];
t(1).cases(7).run.result.vars.name = '';
t(1).cases(7).run.result.vars.content = [];
t(1).cases(7).evaluation.evaluationfunction = @getFallVelocity_test;
t(1).cases(7).evaluation.input.expoutvars.name = 'w';
t(1).cases(7).evaluation.input.expoutvars.content = 0.035188;
t(1).cases(7).evaluation.result = [];
t(1).process.processfunction = '';
t(1).process.input = [];
t(1).process.result = [];
t(2).functionname = @getFallVelocity;
t(2).logfile = '';
t(2).resultdir = '';
t(2).currentcase = [];
t(2).cases.id = 1;
t(2).cases.name = 'getFallVelocity test';
t(2).cases.description = 'getFallVelocity test (created on 20-Feb-2009 11:50:25)';
t(2).cases.settings.settingsfunction = '';
t(2).cases.settings.input = [];
t(2).cases.run.runfunction = @McT_RunFunction;
t(2).cases.run.input.vars(1).name = 'D50';
t(2).cases.run.input.vars(1).content = 0.000225;
t(2).cases.run.input.vars(2).name = 'a';
t(2).cases.run.input.vars(2).content = 0.5236;
t(2).cases.run.input.vars(3).name = 'b';
t(2).cases.run.input.vars(3).content = 2.398;
t(2).cases.run.input.vars(4).name = 'c';
t(2).cases.run.input.vars(4).content = 3.5486;
t(2).cases.run.result.runflag = [];
t(2).cases.run.result.vars.name = '';
t(2).cases.run.result.vars.content = [];
t(2).cases.evaluation.evaluationfunction = @getFallVelocity_test;
t(2).cases.evaluation.input.expoutvars.name = 'w';
t(2).cases.evaluation.input.expoutvars.content = 0.017043;
t(2).cases.evaluation.result = [];
t(2).process.processfunction = '';
t(2).process.input = [];
t(2).process.result = [];
