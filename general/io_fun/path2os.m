function string = path2os(string,input)
%PATH2OS   Replaces directory slashes to conform with a OS
%
% string = path2os(string)
%
% Replaces all slashes (/ or \) with the
% slash of the current Operating System.
%
% Options are:
%
% string = path2os(string,'/')
% string = path2os(string,'\')
% string = path2os(string,'d<os>')
% string = path2os(string,'u<nix>')
% string = path2os(string,'l<inux>')
% string = path2os(string,'w<indows>')
%
% Also removes redundant (double) slashes
% that might have arisen when merging
% pathnames like in d:\temp\\foo\\
%
% G.J. de Boer, TU Delft, 
% Environmental FLuid Mechanics
% Feb. 2005
%
%See also: MKDIR,  EXIST, MKPATH,     COPYFILE, CD, LAST_SUBDIR,
%          DELETE, DIR,   FILEATTRIB, MOVEFILE, RMDIR.

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
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
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

   if nargin==1
       slash = filesep;
   else
       if     input(1) == 'u' | ...
              input(1) == 'l'
              slash    =  '/';
              
       elseif input(1) == 'w' | ...
              input(1) == 'd'
              slash    =  '\';
              
       elseif input(1) == '\' | ...
              input(1) == '/'
              slash    =  input(1);
       end
   end

%% Replace all slashes 
%--------------------------

   string = strrep(string,'/',slash);

   string = strrep(string,'\',slash);


%% Remove redundant fileseps
%--------------------------

   string1 = '';

   while ~strcmp(string,string1)

      string1 = strrep(string,[slash, slash],slash);
      string  = string1;

   end
   
%% EOF   