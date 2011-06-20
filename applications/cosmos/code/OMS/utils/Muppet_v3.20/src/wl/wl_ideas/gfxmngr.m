function gfxmngr(cmd),
% GFXMNGR Graphics manager

if nargin==0,
  cmd='initialize';
end;

switch(cmd),
case 'close',
  H1=findobj(allchild(0),'tag','Graphics manager for Matlab (c)');
  delete(H1);
case 'initialize',
  H1=findobj(allchild(0),'tag','Graphics manager for Matlab (c)');
  if isempty(H1),
    ui_gfxmngr;
  else,
    figure(H1);
  end;
case 'addtext',
  H1=findobj(allchild(0),'tag','Graphics manager for Matlab (c)');
  T1=findobj(H1,'tag','message');
  shh=get(0,'showhiddenhandles');
  set(0,'showhiddenhandles','on');
  try,
    set(T1,'string','Select location.');
    waitforbuttonpress; h1=gco;
    set(T1,'string','');
    if isequal(gcf,H1),
      set(0,'showhiddenhandles',shh);
      return;
    end;
    switch get(h1,'type'),
    case {'line','surface','patch','text'},
      h1=get(h1,'parent');
    case {'figure','uicontrol'},
      set(0,'showhiddenhandles',shh);
      return;
    end;
    Pos=get(h1,'currentpoint');
    Pos=Pos(1,:); % get closest point
    set(text(Pos(1),Pos(2),Pos(3),''),'editing','on');
  catch,
  end; % just make sure that showhiddenhandles is set back to its original settings
  set(0,'showhiddenhandles',shh);
case 'copy',
  H1=findobj(allchild(0),'tag','Graphics manager for Matlab (c)');
  T1=findobj(H1,'tag','message');
  shh=get(0,'showhiddenhandles');
  set(0,'showhiddenhandles','on');
  try,
    set(T1,'string','Select an object.');
    waitforbuttonpress; h1=gco;
    set(T1,'string','');
    if isequal(gcf,H1),
      set(0,'showhiddenhandles',shh);
      return;
    end;
    t1=get(h1,'type');
    if strcmp(t1,'figure'),
      h2=copyobj(h1,0);
      s=' ';
      set(h2,'paperposition',get(h1,'paperposition'));
    elseif strcmp(t1,'axes'),
      set(T1,'string','Select a target figure.');
      waitforbuttonpress; h3=gco;
      set(T1,'string','');
      if isequal(gcf,H1),
        set(0,'showhiddenhandles',shh);
        return;
      end;
      switch get(h3,'type'),
      case 'figure',
        h2=copyobj(h1,h3);
      case {'uicontrol','uimenu'},
        h2=copyobj(h1,get(h3,'parent'));
      otherwise,
        switch get(h3,'type'),
        case 'axes',
        otherwise,
          h3=get(h3,'parent');
        end;
        Answer=selmenu(h3,'add axes','transform axes','add children');
        switch lower(Answer),
        case 'add axes',
          h2=copyobj(h1,get(h3,'parent'));
        case 'transform axes',
          h2=copyobj(h1,get(h3,'parent'));
          set(h3,'units',get(h2,'units'));
          set(h2,'position',get(h3,'position'));
          delete(h3);
        case 'add children',
          Ch=allchild(h1);
          Lb=[get(h1,'xlabel') get(h1,'ylabel') get(h1,'zlabel') get(h1,'title')];
          Ch=setdiff(Ch,Lb);
          h2=copyobj(Ch,h3);
        end;
      end;
    elseif strcmp(t1,'uicontrol'),
      set(T1,'string','Select a target figure.');
      waitforbuttonpress; h3=gco;
      set(T1,'string','');
      if isequal(gcf,H1),
        set(0,'showhiddenhandles',shh);
        return;
      end;
      if strcmp(get(h3,'type'),'uicontrol'),
        Answer=selmenu(h3,'replace control','add control');
        switch lower(Answer),
        case 'replace control',
          h2=copyobj(h1,gcf);
          set(h3,'units',get(h2,'units'));
          set(h2,'position',get(h3,'position'));
          delete(h3);
        case 'add control',
          h2=copyobj(h1,gcf);
        end;
      else,
        h2=copyobj(h1,gcf);
      end;
    else, % object in axes
      set(T1,'string','Select a target axes.');
      %axes(get(gco,'parent'));
      waitforbuttonpress; h2=gco;
      set(T1,'string','');
      if isequal(gcf,H1),
        set(0,'showhiddenhandles',shh);
        return;
      end;
      t2=get(h2,'type');
      if strcmp(t2,'figure'),
        axes;
      end;
      h2=copyobj(h1,gca);
      set(h2,'visible','on');
    end;
  catch,
  end; % just make sure that showhiddenhandles is set back to its original settings
  set(0,'showhiddenhandles',shh);
case 'delete',
  H1=findobj(allchild(0),'tag','Graphics manager for Matlab (c)');
  T1=findobj(H1,'tag','message');
  shh=get(0,'showhiddenhandles');
  set(0,'showhiddenhandles','on');
  try,
    set(T1,'string','Select an object.');
    waitforbuttonpress; h1=gco;
    set(T1,'string','');
    if isequal(gcf,H1),
      set(0,'showhiddenhandles',shh);
      return;
    end;
    t1=get(h1,'type');
    if strcmp(t1,'axes'),
      Answer=selmenu(h1,'delete axes','delete children and labels', ...
         'delete children','delete labels');
      switch lower(Answer),
      case 'delete axes',
        delete(h1);
      case 'delete children and labels',
        delete(allchild(h1));
      case 'delete children',
        Ch=allchild(h1);
        Lb=[get(h1,'xlabel') get(h1,'ylabel') get(h1,'zlabel') get(h1,'title')];
        Ch=setdiff(Ch,Lb);
        delete(Ch);
      case 'delete labels',
        Lb=[get(h1,'xlabel') get(h1,'ylabel') get(h1,'zlabel') get(h1,'title')];
        delete(Lb);
      end;
    else, % other object
      delete(h1);
    end;
  catch,
  end; % just make sure that showhiddenhandles is set back to its original settings
  set(0,'showhiddenhandles',shh);
case 'edit',
  H1=findobj(allchild(0),'tag','Graphics manager for Matlab (c)');
  T1=findobj(H1,'tag','message');
  shh=get(0,'showhiddenhandles');
  set(0,'showhiddenhandles','on');
  try,
    set(T1,'string','Select an object.');
    waitforbuttonpress; h1=gco;
    set(T1,'string','');
    if isequal(gcf,H1),
      set(0,'showhiddenhandles',shh);
      return;
    end;
    gc(h1);
  catch,
  end; % just make sure that showhiddenhandles is set back to its original settings
  set(0,'showhiddenhandles',shh);
case 'move',
  H1=findobj(allchild(0),'tag','Graphics manager for Matlab (c)');
  T1=findobj(H1,'tag','message');
  shh=get(0,'showhiddenhandles');
  set(0,'showhiddenhandles','on');
  try,
    set(T1,'string','Select an object.');
    waitforbuttonpress; h1=gco;
    set(T1,'string','');
    t1=get(h1,'type');
    if isequal(gcf,H1),
      set(0,'showhiddenhandles',shh);
      return;
    end;
    if strcmp(t1,'axes'),
      set(T1,'string','Select a target figure.');
      waitforbuttonpress; h3=gco;
      set(T1,'string','');
      if isequal(gcf,H1),
        set(0,'showhiddenhandles',shh);
        return;
      end;
      switch get(h3,'type'),
      case 'figure',
        set(h1,'parent',h3);
      case {'uicontrol','uimenu'},
        set(h1,'parent',gcf);
      otherwise,
        switch get(h3,'type'),
        case 'axes',
        otherwise,
          h3=get(h3,'parent'),
        end;
        Answer=selmenu(h3,'replace axes','add axes');
        switch lower(Answer),
        case 'replace axes',
          set(h1,'parent',get(h3,'parent'));
          set(h3,'units',get(h1,'units'));
          set(h1,'position',get(h3,'position'));
          delete(h3);
        case 'add axes',
          set(h1,'parent',get(h3,'parent'));
        end;
      end;
    elseif strcmp(t1,'uicontrol'),
      set(T1,'string','Select a target figure.');
      waitforbuttonpress; h3=gco;
      set(T1,'string','');
      if isequal(gcf,H1),
        set(0,'showhiddenhandles',shh);
        return;
      end;
      if strcmp(get(h3,'type'),'uicontrol'),
        Answer=selmenu(h3,'replace control','add control');
        switch lower(Answer),
        case 'replace control',
          set(h1,'parent',gcf);
          set(h3,'units',get(h1,'units'));
          set(h1,'position',get(h3,'position'));
          delete(h3);
        case 'add control',
          set(h1,'parent',gcf);
        end;
      else,
        set(h1,'parent',gcf);
      end;
    else, % object in axes
      set(T1,'string','Select a target axes.');
      axes(get(gco,'parent'));
      waitforbuttonpress; h2=gco;
      set(T1,'string','');
      if isequal(gcf,H1),
        set(0,'showhiddenhandles',shh);
        return;
      end;
      t2=get(h2,'type');
      if strcmp(t2,'figure'),
        axes;
      end;
      set(h1,'parent',gca);
    end;
  catch,
  end; % just make sure that showhiddenhandles is set back to its original settings
  set(0,'showhiddenhandles',shh);
end;


function ui_gfxmngr()

ss=get(0,'screensize');

a = figure('Color',[0.8 0.8 0.8], ...
	'HandleVisibility','off', ...
	'IntegerHandle','off', ...
	'MenuBar','none', ...
	'Name','Graphics manager', ...
	'NumberTitle','off', ...
	'Position',[20 ss(4)-190 230 140], ...
	'Resize','off', ...
	'Tag','Graphics manager for Matlab (c)');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'FontSize',12, ...
	'Position',[10 110 210 20], ...
	'Style','text', ...
	'String','', ...
	'Tag','message');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'Callback','gfxmngr copy', ...
	'FontSize',12, ...
	'Position',[10 80 100 20], ...
	'String','copy', ...
	'Tag','copy');
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'Callback','gfxmngr move', ...
	'FontSize',12, ...
	'Position',[10 60 100 20], ...
	'String','move', ...
	'Tag','move');
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'Callback','gfxmngr delete', ...
	'FontSize',12, ...
	'Position',[10 40 100 20], ...
	'String','delete', ...
	'Tag','delete');
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'Callback','gfxmngr addtext', ...
	'FontSize',12, ...
	'Position',[110 80 100 20], ...
	'String','add text', ...
	'Tag','add text');
b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'Callback','gfxmngr edit', ...
	'FontSize',12, ...
	'Position',[110 60 100 20], ...
	'String','edit', ...
	'Tag','edit');

b = uicontrol('Parent',a, ...
	'FontUnits','pixels', ...
	'Callback','gfxmngr close', ...
	'FontSize',12, ...
	'Position',[10 10 210 20], ...
	'String','close', ...
	'Tag','close');
