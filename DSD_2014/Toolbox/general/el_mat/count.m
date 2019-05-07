function varargout = count(varargin)
%COUNT   counts freqeuncy of unique values
%
% [n_occurrences, c, ia, ic] = count(varargin)
% where c, ia, ic is the output of unique(varargin)
% varargin = the same as for unique
%
% Example: 
%   count([1 1 1 2 2 3]) gives [3 2 1]
% Also observe the differences in 
%   [n_occurrences, c] = count(['bbcaaa';'aaabbc']);
%   [n_occurrences, c] = count(['bbcaaa';'bbcaaa'],'rows');
%
%See also: HIST, MODE, ISMEMBER, UNIQUE, INTERSECT

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%
%       Gerben J. de Boer
%       g.j.deboer@tudelft.nl	
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

% $Id: count.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/el_mat/count.m $
% $Keywords$

[c,ia,ic]     = unique(varargin{:});
n_occurrences = histc(int32(ic),int32(1:length(ia)));
varargout     = {n_occurrences,c,ia,ic};


%% EOF