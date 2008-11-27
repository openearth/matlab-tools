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
%   [ax, h]=colorbarwithtext(colorbartxt) 
%   returns both the handle h of the colorbar and
%   the handle ax of the axes. NOTE that ax is
%   returned first to follow the syntax of ax = colorbar.
%
%   colorbarwithtext(colorbartxt,arguments) or
%   colorbarwithtext(colorbartxt,ctick,arguments) passes arguments
%   to colorbar
%
%   See also: COLORBAR, SET(gca), GET(gca), COLORBARWITHYLABEL
%             COLORBARWITHhTEXT, COLORBARWITHvTEXT

%   G.J. de Boer, Delft Univeristy of Technology, WL | Delft Hydraulics
%   May 2004, 1.1

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
