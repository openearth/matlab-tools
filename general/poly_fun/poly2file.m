function poly2file

%POLY2FILE   draw and save polygon in current axes
%
% 1. Draw a polygon by left clicking the mouse.
% 2. Terminate with enter
% 3. Choose filename
% 
% See also: UCIT_WS_drawPolygon, drawpolygon 
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl	
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


[xv,yv] = UCIT_WS_drawPolygon;
polygon=[xv yv];
[FileName,PathName] = uiputfile('d:\*.mat','Save polygon to file', 'Saved_polygon.mat');
if FileName==0 & PathName==0
    return
else
    save([PathName FileName],'polygon');
    hold on; plot(polygon(:,1),polygon(:,2));
end
