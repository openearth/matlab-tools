function varargout = disp(File,varargin)
%DISP  displays overview of contents of DONAR (blocks + variables)
%
% File = disp(diafile) displays overview of File Variables
%
% Example:
% 
%  File            = donar.open(diafile)
%                    donar.disp(File)
% [data, metadata] = donar.read(File,1,6) % 1st variable, residing in 6th column
%
%See also: open, read, disp

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

OPT.format = 0;

if nargin==0
    varargout = {OPT};return
end
OPT = setproperty(OPT,varargin);

V = File.Variables;
%%
disp(File.Filename)
fmt = '%5s+%4s+%6s+%8s+%8s+%+64s-+-%s';
disp(sprintf(fmt,'-----','----','------','--------','--------','----------------------------------------------------------------','--------->'))

%%
fmt = '%5s|%4s|%6s|%8s|%8s|%64s | %s';
disp(sprintf(fmt,'File ','WNS ', ' # of ', ' # of ', 'DONAR','CF', 'DONAR'))
disp(sprintf(fmt,'index','code', 'blocks', 'values', 'name','standard_name', 'long_name'))
%%
fmt = '%5s+%4s+%6s+%8s+%8s+%+64s-+-%s';
disp(sprintf(fmt,'-----','----','------','--------','--------','----------------------------------------------------------------','--------->'))
%%
fmt = '%5d|%4s|%6d|%8d|%8s|%64s | %s';

for i=1:length(V)

disp(sprintf(fmt, i, V(i).WNS, length(V), sum(V(i).nval), V(i).hdr.PAR{1}, V(i).standard_name, V(i).long_name))

end
%%
fmt = '%5s+%4s+%6s+%8s+%8s+%64s-+-%s';
disp(sprintf(fmt,'-----','----','------','--------','--------','----------------------------------------------------------------','--------->'))
