function [z OPT] = prob_zfunctioncall(OPT, stochast, x, varargin)
%PROB_ZFUNCTIONCALL  adapter function between FORM/MC and z-function
%
%   This function creates a call to a z-function based on the input from
%   either the FORM or the MC routine. This function is mainly created to
%   ensure backward compatibility with older versions of FORM and MC and
%   the corresponding requirements for the z-functions.
%
%   Syntax:
%   varargout = prob_zfunctioncall(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_zfunctioncall
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% check z-function
z_input = getInputVariables(OPT.x2zFunction);

% derive z based on x
if strcmp(OPT.method, 'matrix')
    inputargs = {};
    if ismember('samples', z_input)
        % create samples structure
        samples = x2samples(x, {stochast.Name});
        inputargs{end+1} = samples;
    else
        inputargs = x2inputargs(x, inputargs, stochast);
    end
    if ismember('Resistance', z_input)
        inputargs{end+1} = 0;
    end
    z = feval(OPT.x2zFunction, inputargs{:},...
        OPT.variables{:});
elseif strcmp(OPT.method, 'loop')
    z = [];
    for isample = 1:OPT.NrSamples
        inputargs = {};
        if ismember('samples', z_input)
            % create samples structure
            samples = x2samples(x(isample,:), {stochast.Name});
            inputargs{end+1} = samples;
        else
            inputargs = x2inputargs(x(isample,:), inputargs, stochast);
        end
        if ismember('Resistance', z_input)
            inputargs{end+1} = 0;
        end
        z(isample,:) = feval(OPT.x2zFunction, inputargs{:},...
            OPT.variables{:});
    end
end


%%
function samples = x2samples(x, variable_names)
samples = cell2struct(mat2cell(x, size(x,1), ones(size(x,2),1)), variable_names, 2);

%%
function inputargs = x2inputargs(x, inputargs, stochast)
% create cell array of input arguments in same order as defined in
% the stochast structure
for ivar = 1:length(stochast)
    if ischar(stochast(ivar).propertyName)
        % specific propertyName is defined in stochast structure
        inputargs = [inputargs {stochast(ivar).propertyName} {x(:,ivar)}];
    elseif stochast(ivar).propertyName
        % propertyName is equal to Name in stochast structure
        inputargs = [inputargs {stochast(ivar).Name} {x(:,ivar)}];
    else
        % no propertyName is defined
        inputargs = [inputargs {x(:,ivar)}];
    end
end
