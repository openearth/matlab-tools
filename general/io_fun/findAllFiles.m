function filenames = findAllFiles(varargin)
%UNTITLED  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Van Oord
%       Mark van Koningsveld
%
%       mrv@vanoord.com
%
%       Watermanweg 64
%       POBox 8574
%       3009 AN Rotterdam
%       Netherlands
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

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings
% defaults
OPT = struct(...
    'pattern_excl', {{[filesep,'.svn']}}, ...                % pattern to exclude
    'pattern_incl', {'*.dat'}, ...                           % pattern to include
    'basepath', 'D:\checkouts\VO-rawdata\waveclimates\', ... % indicate basedpath to start looking
    'recursive', 1 ...                                       % indicate whether or not the request is recursive
    );

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

%% Find all subdirs in basepath
%---------------------------------------------

if ispc
    if OPT.recursive
        [a b] = system(['dir /b /a /s ' '"' OPT.basepath filesep OPT.pattern_incl '"']);
    else
        [a b] = system(['dir /b /a ' '"' OPT.basepath filesep OPT.pattern_incl '"']);
    end
else
    disp('Not supported yet for this operating system')
end

%% Exclude the .svn directories from the path
% read path as cell
s = strread(b, '%s', 'delimiter', char(10));  

% clear cells which contain OPT.pattern_excl
for imask = 1:length(OPT.pattern_excl)
    OPT.pattern = OPT.pattern_excl{imask};
    s = s(cellfun('isempty', regexp(s, [OPT.pattern]))); % keep only paths not containing [filesep '.svn']
end

%% return cell with resulting files (including pathnames)
filenames = s;