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

%% call z-function

% check z-function
z_input = getInputVariables(OPT.x2zFunction);

% derive z based on x
if strcmp(OPT.method, 'matrix')
    [z OPT] = zfuntioncall(OPT, stochast, x, z_input);
elseif strcmp(OPT.method, 'loop')
    z = [];
    for isample = 1:size(x,1)
        [z(isample,:) OPT] = zfuntioncall(OPT, stochast, x(isample,:), z_input);
    end
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [z OPT] = zfuntioncall(OPT, stochast, x, z_input)

    [inputargs OPT] = get_inputargs(OPT, x, stochast, z_input);
    z               = feval(OPT.x2zFunction, inputargs{:}, OPT.x2zVariables{:});

function [inputargs OPT] = get_inputargs(OPT, x, stochast, z_input)

    if any(ismember({'samples' 'Resistance'}, z_input))
        warning('OET:probabilistic:deprecated',  [ ...
            'The argument list of the Z-function you are using is deprecated. ' ...
            'Please use the new argument list using the "variables" option and ' ...
            'a varargin cell array.']);
        
        i1 = find(strcmpi('samples',    z_input));
        i2 = find(strcmpi('Resistance', z_input));
        
        if ~isempty(i1)
            inputargs{i1} = x2samples(x, {stochast.Name});
        end
        
        if ~isempty(i2)
            i3 = find(strcmpi('resistance', OPT.x2zVariables));
            if ~isempty(i3)
                inputargs{i2} = OPT.x2zVariables{i3+1};
            else
                inputargs{i2} = 0;
            end
            OPT.x2zVariables(i3:i3+1) = [];
        end
    else
        inputargs = x2inputargs(OPT.x2zFunction, x, stochast);
    end
    
function samples = x2samples(x, variable_names)
samples = cell2struct(mat2cell(x, size(x,1), ones(size(x,2),1)), variable_names, 2);

function inputargs = x2inputargs(fun, x, stochast)
% create cell array of input arguments in same order as defined in
% the stochast structure

inputargs = {};

for ivar = 1:length(stochast)
    if isfield(stochast(ivar), 'Name') && isOETInputCompatible(fun)
        % propertyName is equal to Name in stochast structure
        inputargs = [inputargs {stochast(ivar).Name} {x(:,ivar)}];
    else
        % no propertyName is defined
        inputargs = [inputargs {x(:,ivar)}];
    end
end
