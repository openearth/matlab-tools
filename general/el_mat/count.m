function varargout = count(x)
%COUNT   counts freqeuncy of unique values
%
% [number_of_occurence ]               = count(x)
% [number_of_occurence, unique_values] = count(x)
%
% where unique_values is the output of unique(x)
%
% Example: count([1 1 1 2 2 3]) gives [3 2 1]
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
values   = unique(x);

numbers  = zeros(size(values));

for ival = 1:length(values)

   numbers(ival) = sum(x==values(ival));

end

if nargout < 2

   varargout = {numbers};

elseif nargout==2

   varargout = {numbers, values};

end

%% EOF