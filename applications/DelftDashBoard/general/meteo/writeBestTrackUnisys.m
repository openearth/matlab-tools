function varargout = writeBestTrackUnisys(tc_fname,tc,varargin)
%UNTITLED  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = Untitled(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
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
%   Copyright (C) 2014 <COMPANY>
%       grasmeijerb
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 03 Jun 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

fid = fopen(tc_fname,'w+');
fprintf(fid,'%s\n',tc.date);
fprintf(fid,'%s\n',tc.name);
fprintf(fid,'%s\n',tc.meta);
for i = 1:length(tc.time)
    mystring = [num2str(i,'%8.2f'),datestr(tc.time(i),'mm/dd/hh')];
    fprintf(fid,'%3s %8s %8s %10s%s %8s %10s\n',num2str(i),num2str(tc.lat(i)),...
        num2str(tc.lon(i)),datestr(tc.time(i),'mm/dd/hh'),'Z',num2str(tc.vmax(i,1)),num2str(tc.p(i,1)./100))
    
end
fclose(fid)
