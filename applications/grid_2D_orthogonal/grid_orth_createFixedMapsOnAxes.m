function ah = grid_orth_createFixedMapsOnAxes(ah, OPT, varargin)
%GRID_ORTH_CREATEFIXEDMAPSONAXES   plot fixed maps retrieved from OPeNDAP server to any arbitrary axes
%
% See also: grid_2D_orthogonal


% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

%% make the axes to use the current one
OPT.x_ranges = OPT.x_ranges';
OPT.y_ranges = OPT.y_ranges';

for ii = 1:length(OPT.urls)
    patch(...
       'xdata',[OPT.x_ranges(ii,1) OPT.x_ranges(ii,2) OPT.x_ranges(ii,2) OPT.x_ranges(ii,1) OPT.x_ranges(ii,1)], ...
       'ydata',[OPT.y_ranges(ii,1) OPT.y_ranges(ii,1) OPT.y_ranges(ii,2) OPT.y_ranges(ii,2) OPT.y_ranges(ii,1)], ...
       'EdgeColor','r','tag',OPT.urls{ii},'FaceColor','none','parent',ah);
end

