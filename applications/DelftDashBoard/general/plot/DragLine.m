function DragLine(src, eventdata, fcn, opt)
%DRAGLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   DragLine(src, eventdata, fcn, opt)
%
%   Input:
%   src       =
%   eventdata =
%   fcn       =
%   opt       =
%
%
%
%
%   Example
%   DragLine
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;
id=handles.ActiveDomain;

set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

if strcmp(opt,'gridline')
    [m1,n1]=findcornerpoint(posx,posy,handles.Model(handles.ActiveModel.Nr).Input(id).GridX,handles.Model(handles.ActiveModel.Nr).Input(id).GridY);
    posx=handles.Model(handles.ActiveModel.Nr).Input(id).GridX(m1,n1);
    posy=handles.Model(handles.ActiveModel.Nr).Input(id).GridY(m1,n1);
end

usd.opt=opt;

usd.x=[posx posx];
usd.y=[posy posy];
usd.z=[9000 9000];
usd.Line=plot3(usd.x,usd.y,usd.z);

usd.LineColor='g';
usd.LineWidth=2;
usd.LineStyle='-';

set(usd.Line,'LineWidth',usd.LineWidth);
set(usd.Line,'LineStyle',usd.LineStyle);
set(usd.Line,'Color',usd.LineColor);

set(0,'UserData',usd);

waitfor(0,'userdata',[]);

h=findall(gcf,'Tag','DraggedLine');
if ~isempty(h)
    usd=get(h,'UserData');
    x=usd.x;
    y=usd.y;
    delete(h);
    fcn(x,y);
end

%%
function StartTrack(imagefig, varargins) 

set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});
usd=get(0,'UserData');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x=posx;
usd.y=posy;
usd.z=9000;
usd.Line=plot3(usd.x,usd.y,usd.z);
set(usd.Line,'LineWidth',usd.LineWidth);
set(usd.Line,'LineStyle',usd.LineStyle);
set(usd.Line,'Color',usd.LineColor);
set(0,'UserData',usd);

%%
function FollowTrack(imagefig, varargins) 
usd=get(0,'UserData');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x(2)=posx;
usd.y(2)=posy;
usd.z(2)=9000;
set(usd.Line,'XData',usd.x);
set(usd.Line,'YData',usd.y);
set(usd.Line,'ZData',usd.z);
set(0,'UserData',usd);
ddb_updateCoordinateText('arrow');

%%
function StopTrack(imagefig, varargins)
ddb_setWindowButtonMotionFcn;
usd=get(0,'UserData');
set(usd.Line,'UserData',usd);
set(usd.Line,'Tag','DraggedLine');
set(0,'UserData',[]);

%%
function MoveMouse(imagefig, varargins)

ddb_updateCoordinateText('arrow');
