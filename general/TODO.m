function [mfilestr]=TODO(txt)
%TODO  Display a TODO message while running code
%
%   This function displays a custom TODO message whenever matlab executes
%   the code where function is called. A link to the specific location of
%   the code is included (like an error message).
%
%   Syntax:
%   mfilestr = TODO(txt)
%
%   Input:
%   txt  = TODO message that has to be displayed
%
%   Output:
%   mfilestr = struct that follows from a dbstack call at the location
%               where the function is called.
%
%   Example
%   TODO('Edit this code');
%
%   See also warning error

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       <ADDRESS>
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

% Created: 09 Dec 2008
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% Look in stack
mfilestr=dbstack(1);

CalledFromFile = ~isempty(mfilestr);

if CalledFromFile
    %% Retrieve function/m-file name and line
    mfile = mfilestr(1).file;
    fullmfile = which(mfile);
    lineno = num2str(mfilestr(1).line);
    
    %% Build string with link info
    str=['TODO in ==> <a href="matlab: opentoline(''' fullmfile ''',' lineno ',0);">' mfile ' at ' lineno '</a>'];
    
    %% display message
    disp(str);
    disp(txt);
end