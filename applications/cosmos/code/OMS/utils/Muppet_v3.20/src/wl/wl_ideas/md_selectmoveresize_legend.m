function md_selectmoveresize_legend(ax),

if (nargin==1) | isempty(gcbf), % initialize
  if nargin==0,
    fig=get(0,'currentfigure');
    if isempty(fig),
      return;
    else,
      ax=get(fig,'currentaxes');
      if isempty(ax),
        return;
      end;
    end;
  end;
  axoptions=get(ax,'userdata');
  H=handles(ob_ideas(axoptions.Object));
  ax2=axes('parent',get(ax,'parent'), ...
           'units','normalized', ...
           'position',axoptions.Info.Pos, ...
           'visible','on', ...
           'color','none', ...
           'box','on', ...
           'xtick',[], ...
           'ytick',[], ...
           'ztick',[], ...
           'xcolor',[.75 .75 .75], ...
           'ycolor',[.75 .75 .75], ...
           'zcolor',[.75 .75 .75], ...
           'parent',get(ax,'parent'), ...
           'userdata',H);
  set(get(ax2,'xlabel'),'string','');
  set(get(ax2,'ylabel'),'string','');
  set(get(ax2,'zlabel'),'string','');
  set(ax2,'selected','on', ...
          'selectionhighlight','on', ...
          'buttondownfcn','md_selectmoveresize_legend;');
else,
  switch get(gcbf,'selectiontype'),
  case 'normal',
    hvis=get(gcbf,'handlevisibility');
    set(gcbf,'handlevisibility','on');
    selectmoveresize;
    set(gcbf,'handlevisibility',hvis);
    Obs=findobj(gcbf,'buttondownfcn','md_selectmoveresize_legend;','selected','on');
    for c=Obs',
      H=get(c,'userdata');
      Pos=get(c,'position'); % using new position of axes ...

      %OldVrt=get(H(2),'vertices'); % ... update position of patch
      %Vrt=[Pos(1) Pos(2) -1; Pos(1) Pos(2)+Pos(4) -1; Pos(1)+Pos(3) Pos(2)+Pos(4) -1; Pos(1)+Pos(3) Pos(2) -1];
      %set(H(2),'vertices',Vrt);

      axoptions=get(H(1),'userdata'); % ... update position information
      %ShiftOnly=(Pos(3)==axoptions.Info.Pos(3)); % width constant (for the moment no check on Pos(4)=height)
      axoptions.Info.Pos=Pos;
      set(H(1),'userdata',axoptions);
      
      if 0, %ShiftOnly, % if fast update is possible ...
        Shift=Vrt([1 6])-OldVrt([1 6]);
        cl=setdiff(transpose(get(H(1),'children')),H(2));
        for i=cl,
          switch get(i,'type'),
          case 'text',
            TmpPos=get(i,'position');
            TmpPos(1:2)=TmpPos(1:2)+Shift(1:2);
            set(i,'position',TmpPos);
          otherwise,
            TmpX=get(i,'xdata');
            TmpY=get(i,'Ydata');
            set(i,'xdata',TmpX+Shift(1),'ydata',TmpY+Shift(2));
          end;
        end;
      else, % no fast update possible ... automatically delete and recreate objects
        refresh(axoptions.Object);
      end;
    end;
  case 'alt',
    set(gcbo,'selected','off');
  otherwise,
    delete(gcbo);
    set(gcbo,'selected','off','buttondownfcn','');
  end;
end;
