function [OPT Set Default] = setProperty(OPT, varargin)
% SETPROPERTY generic routine to set values in PropertyName-PropertyValue pairs
%
% Routine to set properties based on PropertyName-PropertyValue pairs. Can
% be used in any function where PropertyName-PropertyValue pairs are used.
%   
% syntax:
% [OPT Set Default] = setProperty(OPT, varargin)
% OPT = setProperty(OPT, 'PropertyName', PropertyValue,...)
%
% input:
% OPT      = structure in which fieldnames are the keywords and the values are the defaults 
% varargin = series of PropertyName-PropertyValue pairs to set
%
% output:
% OPT     = structure, similar to the input argument OPT, with possibly
%           changed values in the fields
% Set     = structure, similar to OPT, values are true where OPT has been 
%           set (and possibly changed)
% Default = structure, similar to OPT, values are true where the values of
%           OPT are equal to the original OPT
%
% See also: 

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

% $Id: keyword_value.m 40 2008-11-12 16:09:19Z heijer $ 
% $Date: 2008-11-12 17:09:19 +0100 (Wed, 12 Nov 2008) $
% $Author: heijer $
% $Revision: 40 $

%%
PropertyNames = fieldnames(OPT); % read PropertyNames from structure fieldnames

if isscalar(varargin) && iscell(varargin)
    % to prevent errors when this function is called as "OPT =
    % setProperty(OPT, varargin);" instead of "OPT = setProperty(OPT,
    % varargin{:})"
    varargin = varargin{1};
end

% Set is similar to OPT, initially all fields are false
Set = cell2struct(repmat({false}, size(PropertyNames)), PropertyNames);
% Default is similar to OPT, initially all fields are true
Default = cell2struct(repmat({true}, size(PropertyNames)), PropertyNames);

[i0 iend] = deal(1, length(varargin)); % specify index of first and last element of varargin to search for keyword/value pairs
for iargin = i0:2:iend
    PropertyName = varargin{iargin};
    if any(strcmp(PropertyNames, PropertyName))
        % set option
        if ~isequalwithequalnans(OPT.(PropertyName), varargin{iargin+1})
            % only renew property value if it really changes
            OPT.(PropertyName) = varargin{iargin+1};
            % indicate that this field is non-default now
            Default.(PropertyName) = false;
        end
        % indicate that this field is set
        Set.(PropertyName) = true;
    elseif any(strcmpi(PropertyNames, PropertyName))
        % set option, but give warning that PropertyName is not totally correct
        realPropertyName = PropertyNames(strcmpi(PropertyNames, PropertyName));
        if ~isequalwithequalnans(OPT.(realPropertyName{1}), varargin{iargin+1})
            % only renew property value if it really changes
            OPT.(realPropertyName{1}) = varargin{iargin+1};
            % indicate that this field is non-default now
            Default.(PropertyName) = false;
        end
        % indicate that this field is set
        Set.(realPropertyName{1}) = true;
        warning([upper(mfilename) ':PropertyName'], ['Could not find an exact (case-sensitive) match for ''' PropertyName '''. ''' realPropertyName{1} ''' has been used instead.'])
    elseif ischar(PropertyName)
        % PropertyName unknown
        error([upper(mfilename) ':UnknownPropertyName'], ['PropertyName "' PropertyName '" is not valid'])
    else
        % no char found where PropertyName expected
        error([upper(mfilename) ':UnknownPropertyName'], 'PropertyName should be char')
    end
end