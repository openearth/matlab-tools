function mask = modis_mask(l2_flags,bits,varargin),
%MODIS_MASK  makes one mask from multiple SeaWiFS flags.
%
% mask = modis_mask(l2_flags,bits,<keyword,value>)
%
% where l2_flags  is an integer array as read by SEAWIFS_L2_READ, 
%       bits      are the bit numbers to be REMOVED from the image 
%                 defined in SEAWIFS_FLAGS
%       mask      is a double array meant for multiplication with the data:
%                 1   where pixels should be KEPT
%                 NaN where pixels should be REMOVED
%
% Example to remove land, clouds and ice:
%
% SAT.mask     = modis_mask(SAT.l2_flags,[2 10]);
%
%See also: BITAND, SEAWIFS_FLAGS, SEAWIFS_L2_READ, DEC2BIN, BIN2DEC, MERIS_MASK
 
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% TO DO: allow also cellstr for bits, and get associated bit numbers from SEAWIFS_FLAGS

%% Keywords

   OPT.disp = 1;
   
   if nargin==0
      varargout = {OPT};return
   else
      OPT       = setproperty(OPT,varargin{:});
   end
   
%% Apply

   mask     = ones(size(l2_flags));
   flags    = seawifs_flags;
   
   for ibit=1:length(bits)
   
      bit = bits(ibit);
      
      if OPT.disp
         disp([mfilename,': removed bit ',num2str(bit),' : ',flags.name{find(bit==flags.bit)}])
      end
   
      bitmask = (bitand(uint32(l2_flags + 2^31),2^bit))~=0;
      
      mask(bitmask) = 0;
   
   end
   
   mask(mask==0)=NaN;


%% EOF