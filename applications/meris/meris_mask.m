function mask = meris_mask(l2_flags,bits),
%MERIS_MASK  makes one mask from multiple MERIS flags.
%
% mask = meris_mask(l2_flags,bits)
%
% where flags   is a double array, 
%       bits    are the bit numbers to be REMOVED from the image and
%       mask    is a double array that is 1 where pixels should be KEPT,
%               and NaN where pixels should be removed,
%               so you can multiply it with your data.
%
% Example to remove land and clouds. Note that land is 
% only true where there are no clouds!
%
% SAT.mask     = meris_mask(SAT.l2_flags,[22 23]);
%
%See also: BITAND, MERIS_NAME2META, MERIS_FLAGS, DEC2BIN, BIN2DEC
 
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Oct. Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% TO DO: allow also cellstr for bits, and get associated bit numbers from MERIS_FLAGS

OPT.debug = 1;

mask = ones(size(l2_flags));

flags = meris_flags;

for ibit=1:length(bits)

   bit = bits(ibit);
   
   if OPT.debug
      disp(['meris_mask: removed bit ',num2str(bit),' : ',flags.name{find(bit==flags.bit)}])
   end

   bitmask = (bitand(l2_flags,2^bit))~=0;
   
   mask(bitmask) = 0;

end

mask(mask==0)=NaN;


%% EOF