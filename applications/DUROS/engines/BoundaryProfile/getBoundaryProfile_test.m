function t = getBoundaryProfile_test(t)
% GETBOUNDARYPROFILE_TEST test defintion routine
%
% see also getBoundaryProfile

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
if nargin == 1
	% optional custom evaluation of test
    % evaluation 1: McT_ExactMatch
    % round t similar to the one written in the test definition file
    evalstr = var2evalstr(t);
    eval(evalstr);
    % run McT_ExactMatch
    t = feval(@McT_ExactMatch, t);
    
    % evaluation 2: plot boundary profile
    % prepare variables
    xActive = t.cases(t.currentcase).run.result.vars.content.xActive;
    zActive = t.cases(t.currentcase).run.result.vars.content.zActive;
    z2Active = t.cases(t.currentcase).run.result.vars.content.z2Active;
    legendtext = {'Boundary profile' 'Water level'};
    % find/create figure
    h = findobj('Tag', mfilename); % find figure with the mfilename in the Tag
    if isempty(h)
        % create figure with the mfilename in the Tag
        figure('Tag', mfilename, 'Name', mfilename);
    end
    
    % plot, create legend and set axis limits and labels
    plot(...
        xActive, z2Active, '-or',... % Boundary profile
        xActive, zActive, '-b' ...   % Water level
        )
    legend(legendtext,2)
    xlabel('x')
    ylabel('z')
	return
end

%% create t-structure
t.functionname = @getBoundaryProfile;
t.logfile = '';
t.resultdir = '';
t.currentcase = [];
t.cases.id = 1;
t.cases.name = 'getBoundaryProfile test';
t.cases.description = 'getBoundaryProfile test (created on 16-Jul-2008 15:17:07)';
t.cases.settings.settingsfunction = '';
t.cases.settings.input = [];
t.cases.run.runfunction = @McT_RunFunction;
t.cases.run.input.vars(1).name = 'WL_t';
t.cases.run.input.vars(1).content = 5;
t.cases.run.input.vars(2).name = 'Tp_t';
t.cases.run.input.vars(2).content = 12;
t.cases.run.input.vars(3).name = 'Hsig_t';
t.cases.run.input.vars(3).content = 9;
t.cases.run.input.vars(4).name = 'x0';
t.cases.run.input.vars(4).content = 0;
t.cases.run.result.runflag = [];
t.cases.run.result.vars.name = '';
t.cases.run.result.vars.content = [];
t.cases.evaluation.evaluationfunction = @getBoundaryProfile_test;
t.cases.evaluation.input.expoutvars.name = 'result';
t.cases.evaluation.input.expoutvars.content.info.time = [];
t.cases.evaluation.input.expoutvars.content.info.ID = 'Boundary Profile';
t.cases.evaluation.input.expoutvars.content.info.messages = [];
t.cases.evaluation.input.expoutvars.content.info.x0 = [];
t.cases.evaluation.input.expoutvars.content.info.iter = [];
t.cases.evaluation.input.expoutvars.content.info.precision = [];
t.cases.evaluation.input.expoutvars.content.info.resultinboundaries = true;
t.cases.evaluation.input.expoutvars.content.info.input = [];
t.cases.evaluation.input.expoutvars.content.Volumes.Volume = 40.9536;
t.cases.evaluation.input.expoutvars.content.Volumes.volumes = [];
t.cases.evaluation.input.expoutvars.content.Volumes.Accretion = [];
t.cases.evaluation.input.expoutvars.content.Volumes.Erosion = [];
t.cases.evaluation.input.expoutvars.content.xLand = [];
t.cases.evaluation.input.expoutvars.content.zLand = [];
t.cases.evaluation.input.expoutvars.content.xActive = [-15.96 -7.32 -4.32 0]';
t.cases.evaluation.input.expoutvars.content.zActive = ones(4,1) * 5;
t.cases.evaluation.input.expoutvars.content.z2Active = [5 9.32 9.32 5]';
t.cases.evaluation.input.expoutvars.content.xSea = [];
t.cases.evaluation.input.expoutvars.content.zSea = [];
t.cases.evaluation.result = [];
t.process.processfunction = '';
t.process.input = [];
t.process.result = [];
