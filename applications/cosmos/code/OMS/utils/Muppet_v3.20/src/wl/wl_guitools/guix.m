function [guihandle,exists]=guix(handle,command,newhandle)
%GUIX manages the list of GUIs

if ~isstandalone
  mlock
end
persistent GUI_LIST gui_main_active gui_main_cmd_list

if ~iscell(GUI_LIST),
  GUI_LIST={};
end;

if (nargin==0),
  GUI_LIST
elseif (nargin==1),
  if isempty(handle) | (~ishandle(handle)),
    fprintf(1,'* The input parameter must be a graphics handle');
  else,
    i=0;
    while i<size(GUI_LIST,1)
      i=i+1;
      if any(GUI_LIST{i,1}==handle(1)),
        % check whether figure still exists
        guihandle=GUI_LIST{i,2};
        if ishandle(guihandle),
          % check whether figure still contains the GUI
          if strcmp(index(get(guihandle,'tag'),1:9),'guiwindow'),
            set(guihandle,'visible','off');
            set(guihandle,'visible','on');
            exists=1;
            return;
          else,
            % figure tag has changed
            GUI_LIST=[GUI_LIST(1:i-1,:);GUI_LIST(i+1:size(GUI_LIST,1),:)];
            i=i-1;
          end;
        else,
          % figure does not exist anymore
          GUI_LIST=[GUI_LIST(1:i-1,:);GUI_LIST(i+1:size(GUI_LIST,1),:)];
          i=i-1;
        end;
      end;
    end;

    exists=0;
    guihandle=figure('visible','off','menubar','none','units','normalized','position',[.35 .35 .3 .3],'integerhandle','off','handlevisibility','off','tag','guiwindow');
    GUI_LIST=[{handle,guihandle};GUI_LIST];
  end;
elseif (nargin==2),
  if ishandle(handle),
    if strcmp(command,'close'),
      i=0;
      while i<size(GUI_LIST,1)
        i=i+1;
        if GUI_LIST{i,2}==handle,
          GUI_LIST=[GUI_LIST(1:(i-1),:);GUI_LIST((i+1):size(GUI_LIST,1),:)];
          delete(handle);
          if gui_main_active,
            gui_main_cmd_list = cmdstack(gui_main_cmd_list,[0 0 -1]);
          end;
          return;
        end;
      end;
      fprintf(1,'* Parameter one is not a GUI handle');
    elseif strcmp(command,'check'),
      i=0;
      while i<size(GUI_LIST,1)
        i=i+1;
        if GUI_LIST{i,2}==handle,
          guihandle=1;
          return;
        end;
      end;
      guihandle=0;
      return;
    elseif strcmp(command,'type'),
      i=0;
      while i<size(GUI_LIST,1)
        i=i+1;
        if GUI_LIST{i,2}==handle,
          if all(ishandle(GUI_LIST{i,1})),
            typestr=get(GUI_LIST{i,2},'tag');
            if strcmp(typestr,'guiwindow'),
              typestr=get(GUI_LIST{i,1}(1),'type');
            end;
            switch(typestr),
            case 'axes',
              guihandle=1;
            case 'text',
              guihandle=2;
            case 'line',
              guihandle=3;
            case 'patch',
              guihandle=4;
            case 'image',
              guihandle=5;
            case 'figure',
              guihandle=6;
            case 'surface',
              guihandle=7;
            case 'uicontrol',
              guihandle=8;
            case 'uimenu',
              guihandle=9;
            case 'root',
              guihandle=10;
            case 'light',
              guihandle=11;
            case 'guiwindow - border',
              guihandle=12;
            otherwise,
              fprintf(1,'* WARNING: Command issued by a GUI of unknown type.\n');
              guihandle=-2;
            end;
          else,
            if any(ishandle(GUI_LIST{i,1})),
              fprintf(1,'* Some objects have been removed.\n');
              guihandle=0;
            else,
              fprintf(1,'* Object has been removed.\n');
              guihandle=0;
            end;
          end;
          return;
        end;
      end; % unknown GUI
      fprintf(1,'* WARNING: Command issued by unknown GUI.\n');
      guihandle=-1;
      return;
    else,
      fprintf(1,'* Parameter two is not a valid command.\n');
    end;
  else,
    fprintf(1,'* Parameter one is not a GUI handle.\n');
  end;
elseif (nargin==3),
  % since handle is may no longer be valid, no check ishandle(handle)!
  if strcmp(command,'change to')
    if (~ishandle(handle)) & ishandle(newhandle) & strcmp(get(newhandle,'type'),'figure'),
      i=0;
      while i<size(GUI_LIST,1)
        i=i+1;
        if GUI_LIST{i,1}==handle,
          GUI_LIST{i,1}=newhandle;
          return;
        end;
      end;
      fprintf(1,'* Parameter does not correspond to a GUI object');
    else,
      fprintf(1,'* Parameter is still a valid handle, or newhandle is not a valid figure handle.');
    end;
  else,
    fprintf(1,'* Parameter two is not a valid command.\n');
  end;
end;