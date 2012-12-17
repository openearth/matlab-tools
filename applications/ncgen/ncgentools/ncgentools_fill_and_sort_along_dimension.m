function varargout = ncgentools_fill_and_sort_along_dimension(source,destination,varargin)
%NCGENTOOLS_FILL_AND_SORT_ALONG_DIMENSION  One line description goes here.
%
% If this function fails, this is probabluy due to a known matlab bug in ncwriteschema. A fix for theis bug can be found here:
%   http://www.mathworks.com/support/bugreports/819646
% TODO: Create posibility for source and destination are the same.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ncgentools_fill_and_sort_along_dimension(source,destination,varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ncgentools_fill_and_sort_along_dimension
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 07 Jun 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings
% sort variable
OPT.dimension_name = 'time';
% must be a dimension variable (both the name of a dimension and a variable
% with only that dimension)

% variable to fill
OPT.fill_variable_name = 'z';

OPT = setproperty(OPT,varargin);

if nargin==0;
    varargout = {OPT};
    return;
end
%% code

mkpath(destination);
delete2(dir2(destination,'no_dirs',1));
D = dir2(source,'depth',0,'no_dirs',1,'file_incl','\.nc$','file_excl','catalog');

multiWaitbar('processing...','reset')
for ii = 1:length(D);
    source_file      = [D(ii).pathname D(ii).name];
    destination_file = fullfile(destination,D(ii).name);
    ncschema         = ncinfo(source_file);

    % work around for bug http://www.mathworks.com/support/bugreports/819646
    [ncschema.Dimensions([ncschema.Dimensions.Unlimited]).Length] = deal(inf);
    [ncschema.Dimensions([ncschema.Dimensions.Unlimited]).Unlimited] = deal(false);
    
    % write schema
    ncwriteschema(destination_file,ncschema);
    
    variable_names   = {ncschema.Variables.Name};
        
    % determine new order
    c                = ncread(source_file,OPT.dimension_name);
    [~,new_order]    = sort(c);
    
    if isempty(c)
        continue
    end
    
    for iVariable = 1:length(variable_names)
        % read variable
        c = ncread(source_file,variable_names{iVariable});
        
        % rearrange variable to new_order
        if ~isempty(ncschema.Variables(iVariable).Dimensions)
            dimension_names = {ncschema.Variables(iVariable).Dimensions.Name};
            n = strcmpi(dimension_names,OPT.dimension_name);
            if any(n)
                index    = repmat({':'},ndims(c),1);
                index(n) = {new_order};
                c        = c(index{:});
            end
        end
        
        % fill variable if needed
        if strcmpi(variable_names{iVariable},OPT.fill_variable_name)
            index     = repmat({':'},ndims(c),1);
            index(n)  = {1};
            c_current = c(index{:});

            for jj = 2:length(new_order)
                c_previous  = c_current;
                
                index       = repmat({':'},ndims(c),1);
                index(n)    = {jj};
                c_current   = c(index{:});
                
                c_current(isnan(c_current)) = c_previous(isnan(c_current));
                
                c(index{:}) = c_current;
            end
        end
        ncwrite(destination_file,variable_names{iVariable},c);
    end
    multiWaitbar('processing...',ii/length(D));
end


