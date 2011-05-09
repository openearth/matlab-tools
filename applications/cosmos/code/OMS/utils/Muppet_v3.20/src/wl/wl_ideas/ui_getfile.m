function [OutFileName,OutFileType]=ui_getfile(DefFileName,DefFileType),
%UI_GETFILE User interface for opening various files
%      [OutFileName,OutFileType]= ...
%         UI_GETFILE(DefFileName,DefFileType)

%#function stackudf
%#function waitforudf
%#function setudf
%#function getudf

AllFilesStr='all files (*.*)';
UserSpecFT=specdir;
FTypes={AllFilesStr UserSpecFT{:}};
OutFileName='';
OutFileType='';
if nargin<2,
  FileType=AllFilesStr;
  if nargin<1,
    FileName=[cd filesep];
  else,
    FileName=DefFileName;
  end;
else,
  FileName=DefFileName;
  FileType=DefFileType;
end;

if strmatch(lower(FileType),{'Delft3D-com','Delft3D-botm','Delft3D-trim','Delft3D-tram'}),
  FileType='nefis file';
end;

FileTypeNr=strmatch(lower(FileType),lower(FTypes),'exact');
if isempty(FileTypeNr),
  FileTypeNr=strmatch(lower(FileType),lower(FTypes));
  if ~isequal(size(FileTypeNr),[1 1]),
    FileTypeNr=1;
    FileType=AllFilesStr;
  else,
    FileType=FTypes{FileTypeNr};
  end;
end;

XX=xx_constants;

File_Width=200;
Dir_Width=150;
Button_Width=100;
List_Height=10*XX.But.Height;

Fig_Width=3*XX.Margin+Dir_Width+File_Width;
Fig_Height=4*XX.Margin+2*XX.But.Height+List_Height;

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=xx_ui_ini('position',rect,'name','Open','color',XX.Clr.LightGray);

Ax=axes( ...
   'units','pixels','position',[1 1 Fig_Width Fig_Height], ...
   'xlim',[0 Fig_Width-1],'ylim',[0 Fig_Height-1], ...
   'visible','off', ...
   'parent',fig);


rect = [XX.Margin XX.Margin Fig_Width-File_Width-Button_Width-4*XX.Margin XX.Txt.Height];
uicontrol('style','text', ...
          'position',rect, ...
          'string','filetype', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect(1) = rect(1)+rect(3)+XX.Margin;
rect(3) = File_Width;
rect(4) = XX.But.Height;
H.FType=uicontrol('style','popupmenu', ...
          'position',rect, ...
          'string',FTypes, ...
          'backgroundcolor',XX.Clr.White, ...
          'parent',fig, ...
          'value',FileTypeNr, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',2)');

rect(1) = rect(1)+rect(3)+XX.Margin;
rect(3) = Button_Width;
H.Open=uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','open', ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',1)');

rect(1) = XX.Margin;
rect(2) = rect(2)+rect(4)+XX.Margin;
rect(3) = Fig_Width-File_Width-Button_Width-4*XX.Margin;
rect(4) = XX.Txt.Height;
uicontrol('style','text', ...
          'position',rect, ...
          'string','filename', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect(1) = rect(1)+rect(3)+XX.Margin;
rect(3) = File_Width;
rect(4) = XX.But.Height;
H.FName=uicontrol('style','edit', ...
          'position',rect, ...
          'string','', ...
          'backgroundcolor',XX.Clr.White, ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',3)');

rect(1) = rect(1)+rect(3)+XX.Margin;
rect(3) = Button_Width;
H.Cancel=uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','cancel', ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',0)');


rect(1) = XX.Margin;
rect(2) = rect(2)+rect(4)+XX.Margin;
rect(3) = Dir_Width;
rect(4) = List_Height;
H.Dir=uicontrol('style','listbox', ...
          'position',rect, ...
          'string','', ...
          'backgroundcolor',XX.Clr.White, ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',4)');

rect(1) = rect(1)+rect(3)+XX.Margin;
rect(3) = File_Width;
H.File=uicontrol('style','listbox', ...
          'position',rect, ...
          'string','', ...
          'backgroundcolor',XX.Clr.White, ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',5)');

set(fig,'visible','on');
setudf(fig,'CommandStack',{});

gui_quit=0;
ui_refresh=1;
DirPath=[cd filesep];
while ~gui_quit,
  if ui_refresh,
    set(fig,'pointer','watch');
    if isempty(FileName),
      FileName=DirPath;
    elseif FileName(end)~=filesep,
      if exist([FileName filesep],'dir'),
        FileName=[FileName filesep];
      elseif ~exist(FileName,'file'),
        FSep=findstr(filesep,FileName);
        i=length(FSep);
        while (i>=1) & ~exist(FileName(1:FSep(i)),'dir'),
          i=i-1;
        end;
        if i>=1,
          FileName=FileName(1:FSep(i));
        else,
          FileName=[cd filesep];
        end;
      end;
    end;
    FSep=findstr(filesep,FileName);
    DirPath=FileName(1:FSep(end));
    FileName=FileName((FSep(end)+1):end);

    set(H.File,'max',2,'value',[],'string','Updating directory ...','enable','inactive');
    drawnow;

    TempDir=pwd;
    try,
      cd(DirPath);
    catch,
      uiwait(msgbox(['Error changing to: ',DirPath],'modal'));
    end;
    DirPath=pwd; % get correct path description
    D=dir;       % get dir
    cd(TempDir);

    if strcmp(DirPath(end),filesep),
      FileName=[DirPath FileName];
    else,
      FileName=[DirPath filesep FileName];
    end;
    FSep=findstr(filesep,FileName);
    FSec=[1 FSep(1:(end-1))+1; FSep];
    DirStr={};
    DirNoSpace={};
    for i=1:size(FSec,2),
      DirNoSpace{i}=FileName(FSec(1,i):FSec(2,i));
      DirStr{i}=[char(32*ones(1,2*i)) FileName(FSec(1,i):FSec(2,i))];
    end;

    nbase=length(DirStr);
    for i=1:length(D),
      if D(i).isdir & ~isequal(D(i).name,'.') & ~isequal(D(i).name,'..'),
        DirNoSpace{end+1}=[D(i).name filesep];
        DirStr{end+1}=[char(32*ones(1,2*size(FSec,2)+2)) D(i).name filesep];
      end;
    end;
    [DirStr((nbase+1):end),sorted]=sort(DirStr((nbase+1):end));
    DirNoSpace((nbase+1):end)=DirNoSpace(nbase+sorted);
    set(H.Dir,'string',DirStr,'enable','on','value',size(FSec,2));
  
    set(H.File,'max',2,'value',[],'string',['Searching ' FileType ' ...'],'enable','inactive');
    drawnow;
  
    if isequal(FileType,AllFilesStr);
      F={D(~[D(:).isdir]).name};
      if ~isempty(F) & isnumeric(F{1}), % F={[]} <-- version 5 oddity
        F={};
      end;
    else,
      try,
        F=specdir(DirPath,FileType,D);
      catch,
        uiwait(msgbox(lasterr,'modal'));
        FileType=AllFilesStr;
        set(H.FType,'value',1);
        F={D(~[D(:).isdir]).name};
        if ~isempty(F) & isnumeric(F{1}), % F={[]} <-- version 5 oddity
          F={};
        end;
      end;
    end;
    if ~isequal(DirPath(end),filesep), DirPath=[DirPath filesep]; end;
  
    if isempty(F),
      set(H.File,'string','<no files>','max',2,'value',[],'enable','off');
      set(H.FName,'string','');
      set(H.Open,'enable','off');
      FileName=DirPath;
    else,
      LocalFileName=FileName(length(DirPath)+1:end);
      FileNr=strmatch(LocalFileName,F,'exact');
      if ~isequal(size(FileNr),[1 1]),
        FileNr=strmatch(LocalFileName,F);
      end;
      if ~isequal(size(FileNr),[1 1]),
        FileNr=1;
      end;
      F=sort(F);
      set(H.File,'string',F,'enable','on','value',1,'max',1,'value',FileNr);
      set(H.FName,'string',F{FileNr});
      set(H.Open,'enable','on');
      FileName=[DirPath F{FileNr}];
    end;
    set(fig,'pointer','arrow');
  end;

  if ishandle(fig),
    if isempty(getudf(fig,'CommandStack')),
      waitforudf(fig,'CommandStack');
    end;
  end;
  if ishandle(fig),
    stack=getudf(fig,'CommandStack');
    setudf(fig,'CommandStack',{});
  else,
    uiwait(msgbox('Unexpected removal of Edit window!','modal'));
    gui_quit=1;
  end;

  ui_refresh=0;
  while ~isempty(stack),
    Cmd=stack{1};
    stack=stack(2:size(stack,1),:);
    switch Cmd,
    case 0, % cancel
      gui_quit=1;
    case 1, % open
      if ~strcmp(FileType,AllFilesStr),
        AcceptPressed=1;
        OutFileType=FileType;
        OutFileName=FileName;
        gui_quit=1;
      else,
        uiwait(msgbox('Please select filetype','modal'));
      end;
    case 2, % filetype
      FileType=FTypes{get(H.FType,'value')};
      ui_refresh=1;
    case 3, % filename
      FileName=deblank(get(H.FName,'string'));
      if isempty(FileName),
        ui_refresh=1;
      else,
        FN_in_list=strmatch(FileName,F,'exact');
        if isempty(FN_in_list),
          FN_in_list=strmatch(FileName,F);
        end;
        if isequal(size(FN_in_list),[1 1]),
          % only filelist value and filename need refreshing
          set(H.File,'value',FN_in_list)
          set(H.FName,'string',F{FN_in_list})
          FileName=[DirPath F{get(H.File,'value')}];
        else,
          % file in other directory or not in list
          if filesep==FileName(1), % directory from root UNIX or NETWORK drive
          elseif (length(FileName)>=2) & (isequal(FileName(2),':')), % WINDOWS drive
          else,
            % not a file, not a path from root
            % path from current directory
            FileName=[DirPath filesep FileName];
          end;
          ui_refresh=1;
        end;
      end;
    case 4, % directory selected
      Dir=get(H.Dir,'value');
      if Dir<=size(FSec,2), % higher directory
        FileName=[DirNoSpace{1:Dir} FileName((FSec(2,end)+1):end)];
      else, % subdirectory
        Dir=DirNoSpace{Dir};
        FileName=[DirNoSpace{1:size(FSec,2)} Dir FileName((FSec(2,end)+1):end)];
      end;
      ui_refresh=1;
    case 5, % file selected
      FileName=[DirPath F{get(H.File,'value')}];
      % only filename needs refreshing
      set(H.FName,'string',F{get(H.File,'value')});
    end;
  end;
end;
delete(fig);