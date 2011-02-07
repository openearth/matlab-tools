function [OPT, Set, Default] = setPropertyInDeeperStruct(OPT, varargin)
% SETPROPERTY generic routine to set values in PropertyName-PropertyValue pairs
%
% Routine to set properties based on PropertyName-PropertyValue
% pairs (aka <keyword,value> pairs). Can be used in any function
% where PropertyName-PropertyValue pairs are used.
%
% syntax:
% [OPT Set Default] = setproperty(OPT, varargin{:})
%  OPT              = setproperty(OPT, 'PropertyName', PropertyValue,...)
%  OPT              = setproperty(OPT, OPT2)
%
% input:
% OPT      = structure in which fieldnames are the keywords and the values are the defaults
% varargin = series of PropertyName-PropertyValue pairs to set
% OPT2     = is a structure with the same fields as OPT.
%
%            Internally setproperty translates OPT2 into a set of
%            PropertyName-PropertyValue pairs (see example below) as in:
%            OPT2    = struct( 'propertyName1', 1,...
%                              'propertyName2', 2);
%            varcell = reshape([fieldnames(OPT2)'; struct2cell(OPT2)'], 1, 2*length(fieldnames(OPT2)));
%            OPT     = setproperty(OPT, varcell{:});
%
% output:
% OPT     = structure, similar to the input argument OPT, with possibly
%           changed values in the fields
% Set     = structure, similar to OPT, values are true where OPT has been
%           set (and possibly changed)
% Default = structure, similar to OPT, values are true where the values of
%           OPT are equal to the original OPT
%
% Example:
%
% +------------------------------------------->
% | function y = dosomething(x,'debug',1)
% | OPT.debug  = 0;
% | OPT        = setproperty(OPT, varargin{:});
% | y          = x.^2;
% | if OPT.debug; plot(x,y);pause; end
% +------------------------------------------->
%
% See also: varargin, struct, mergestructs

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

% Created: 26 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%% input
PropertyNames = fieldnames(OPT); % read PropertyNames from structure fieldnames

if length(varargin) == 1
    % to prevent errors when this function is called as
    % "OPT = setproperty(OPT, varargin);" instead of
    % "OPT = setproperty(OPT, varargin{:})"
    if isstruct(varargin{1})
        OPT2     = varargin{1};
        varargin = reshape([fieldnames(OPT2)'; struct2cell(OPT2)'], 1, 2*length(fieldnames(OPT2)));
    else
        varargin = varargin{1};
    end
end

%% keyword,value loop
[i0 iend] = deal(1, length(varargin)); % specify index of first and last element of varargin to search for keyword/value pairs
for iargin = i0:2:iend
    if ~ischar(varargin{iargin})
        % no char found where PropertyName expected
        error([upper(mfilename) ':UnknownPropertyName'], 'PropertyName should be char')
    end
    PropertyName = regexp(varargin{iargin},'[^\.]*','match');
    % check if propertyname exists
    
    if isfield(OPT,PropertyName{1})
        fieldExists = true;
        if length(PropertyName)>1
            if isfield(OPT.(PropertyName{1}),PropertyName{2})
                fieldExists = true;
                if length(PropertyName)>2
                    if isfield(OPT.(PropertyName{1}).(PropertyName{2}),PropertyName{3})
                        fieldExists = true;
                        if length(PropertyName)>3
                            if isfield(OPT.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}),PropertyName{4})
                                fieldExists = true;
                                if length(PropertyName)>4
                                    error([upper(mfilename) ':InvalidPropertyName'], ['PropertyName "' varargin{iargin} '" is too deep in the structure'])
                                end
                            else
                                fieldExists = false;
                            end
                        end
                    else
                        fieldExists = false;
                    end
                end
            else
                fieldExists = false;
            end
        end
    else
        fieldExists = false;
    end
        
    if fieldExists
            % option is in structure
        switch length(PropertyName)
            case 1
                if nargout>2
                    if ~isequalwithequalnans(OPT.(PropertyName{1}), varargin{iargin+1})
                        % indicate that this field is non-default now
                        Default.(PropertyName{1}) = false;
                    end
                end
                if nargout>1
                    % indicate that this field is set
                    Set.(PropertyName{1}) = true;
                end
                OPT.(PropertyName{1}) = varargin{iargin+1};
            case 2
                % set option
                if ~isequalwithequalnans(OPT.(PropertyName{1}).(PropertyName{2}), varargin{iargin+1})
                    % only renew property value if it really changes
                    OPT.(PropertyName{1}).(PropertyName{2}) = varargin{iargin+1};
                    % indicate that this field is non-default now
                    Default.(PropertyName{1}).(PropertyName{2}) = false;
                end
                % indicate that this field is set
                Set.(PropertyName{1}).(PropertyName{2}) = true;
            case 3
                % set option
                if ~isequalwithequalnans(OPT.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}), varargin{iargin+1})
                    % only renew property value if it really changes
                    OPT.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}) = varargin{iargin+1};
                    % indicate that this field is non-default now
                    Default.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}) = false;
                end
                % indicate that this field is set
                Set.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}) = true;
            case 4
                % set option
                if ~isequalwithequalnans(OPT.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}).(PropertyName{4}), varargin{iargin+1})
                    % only renew property value if it really changes
                    OPT.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}).(PropertyName{4}) = varargin{iargin+1};
                    % indicate that this field is non-default now
                    Default.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}).(PropertyName{4}) = false;
                end
                % indicate that this field is set
                Set.(PropertyName{1}).(PropertyName{2}).(PropertyName{3}).(PropertyName{4}) = true;
            otherwise
                error([upper(mfilename) ':InvalidPropertyName'], ['PropertyName "' varargin{iargin} '" is too deep in the structure'])
        end
    else
        % PropertyName unknown
        error([upper(mfilename) ':UnknownPropertyName'], ['PropertyName "' varargin{iargin} '" is not valid'])
    end
end

% Set all fields in OPT but not yet in Set to false
if nargout>1
    for ii = 1:length(PropertyNames)
        if ~isfield(Set,PropertyNames{ii})
            Set.(PropertyNames{ii}) = false;
        end
    end
    Set = orderfields(Set, OPT);
end

% Set all fields in OPT but not yet in Default to true
if nargout>2
    for ii = 1:length(PropertyNames)
        if ~isfield(Default,PropertyNames{ii})
            Default.(PropertyNames{ii}) = true;
        end
    end
    Default = orderfields(Default, OPT);
end

%% EOF