function panax(cmd,ax)
%PANAX Pan and zoom functionality for axes
%
%    PANAX
%    Turn panning and zooming on for current
%    axes. Left: zoom in, Right: zoom out,
%    Middle: pan.
%
%    PANAX OFF
%    Turn panning and zooming off for current
%    axes.
%
%    PANAX(AX)
%    PANAX(AX,'OFF')
%    Applies to AX instead of current axes.


if nargin==0
   cmd=get(0,'currentfigure');
end
if ~ischar(cmd)
   fig=cmd;
   uitb=findall(fig,'type','uitoolbar');
   if isempty(uitb)
      uitb=uitoolbar('parent',fig);
   else
      uitb=uitb(1);
   end
   if isempty(fig)
      return
   end
   if ~isempty(findobj(gcbf,'tag','panax_pan'))
      return
   end
   zoomin= [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
      1 1 1 1 1 1 1 1 1 1 1 1 1 0 1
      1 1 1 1 1 1 1 1 1 1 1 1 0 0 0
      1 1 1 1 1 1 1 1 1 1 1 0 0 0 1
      1 1 1 1 0 0 0 0 1 1 0 0 0 1 1
      1 1 0 0 1 1 1 1 0 0 0 0 1 1 1
      1 0 1 1 1 1 1 1 1 1 0 1 1 1 1
      1 0 1 1 1 0 0 1 1 1 0 1 1 1 1
      0 1 1 1 1 0 0 1 1 1 1 0 1 1 1
      0 1 1 0 0 0 0 0 0 1 1 0 1 1 1
      0 1 1 0 0 0 0 0 0 1 1 0 1 1 1
      0 1 1 1 1 0 0 1 1 1 1 0 1 1 1
      1 0 1 1 1 0 0 1 1 1 0 1 1 1 1
      1 0 1 1 1 1 1 1 1 1 0 1 1 1 1
      1 1 0 0 1 1 1 1 0 0 1 1 1 1 1
      1 1 1 1 0 0 0 0 1 1 1 1 1 1 1];
   zoomin(logical(zoomin))=NaN; zoomin=repmat(zoomin',[1 1 3]);
   zoomout=zoomin;
   zoomout([4 5 8 9],[10 11],:)=NaN;
   hand=   [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
      1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
      1 1 1 1 1 0 0 0 0 0 0 1 1 1 1
      1 1 1 1 0 1 1 1 1 1 1 0 1 1 1
      1 1 0 0 0 0 0 0 1 1 1 1 0 0 0
      1 0 1 1 1 1 1 1 1 1 1 1 1 1 0
      1 1 0 0 0 0 0 0 1 1 1 1 1 1 0
      1 0 1 1 1 1 1 1 1 1 1 1 1 1 0
      1 1 0 0 0 0 0 0 1 1 1 1 1 1 0
      1 0 1 1 1 1 1 1 1 1 1 1 1 1 0
      1 1 0 0 0 0 0 0 1 1 1 1 0 0 0
      1 1 0 1 1 1 1 1 1 1 1 0 1 1 1
      1 1 1 0 0 0 0 0 0 0 0 1 1 1 1
      1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
      1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
      1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
   hand(logical(hand))=NaN; hand=repmat(hand',[1 1 3]);
   uitoggletool('parent',uitb,'tag','panax_zoom_in','tooltipstring','zoom in','enable','on','clickedcallback','panax togglezoomin','cdata',zoomin,'userdata','','separator','on')
   uitoggletool('parent',uitb,'tag','panax_zoom_out','tooltipstring','zoom out','enable','on','clickedcallback','panax togglezoomout','cdata',zoomout)
   uitoggletool('parent',uitb,'tag','panax_pan','tooltipstring','pan','enable','on','clickedcallback','panax togglepan','cdata',hand)
   set(fig,'windowbuttondownfcn','panax down')
   return
end
wireframe=0;
switch lower(cmd)
   case 'togglezoomin'
      if isequal(get(gcbo,'state'),'on')
         set(findall(gcbf,'tag','panax_pan'),'state','off')
         set(findall(gcbf,'tag','panax_zoom_out'),'state','off')
         set(gcbo,'userdata','zoomin')
      else
         set(gcbo,'userdata','')
      end
   case 'togglezoomout'
      if isequal(get(gcbo,'state'),'on')
         set(findall(gcbf,'tag','panax_pan'),'state','off')
         set(findall(gcbf,'tag','panax_zoom_in'),'state','off','userdata','zoomout')
      else
         set(findall(gcbf,'tag','panax_zoom_in'),'userdata','')
      end
   case 'togglepan'
      if isequal(get(gcbo,'state'),'on')
         set(findall(gcbf,'tag','panax_zoom_out'),'state','off')
         set(findall(gcbf,'tag','panax_zoom_in'),'state','off','userdata','pan')
      else
         set(findall(gcbf,'tag','panax_zoom_in'),'userdata','')
      end
   case 'down'
      % Activate axis that is clicked in
      allAxes = findall(datachildren(gcbf),'flat','type','axes');
      ZOOM_found = 0;
      
      % this test may be causing failures for 3d axes
      for i=1:length(allAxes)
         ax=allAxes(i);
         ZOOM_Pt1 = get(ax,'CurrentPoint');
         xlim = get(ax,'xlim');
         ylim = get(ax,'ylim');
         if (xlim(1) <= ZOOM_Pt1(1,1) & ZOOM_Pt1(1,1) <= xlim(2) & ...
               ylim(1) <= ZOOM_Pt1(1,2) & ZOOM_Pt1(1,2) <= ylim(2))
            ZOOM_found = 1;
            break
         end
      end
      
      if ZOOM_found==0
         return
      end
      
      fig=get(ax,'parent');
      cp1=get(ax,'currentpoint'); cp1=cp1(1,1:2);
      xl=get(ax,'xlim');
      yl=get(ax,'ylim');
      panaxclass=get(findall(gcbf,'tag','panax_zoom_in'),'userdata');
      seltype=get(fig,'selectiontype');
      if (isequal(panaxclass,'zoomin') | isequal(panaxclass,'zoomout')) & isequal(seltype,'open')
         set(ax,'xlim',limits(ax,'x'),'ylim',limits(ax,'y'))
      elseif (isequal(panaxclass,'zoomin') & isequal(seltype,'normal')) | (isequal(panaxclass,'zoomout') & isequal(seltype,'alt'))
         rbbox;
         cp2=get(ax,'currentpoint'); cp2=cp2(1,1:2);
         if min(abs(cp1-cp2)) >= 0.01*min(diff(xl),diff(yl))
            set(ax,'xlim',sort(cat(2,cp1(1),cp2(1))));
            set(ax,'ylim',sort(cat(2,cp1(2),cp2(2))));
         else
            cp=(cp1+cp2)/2;
            set(ax,'xlim',cp(1)+0.25*[-1 1]*diff(xl));
            set(ax,'ylim',cp(2)+0.25*[-1 1]*diff(xl));
         end
      elseif (isequal(panaxclass,'zoomin') & isequal(seltype,'alt')) | (isequal(panaxclass,'zoomout') & isequal(seltype,'normal'))
         rbbox;
         cp2=get(ax,'currentpoint'); cp2=cp2(1,1:2);
         if min(abs(cp1-cp2)) >= 0.01*min(diff(xl),diff(yl))
            xl0=sort(cat(2,cp1(1),cp2(1)));
            x1=diff(xl)/diff(xl0)*(xl(1)-xl0(1))+xl(1);
            x2=x1+diff(xl)^2/diff(xl0);
            set(ax,'xlim',[x1 x2]);
            yl0=sort(cat(2,cp1(2),cp2(2)));
            y1=diff(yl)/diff(yl0)*(yl(1)-yl0(1))+yl(1);
            y2=y1+diff(yl)^2/diff(yl0);
            set(ax,'ylim',[y1 y2]);
         else
            cp=(cp1+cp2)/2;
            set(ax,'xlim',cp(1)+[-1 1]*diff(xl));
            set(ax,'ylim',cp(2)+[-1 1]*diff(xl));
         end
      elseif isequal(panaxclass,'pan') & isequal(seltype,'normal')
         if wireframe
            cu=get(ax,'units');
            set(ax,'units','pixels');
            P1=get(ax,'position');
            set(ax,'units',cu);
            dragrect(P1);
            cp2=get(ax,'currentpoint'); cp2=cp2(1,1:2);
            set(ax,'xlim',get(ax,'xlim')+cp1(1)-cp2(1));
            set(ax,'ylim',get(ax,'ylim')+cp1(2)-cp2(2));
         else
            params={'units','position','xlim','ylim','zlim','dataaspectratio','plotboxaspectratio'};
            vals=get(ax,params);
            dumax=axes('visible','off', ...
               params,vals);
            setappdata(fig,'PanaxObject',ax)
            setappdata(fig,'PanaxDummyObject',dumax)
            setappdata(fig,'PanaxPoint1',cp1)
            set(fig,'windowbuttonmotionfcn','panax motion')
            set(fig,'windowbuttonupfcn','panax up')
         end
      end
      %[seltype 'out']
   case 'motion'
      fig=gcbf;
      ax=getappdata(fig,'PanaxObject');
      dumax=getappdata(fig,'PanaxDummyObject');
      cp1=getappdata(fig,'PanaxPoint1');
      cp2=get(dumax,'currentpoint'); cp2=cp2(1,1:2);
      set(ax,'xlim',get(dumax,'xlim')+cp1(1)-cp2(1));
      set(ax,'ylim',get(dumax,'ylim')+cp1(2)-cp2(2));
   case 'up'
      fig=gcbf;
      set(fig,'windowbuttonmotionfcn','')
      set(fig,'windowbuttonupfcn','')
      dumax=getappdata(fig,'PanaxDummyObject');
      delete(dumax);
      rmappdata(fig,'PanaxDummyObject');
      rmappdata(fig,'PanaxObject')
      rmappdata(fig,'PanaxPoint1')
   case 'off'
      if nargin==1
         fig=get(0,'currentfigure');
         ax=get(fig,'currentaxes');
      end
      set(ax,'buttondownfcn','')
end