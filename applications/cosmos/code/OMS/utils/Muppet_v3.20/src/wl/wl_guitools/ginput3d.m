function [out1,out2,out3] = ginput3d(varargin)
%GINPUT3D Graphical input from a mouse or cursor.
%   [X,Y,Z] = GINPUT3D(N) gets N points from the current axes and
%   returns the X-, Y- and Z-coordinates in length N vectors X, Y
%   and Z. The cursor can be positioned using a mouse. Due to the
%   limitation of 2D mouse movement, one coordinate remains fixed.
%   One can toggle between fixed X-, Y- and Z-coordinate by press-
%   ing the right mouse button. Data points are entered by pressing
%   the left mouse button or any key on the keyboard. A carriage
%   return terminates the input before N points are entered.
% 
%   [X,Y,Z] = GINPUT3D gathers an unlimited number of points until
%   the return key is pressed.
%
%   [X,Y] = GINPUT3D(N,'fig') gathers N points in figure coordinates.
%
%   The order of the output variables can be influenced by a third
%   argument S, which determines the order (and the occurence) of
%   the X-, Y-, and Z-coordinates in the output. For example
%        [Z,Y]=GINPUT3D(N,'zy')
%   returns the Z- and Y-coordinates of N points.

%    Copyright (c) Mar 6th, 1997 H.R.A.Jagers
%                               The Netherlands

global GINPUT3D_ref_level
global GINPUT3D_ref_direc
global GINPUT3D_excl_direc

b = [];
ax = [];
how_many = inf;
axes_coord = 1;
STR_coords = '';

for i=1:nargin,
  if ischar(varargin{i}),
    if strcmp(varargin{i},'fig'),
      axes_coord = 0;
    else,
      STR_coords = varargin{i};
    end;
  else,
    if ishandle(varargin{i}) & strcmp(get(varargin{i},'type'),'axes'),
      ax=varargin{i};
    else,
      how_many=varargin{i};
    end;
  end;
end;

if strcmp(STR_coords,''),
  if axes_coord,
    coords=[1 2 3];
  else,
    coords=[1 2];
  end;
else,
  coords=abs(STR_coords)-119;
  if any((coords<1) | (coords>3)) | ~isequal(size(unique(coords)),size(coords)), % only x, y and z, and all different
    fprintf(1,'* Invalid string argument: %s.\n',STR_coords);
    return;
  end;
end;

if ~axes_coord,
  if ~isempty(findstr(STR_coords,'z')),
    fprintf(1,'* Z coordinate not available in combination with fig option.\n',STR_coords);
    return;
  end;
end;

if nargout>size(coords,2)+1,
  fprintf(1,'* Too many output variables.\n');
  return;
end;

if axes_coord,
  if isempty(ax),
    ax=gca;
  end;
  fig=get(ax,'parent');
else,
  fig=gcf;
end;
figure(fig);

if how_many == 0,
  ptr_fig = 0;
  while(ptr_fig ~= fig),
    ptr_fig = get(0,'PointerWindow');
  end
  scrn_pt = get(0,'PointerLocation');
  loc = get(fig,'Position');
  pnt = [scrn_pt(1) - loc(1), scrn_pt(2) - loc(2)];
  out1 = pnt(1); y = pnt(2);
elseif how_many < 0,
  fprintf(1,'* Argument must be a positive integer.');
  return;
end

pointer = get(fig,'pointer');
set(fig,'pointer','circle');
if axes_coord,
  axu = get(ax,'units');
  set(ax,'units','normalized');
  handle=ax;
else,
  pos=get(fig,'position');
  handle=axes('units','normalized', ...
              'position',[0 0 1 1], ...
              'xlim',[0 pos(3)], ...
              'ylim',[0 pos(4)], ...
              'visible','off', ...
              'parent',fig);
end;
char = 0;

xrange=get(handle,'xlim');
yrange=get(handle,'ylim');
zrange=get(handle,'zlim');
xlimmode=get(handle,'xlimmode');
ylimmode=get(handle,'ylimmode');
zlimmode=get(handle,'zlimmode');
set(handle,'xlim',xrange);
set(handle,'ylim',yrange);
set(handle,'zlim',zrange);

vw=get(handle,'view');
GINPUT3D_excl_direc=[];
if (any(vw(1)==[-90,0,90,180]) | any(vw(2)==[-90,0,90,180])),
  if vw(1)==0 | vw(1)==180,
    GINPUT3D_excl_direc=[1];
  elseif vw(1)==-90 | vw(1)==90,
    GINPUT3D_excl_direc=[2];
  end;
  if vw(2)==-90 | vw(2)==90,
    GINPUT3D_excl_direc=[1 2];
  elseif vw(2)==0 | vw(2)==180,
    GINPUT3D_excl_direc=[GINPUT3D_excl_direc 3];
  end;
end;

if ismember(3,GINPUT3D_excl_direc),
  if ismember(2,GINPUT3D_excl_direc),
    GINPUT3D_ref_level=xrange(1)+(xrange(2)-xrange(1))/2;
    GINPUT3D_ref_direc=1;
  else,
    GINPUT3D_ref_level=yrange(1)+(yrange(2)-yrange(1))/2;
    GINPUT3D_ref_direc=2;
  end;
else,
  GINPUT3D_ref_level=zrange(1)+(zrange(2)-zrange(1))/2;
  GINPUT3D_ref_direc=3;
end;

l(1)=line(0,0,0,'erasemode','xor', ...
          'color','k', ...
          'parent',handle);
l(2)=line(0,0,0,'erasemode','xor', ...
          'color','k', ...
          'parent',handle);
l(3)=line(0,0,0,'erasemode','xor', ...
          'color','k', ...
          'parent',handle);
set(l(GINPUT3D_ref_direc),'color','b');
l(4)=line(0,0,0,'erasemode','xor', ...
          'color','k', ...
          'parent',handle);

figud=get(fig,'userdata');
set(fig,'userdata',l);
figwbmf=get(fig,'windowbuttonmotionfcn');
set(fig,'windowbuttonmotionfcn','ginput__(1)');
fignumtit=get(fig,'numbertitle');
figname=get(fig,'name');
fighvis=get(fig,'handlevisibility');
set(fig,'numbertitle','off','name',' ','handlevisibility','on');

out1=[];
if ~isempty(coords),
while how_many ~= 0
    keydown = waitforbuttonpress;
    ptr_fig = get(0,'CurrentFigure');
    if(ptr_fig == fig),
       axes(handle); % Protects against user selecting another axis
       if keydown,
         pnt = get(handle, 'CurrentPoint');
         char = get(fig, 'CurrentCharacter');
         button = abs(char);
       else,
         pnt = get(handle, 'CurrentPoint');
         button = get(fig, 'SelectionType');
         if strcmp(button,'open'),
           button = b(max(size(b)));
         elseif strcmp(button,'normal'),
           button = 1;
         elseif strcmp(button,'alt'),
           button = 2;
           if GINPUT3D_ref_direc==1,
             xref=GINPUT3D_ref_level;
             alpha=(xref-pnt(1,1))/(pnt(2,1)-pnt(1,1));
           elseif GINPUT3D_ref_direc==2,
             yref=GINPUT3D_ref_level;
             alpha=(yref-pnt(1,2))/(pnt(2,2)-pnt(1,2));
           elseif GINPUT3D_ref_direc==3,
             zref=GINPUT3D_ref_level;
             alpha=(zref-pnt(1,3))/(pnt(2,3)-pnt(1,3));
           end;
           pntref=pnt(1,:)+alpha*(pnt(2,:)-pnt(1,:));
           if size(GINPUT3D_excl_direc,2)<2,
             if GINPUT3D_ref_direc==1,
               set(l(1),'color','k');
               if ismember(2,GINPUT3D_excl_direc),
                 set(l(3),'color','b');
                 GINPUT3D_ref_direc=3;
               else,
                 set(l(2),'color','b');
                 GINPUT3D_ref_direc=2;
               end;
             elseif GINPUT3D_ref_direc==2,
               set(l(2),'color','k');
               if ismember(3,GINPUT3D_excl_direc),
                 set(l(1),'color','b');
                 GINPUT3D_ref_direc=1;
               else,
                 set(l(3),'color','b');
                 GINPUT3D_ref_direc=3;
               end;
             elseif GINPUT3D_ref_direc==3,
               set(l(3),'color','k');
               if ismember(1,GINPUT3D_excl_direc),
                 set(l(2),'color','b');
                 GINPUT3D_ref_direc=2;
               else,
                 set(l(1),'color','b');
                 GINPUT3D_ref_direc=1;
               end;
             end;
           end;
           GINPUT3D_ref_level=pntref(GINPUT3D_ref_direc);
         elseif strcmp(button,'extend')
           button = 2;
         elseif strcmp(button,'open')
           button = 4;
         else
           error('Invalid mouse selection.')
         end
       end

       if button~=2,
         how_many = how_many - 1;

         if (char == 13 & how_many ~= 0) % char(13) marks end of input
           break;
         end

         if GINPUT3D_ref_direc==1,
           xref=GINPUT3D_ref_level;
           alpha=(xref-pnt(1,1))/(pnt(2,1)-pnt(1,1));
         elseif GINPUT3D_ref_direc==2,
           yref=GINPUT3D_ref_level;
           alpha=(yref-pnt(1,2))/(pnt(2,2)-pnt(1,2));
         elseif GINPUT3D_ref_direc==3,
           zref=GINPUT3D_ref_level;
           alpha=(zref-pnt(1,3))/(pnt(2,3)-pnt(1,3));
         end;
         pntref=pnt(1,:)+alpha*(pnt(2,:)-pnt(1,:));
         out1 = [out1;pntref];
       end;
       refresh(fig);
    end;
end;
else,
  fprintf(1,'* Output coordinates not compatible with current view.\n');
end;

if ~isempty(out1),
  out1=out1(:,coords);
  if nargout > 1
    no=nargout;
    if no==(size(coords,2)+1),
      eval(['out',gui_str(no),'=b;']);
      no=no-1;
    end;
    for i=no:-1:1,
      eval(['out',gui_str(i),'=out1(:,',gui_str(i),');']);
    end;
  end;
end;

delete(l);
if axes_coord,
  set(ax,'units',axu, ...
         'xlimmode',xlimmode, ...
         'ylimmode',ylimmode, ...
         'zlimmode',zlimmode);
else,
  delete(handle);
end;
set(fig,'userdata',figud, ...
        'windowbuttonmotionfcn',figwbmf, ...
        'numbertitle',fignumtit, ...
        'name',figname, ...
        'handlevisibility',fighvis, ...
        'pointer',pointer);
if ~isempty(ax),
  axes(ax);
end;
refresh(fig);