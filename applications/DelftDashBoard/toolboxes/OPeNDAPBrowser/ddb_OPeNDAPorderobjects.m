function ddb_OPeNDAPorderobjects
% OPENDAP_ORDER_OBJECTS  make sure objects are properly ordered (largest objects in the back, selected ones up front) 

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

%% get handles
handles           = getHandles;
C                 = get(handles.GUIHandles.Pushddb_FindDataset, 'userdata' );

%% sort shapes on size
xll                 = C.geospatialCoverage_eastwest(:,1);
yll                 = C.geospatialCoverage_northsouth(:,1);
xur                 = C.geospatialCoverage_eastwest(:,2);
yur                 = C.geospatialCoverage_northsouth(:,2);

sizes               = sqrt((xur - xll).^2 + (yur - yll).^2);
[dummy, id1]        = sort(sizes, 'descend'); clear dummy

%% get the handles and urls of all OPeNDAP objects and sort the according to above sorting
hndls_obj           = [findobj(gca, 'type', 'rectangle'); findobj(gca, 'type', 'patch')];
hndls_obj           = hndls_obj(id1);

hndls_all    = get(gca,'children');
hndls_ddb    = hndls_all(~ismember(hndls_all, hndls_obj));

set(gca, 'children', [hndls_obj; hndls_ddb] )

%% now reorder the shapes such that selected ones are on top
ids_rect_act        = ismember(hndls_obj, findobj(gca, 'type', 'rectangle', 'facecolor', [0 1 0]));
ids_patches_act     = ismember(hndls_obj, findobj(gca, 'type', 'patch',     'facecolor', [0 1 0]));
ids_rect_pas        = ismember(hndls_obj, findobj(gca, 'type', 'rectangle', 'facecolor', [1 0 0]));
ids_patches_pas     = ismember(hndls_obj, findobj(gca, 'type', 'patch',     'facecolor', [1 0 0]));

hndls_obj         =  [hndls_obj(ids_rect_act); hndls_obj(ids_patches_act); hndls_obj(ids_rect_pas); hndls_obj(ids_patches_pas)];

set(gca, 'children', [hndls_obj; hndls_ddb] )

% % 
% % %% find out which handles belong to DelftDashboard
% % 
% % %% now make sure that all objects are displayed in descending order first on top of the ddb objects 
% % set(gca, 'children', [hndls_obj; hndls_ddb] )
% % 
% % uistack(hndls_obj(ids_patches_pas),'top'); 
% % uistack(hndls_obj(ids_rect_pas),   'top'); 
% % uistack(hndls_obj(ids_patches_act),'top'); 
% % uistack(hndls_obj(ids_rect_act),   'top'); 
% % 
% % try set(hndls_obj(ids_patches_pas),'facecolor', [1 0 0], 'edgecolor', 'k','FaceAlpha',.25); end
% % try set(hndls_obj(ids_rect_pas),   'facecolor', [1 0 0], 'edgecolor', 'k');                 end
% % try set(hndls_obj(ids_patches_act),'facecolor', [0 1 0], 'edgecolor', 'k','FaceAlpha',1);   end
% % try set(hndls_obj(ids_rect_act),   'facecolor', [0 1 0], 'edgecolor', 'k');                 end


% %% automatically adjust object sizes depending on zoom levels
% hndls_rectangles     = findobj(gca, 'type', 'rectangle');
% pos                  = get(hndls_rectangles,'position');
% pos                  = vertcat(pos{:});
% ax                   = axis;
% if ax(2) - ax(1)<20
%     newsize = .05;
%     for i = 1:length(hndls_rectangles)
%         set(hndls_rectangles(i),'position', [pos(i,1:2) newsize newsize])
%     end
% elseif ax(2) - ax(1)>=20 & ax(2) - ax(1)<75
%     newsize = .2;
%     for i = 1:length(hndls_rectangles)
%         set(hndls_rectangles(i),'position', [pos(i,1:2) newsize newsize])
%     end
% elseif ax(2) - ax(1)>=75
%     newsize = .3;
%     for i = 1:length(hndls_rectangles)
%         set(hndls_rectangles(i),'position', [pos(i,1:2) newsize newsize])
%     end
% end
% drawnow
