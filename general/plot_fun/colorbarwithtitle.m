function [varargout]=colorbarwithtitle(colorbartxt,varargin)
%COLORBARWITHTITLE   (re)draws the colorbar with title above it.
%
%   colorbarwithtext(colorbartxt) (re)draws the colorbar
%   with text above it.
%
%   colorbarwithtext(colorbartxt,ctick) (re)draws the colorbar
%   with tick marks at positions ctick.
%
%   [h]=colorbarwithtext(colorbartxt) does the same
%   and returns the handle h of the colorbar.
%
%   [ax, h]=colorbarwithtext(colorbartxt,<ctick>) 
%   returns both the handle h of the colorbar and
%   the handle ax of the axes. NOTE that ax is
%   returned first to follow the syntax of ax = colorbar.
%
%   Example:  
%   [ax, h]=colorbarwithtitle('wind direction',[0:90:360]) 
%   set(ax,'YTickLabel',{'E','N','W','S'})
%
%   colorbarwithtext(colorbartxt,arguments) or
%   colorbarwithtext(colorbartxt,ctick,arguments) passes arguments
%   to colorbar
%
%   See also: COLORBAR, SET(gca), GET(gca), COLORBARWITHYLABEL
%             COLORBARWITHhTEXT, COLORBARWITHvTEXT

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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
%   -------------------------------------------------------------------

    OPT.position = 'title';

    nextarg = 1;
    ctick   = [];
if nargin>1

    %% note that 0 is also a handle,
    %% so we cannot use ishandle(), and we use istype()

    if isnumeric(varargin{1}) & ~istype(varargin{1},'axes');
    nextarg = 2;
    ctick   = varargin{1};
    end    
end

Handles.axes          = colorbar(varargin{nextarg:end});

Handles.colorbar       = get(Handles.axes,'children');
if     strcmp(OPT.position,'title')
   Handles.colorbartitle  = get(Handles.axes,'title');
elseif strcmp(OPT.position,'xlabel')
   Handles.colorbarxlabel = get(Handles.axes,'xlabel');
elseif strcmp(OPT.position,'ylabel')
   Handles.colorbarylabel = get(Handles.axes,'ylabel');
elseif strcmp(OPT.position,'text')
   text(0.5,0.5,colorbartxt,'units','normalized',...
                         'rotation',0,...
              'horizontalalignment','center',...
                           'Parent',Handles.axes)
end

%for i=1:length(Handles.colorbar)
%   get(Handles.colorbar(i))
%   disp('--------------')
%end

if ~isempty(ctick)
   if isempty(get(Handles.axes,'xtick'))
   set(Handles.axes,'ytick',[ctick]);    
   elseif isempty(get(Handles.axes,'ytick'))
   set(Handles.axes,'xtick',[ctick]);    
   end
end

if     strcmp(OPT.position,'title')
set(Handles.colorbartitle ,'string',colorbartxt);
elseif strcmp(OPT.position,'xlabel')
set(Handles.colorbarxlabel,'string',colorbartxt);
elseif strcmp(OPT.position,'ylabel')
set(Handles.colorbarylabel,'string',colorbartxt);
end

if nargout==1
   varargout={Handles.colorbar};
elseif nargout==2
   varargout={Handles.axes, Handles.colorbar};
elseif nargout>2
   error('requires only 0, 1 or 2 output parameters.');
end
