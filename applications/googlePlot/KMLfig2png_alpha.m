function KMLfig2png_alpha(directory,factor)
%KMLfig2png_alpha(directory)
%
%  KMLfig2png(directory,factor)
%
% changes the alpha channel (transparency) of all
% png images in a directory by multiplying them with factor.
% Alpha = 0 is fully transparent(opaque), and 1 is
% non transparent. When the initial alpha supplied to
% KMLfig2png was 1, the resulting transparency of the
% images is will be alpha=fac.
%
% Note that the original images will be overwritten
% so apply KMLfig2png_alpha on a <COPY> of
% a directory only.
%
%See also: KMLFIG2PNG

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   list = dir([directory,filesep,'*.png']);
   
   nfile = length(list);
   
   for ifile=1:nfile
   
      disp([num2str(ifile),'/',num2str(nfile)])
   
      [im,map,alpha] = imread([directory,filesep,list(ifile).name]);
      alpha          = alpha * .5;
      imwrite(im,[directory,filesep,list(ifile).name],'alpha',alpha)
   
   end

%% EOF
