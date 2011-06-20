function [t,R]=boxedtext(x,y,str,varargin)
%BOXEDTEXT create text in a box
%     BOXEDTEXT(X,Y,String)
%     Create a text just like the TEXT command but with an added
%     yellow bounding 'PostIt' box using RECTANGLE.  Note: the
%     combination is sensitive to changes in size and scale of
%     the parent axes and figure!
%
%     [T,R]=BOXEDTEXT(...) returns the TEXT and RECTANGLE handles.
%
%     BOXEDTEXT(...,'PropertyName',PropertyValue,...) sets the value
%     of the specified text property.  Multiple property values can
%     be set with a single statement.
 

% created by H.R.A.Jagers
%     WL | Delft Hydraulics, bert.jagers@wldelft.nl

if isempty(x) & isempty(y)
  T=gtext(str,varargin{:});
else
  T=text(x,y,str,varargin{:}); % assume units 'data'
end
ax=get(T,'parent');
set(ax,'xlimmode','manual','ylimmode','manual','zlimmode','manual');
r=get(T,'extent');
r0=min(r(3),r(4));
R=rectangle('position',r+0.02*(r0*[-1 0 2 0]+r0*[0 0 0 1]), ...
            'parent',ax, ...
            'facecolor',[1 1 0.7]);
Ch=get(ax,'children');
Ch(Ch==R)=0;
Ch(Ch==T)=R;
Ch(Ch==0)=T;
set(ax,'children',Ch);
if nargout>0,
  t=T;
end