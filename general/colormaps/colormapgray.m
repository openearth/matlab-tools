function colormapgray = colormapgray(varargin);
%COLORMAPGRAY   colormap with linear transition between two gray scales
%
%   map = colormapgray(graymin,graymax)
%   map = colormapgray(graymin,graymax, ngray)
%
% creates a linear gray colormap between graymin 
% and graymax with ngray entries. Graymin and 
% graymax are values in the range [0 1], which are 
% applied for all rgb triplets (red, green and blue).
% Same syntax as linspace (where default ngray=100);
%
% map = colormapgray([gray_tones])
% replictes the 1D vector gray_tones to the r,g and b values.
%
% Example:
% colormap(colormapgray(.1,.9,10))
%
%See also: colormapeditor, colormap,COLORGRAYMAP

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
%   -------------------------------------------------------------------- 

   %   Feb 2004, version 1.0
   %   Feb 2006, version 2.0, added option for nargin=1
   
   if nargin>1
       
      grayvector   = linspace(varargin{:});
     % graymin = varargin{1};
     % graymax = varargin{2};
     % ngray   = varargin{3};
     % grayvector   = graymin + (0:1:ngray)./ngray.*(graymax-graymin);
   
   elseif nargin==1
   
      grayvector   = varargin{1};
   
   end
   
   colormapgray = [grayvector' grayvector' grayvector'];

%% EOF