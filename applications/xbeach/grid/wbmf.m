function wbmf
% window motion callback function
% - this function will be called each time the mouse moves

% Created by Sandra Martinka March 2002
% Modified by Dano Roelvink Feb 2009
% Commented by Mark van Koningsveld April 2009

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

global udata

%% get currentpoint information on current axis (utemp.h)
ptemp    = get(udata.h,'CurrentPoint');
ptemp    = ptemp(1,1:2);

%% determine the other two points of the rectangle
x3       = ptemp(1)-10*(ptemp(2)-udata.p1(2));
y3       = ptemp(2)+10*(ptemp(1)-udata.p1(1));
x4       = udata.p1(1)-10*(ptemp(2)-udata.p1(2));
y4       = udata.p1(2)+10*(ptemp(1)-udata.p1(1));

%% set XData and YData on linehandle lh
set(udata.lh,'XData',[x4,udata.p1(1),ptemp(1),x3], ...
             'YData',[y4,udata.p1(2),ptemp(2),y3]);