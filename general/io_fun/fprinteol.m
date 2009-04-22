function fprinteol(fid,varargin)
%FPRINTEOL   Write end-of-line symbol(s) of specific OS to file.
%
% Writes the system depenedent ASCII end of line 
% character to a text file.
%
%    FPRINTEOL(fid,OperationSystem)
%
% where fid is a file indentifier as returned by FOPEN,
% where OperationSystem is a string with value
% * 'u<nix>'  (default)
% * 'l<inux>' (default)
% * 'd<os>'
% * 'w<indows>'
%
%See also: FOPEN, FPRINTF, FCLOSE

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

   if nargin==2
      OS = varargin{1};
   else
      OS = 'l';
   end

       if strcmp(lower(OS(1)),'u');fprintf(fid,'\n');
   elseif strcmp(lower(OS(1)),'l');fprintf(fid,'\n');
   elseif strcmp(lower(OS(1)),'w');fprintf(fid,'\r\n');
   elseif strcmp(lower(OS(1)),'d');fprintf(fid,'\r\n');
   end 

%% EOF