function EntriesOut=ds_loadfield(EntriesIn),

%Entries(#).FileType
%Entries(#).FileName
%Entries(#).EntryName
%Entries(#).EntryParameters
%Entries(#).NumberOfFields

if ~isstruct(EntriesIn),
  EntriesIn=[];
  EntriesIn.FileType='unknown';
  EntriesIn.FileName='';
  EntriesIn.EntryName='none';
  EntriesIn.EntryParameters=[];
  EntriesIn.NumberOfFields=[];
  EntriesIn(1)=[];
end;
EditedEntries=EntriesIn;

% create window 
Handles=ui_ds_loadfield;

% initialize window
Succes=md_filemem('addinterface',Handles.CurrentData,Handles.CloseFile);
set(Handles.EntryAdd,'enable',logicalswitch(isempty(md_filemem('listfiles')),'off','on'));

EntryList={};
if ~isempty(EditedEntries),
  for i=1:length(EditedEntries),
    EntryList{i}=EntryString(EditedEntries(i));
  end;
  set(Handles.EntryList,'string',EntryList);
  set([Handles.EntryList Handles.AddAt Handles.EntryMove Handles.MoveTo Handles.EntryEdit Handles.EntryDel],'enable','on');
end;

% process buttons from window

gui_quit=0;               % Becomes one if the interface has to quit.
stack=[];                 % Contains the stack of commands; read from 'userdata' field of the figure

setudf(Handles.Figure,'CommandStack',{});

while ~gui_quit,

%%*************************************************************************************************
%%%% UPDATE SCREEN BEFORE WAITING FOR COMMAND
%%*************************************************************************************************

  drawnow;

%%*************************************************************************************************
%%%% WAIT UNTIL A COMMAND IS ON THE STACK IN THE USERDATA FIELD OF THE FIGURE
%%*************************************************************************************************

  if ishandle(Handles.Figure),
    if isempty(getudf(Handles.Figure,'CommandStack')),
      waitforudf(Handles.Figure,'CommandStack');
    end;
  end;

%%*************************************************************************************************
%%%% SET POINTER TO WATCH WHILE PROCESSING COMMANDS ON STACK
%%%% FIRST CHECK WHETHER FIGURE STILL EXISTS
%%*************************************************************************************************

  if ishandle(Handles.Figure),
    stack=getudf(Handles.Figure,'CommandStack');
    setudf(Handles.Figure,'CommandStack',{});
%    set(Handles.Figure,'pointer','watch');
  else,
    uiwait(msgbox('Unexpected removal of LoadField window!','modal'));
    gui_quit=1;
  end;

%%*************************************************************************************************
%%%% START OF WHILE COMMANDS ON STACK LOOP
%%*************************************************************************************************

  while ~isempty(stack),
    cmd=stack{1};
    stack=stack(2:size(stack,1),:);

    switch cmd(1),
    case 1,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% open, close, select data file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      switch cmd(2),
      case 1, % open data file
        [Succes,FileInfo]=md_filemem('openfile');
        if Succes,
          set(Handles.EntryAdd,'enable',logicalswitch(isempty(md_filemem('listfiles')),'off','on'));
        end;
      case 2, % close data file
        Succes=md_filemem('closefile');
        set(Handles.EntryAdd,'enable',logicalswitch(isempty(md_filemem('listfiles')),'off','on'));
      case 3, % select data file
        Succes=md_filemem('selectfile',Handles.CurrentData);
      otherwise,
        uiwait(msgbox(['Unknown command: ' xx_str(cmd)],'modal'));
      end;

    case 2,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% add, move entry
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      switch cmd(2),
      case 1, % add entry
        [Succes,FileInfo]=md_filemem('usefile');
        FileData=FileInfo.Data;
        NewEntry.FileType=FileInfo.FileType;
        NewEntry.FileName=FileInfo.FileName;
        NewEntry.EntryName=[];
        NewEntry.EntryParameters=[];
        NewEntry.NumberOfFields=[];

        switch NewEntry.FileType,
        case 'Delft3D-com',
          [NewEntry,NowError]=ds_comfile(NewEntry,FileInfo.Data);
        case 'Delft3D-botm',
          [NewEntry,NowError]=ds_botmfile(NewEntry,FileInfo.Data);
        case 'Delft3D-trim',
          [NewEntry,NowError]=ds_trimfile(NewEntry,FileInfo.Data);
        case 'Delft3D-tram',
          [NewEntry,NowError]=ds_tramfile(NewEntry,FileInfo.Data);
        otherwise,
          uiwait(msgbox(['Don''t know how to edit entries from a ' FileInfo.FileType,' file.'],'modal'));
          NowError=1;
        end;

        if (~NowError) & (~isempty(NewEntry.EntryName)), % no error and no cancel
          % Add entry
          NewEntry=sortfieldnames(NewEntry);            % explicitly sort fieldnames
          EditedEntries=sortfieldnames(EditedEntries);  % before concatenation

          CurrentEntry=get(Handles.EntryList,'value');
  
          EntryList=get(Handles.EntryList,'string');

          if isempty(EditedEntries),
            EditedEntries=NewEntry;
            EntryList={EntryString(NewEntry)};
            CurrentEntry=1;
          else,
            switch get(Handles.AddAt,'value'),
            case 1, % add at top
              EditedEntries=[NewEntry EditedEntries];
              EntryList={EntryString(NewEntry),EntryList{:}};
              CurrentEntry=1;
            case 2, % add above current
              EditedEntries=[EditedEntries(1:(CurrentEntry-1)) NewEntry EditedEntries(CurrentEntry:end)];
              EntryList={EntryList{1:(CurrentEntry-1),:},EntryString(NewEntry),EntryList{CurrentEntry:end,:}};
              % CurrentEntry=CurrentEntry;
            case 3, % add below current
              EditedEntries=[EditedEntries(1:CurrentEntry) NewEntry EditedEntries((CurrentEntry+1):end)];
              EntryList={EntryList{1:CurrentEntry,:},EntryString(NewEntry),EntryList{(CurrentEntry+1):end,:}};
              CurrentEntry=CurrentEntry+1;
            case 4, % add at bottom
              EditedEntries=[EditedEntries NewEntry];
              EntryList{end+1}=EntryString(NewEntry);
              CurrentEntry=length(EditedEntries);
            end;
          end;
          set(Handles.EntryList,'string',EntryList,'value',CurrentEntry);
          set([Handles.AddAt Handles.EntryList Handles.EntryMove Handles.MoveTo Handles.EntryEdit Handles.EntryDel],'enable','on');
        end;

      case 2, % move entry
        CurrentEntry=get(Handles.EntryList,'value');

        ReorderedEntries=1:length(EditedEntries);
        switch get(Handles.MoveTo,'value'),
        case 1, % move to top
          ReorderedEntries=[CurrentEntry setdiff(ReorderedEntries,CurrentEntry)];
          CurrentEntry=1;
        case 2, % move one up
          if CurrentEntry>1,
            ReorderedEntries(CurrentEntry-1)=CurrentEntry;
            ReorderedEntries(CurrentEntry)=CurrentEntry-1;
            CurrentEntry=CurrentEntry-1;
          end;
        case 3, % move one down
          if CurrentEntry<length(EditedEntries),
            ReorderedEntries(CurrentEntry+1)=CurrentEntry;
            ReorderedEntries(CurrentEntry)=CurrentEntry+1;
            CurrentEntry=CurrentEntry+1;
          end;
        case 4, % move to bottom
          ReorderedEntries=[setdiff(ReorderedEntries,CurrentEntry) CurrentEntry];
          CurrentEntry=length(EditedEntries);
        end;

        EditedEntries=EditedEntries(ReorderedEntries);
        EntryList=get(Handles.EntryList,'string');
        EntryList=EntryList(ReorderedEntries);
        set(Handles.EntryList,'string',EntryList,'value',CurrentEntry);
      otherwise,
        uiwait(msgbox(['Unknown command: ' xx_str(cmd)],'modal'));
      end;

    case 3,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% delete, edit entry
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      switch cmd(2),
      case 1, % delete entry
        CurrentEntry=get(Handles.EntryList,'value');
        EditedEntries(CurrentEntry)=[];
        EntryList=get(Handles.EntryList,'string');
        EntryList(CurrentEntry)=[];
        CurrentEntry=max(1,CurrentEntry-1);
        set(Handles.EntryList,'string',EntryList,'value',CurrentEntry);
        if isempty(EditedEntries),
          set([Handles.AddAt Handles.EntryList Handles.EntryMove Handles.MoveTo Handles.EntryEdit Handles.EntryDel],'enable','off');
        end;
      case 2, % edit entry
        CurrentEntry=get(Handles.EntryList,'value');
        FileData=ideas('opendata',EditedEntries(CurrentEntry).FileType,EditedEntries(CurrentEntry).FileName);
        switch EditedEntries(CurrentEntry).FileType,
        case 'Delft3D-com',
          EditedEntries(CurrentEntry)=ds_comfile(EditedEntries(CurrentEntry),FileData,'edit');
        case 'Delft3D-botm',
          EditedEntries(CurrentEntry)=ds_botmfile(EditedEntries(CurrentEntry),FileData,'edit');
        case 'Delft3D-trim',
          EditedEntries(CurrentEntry)=ds_trimfile(EditedEntries(CurrentEntry),FileData,'edit');
        case 'Delft3D-tram',
          EditedEntries(CurrentEntry)=ds_tramfile(EditedEntries(CurrentEntry),FileData,'edit');
        otherwise,
          uiwait(msgbox(['Don''t know how to edit entries from a ' EditedEntries(CurrentEntry).FileType,' file.'],'modal'));
        end;
        EntryList=get(Handles.EntryList,'string');
        EntryList{CurrentEntry}=EntryString(EditedEntries(CurrentEntry));
        set(Handles.EntryList,'string',EntryList,'value',CurrentEntry);
      otherwise,
        uiwait(msgbox(['Unknown command: ' xx_str(cmd)],'modal'));
      end;

    case 4,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% reset, accept
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      switch cmd(2),
      case 1, % reset
        EditedEntries=EntriesIn;
        EntryList={};
        if ~isempty(EditedEntries),
          for i=1:length(EditedEntries),
            EntryList{i}=EntryString(EditedEntries(i));
          end;
          set(Handles.EntryList,'string',EntryList,'value',1);
          set([Handles.EntryList Handles.EntryMove Handles.MoveTo Handles.EntryEdit Handles.EntryDel],'enable','on');
        else,
          EntryList={};
          set(Handles.EntryList,'string',EntryList,'value',1);
          set([Handles.EntryList Handles.EntryMove Handles.MoveTo Handles.EntryEdit Handles.EntryDel],'enable','off');
        end;
      case 2, % accept
        gui_quit=1;
        if length(EditedEntries)>0,
          FieldSize=EditedEntries(1).FieldSize;
        end;
        for i=1:length(EditedEntries),
          if (~isequal(FieldSize,EditedEntries(i).FieldSize)) & gui_quit,
            uiwait(msgbox('All entries should be of equal size','modal'));
            gui_quit=0;
          end;
        end;
      otherwise,
        uiwait(msgbox(['Unknown command: ' xx_str(cmd)],'modal'));
      end;

    case 5,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% list menu: load, save
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      switch cmd(2),
      case 1, % load
        EditedEntries=lf_load;
        set(Handles.EntryAdd,'enable',logicalswitch(isempty(md_filemem('listfiles')),'off','on'));
        EntryList={};
        if ~isempty(EditedEntries),
          for i=1:length(EditedEntries),
            EntryList{i}=EntryString(EditedEntries(i));
          end;
          set(Handles.EntryList,'string',EntryList,'value',1);
          set([Handles.EntryList Handles.EntryMove Handles.MoveTo Handles.EntryEdit Handles.EntryDel],'enable','on');
        else,
          EntryList={};
          set(Handles.EntryList,'string',EntryList,'value',1);
          set([Handles.EntryList Handles.EntryMove Handles.MoveTo Handles.EntryEdit Handles.EntryDel],'enable','off');
        end;
      case 2, % save
        lf_save(EditedEntries);
      otherwise,
        uiwait(msgbox(['Unknown command: ' xx_str(cmd)],'modal'));
      end;

    otherwise,
      uiwait(msgbox(['Unknown command: ' xx_str(cmd)],'modal'));
    end;
  end;
%%*************************************************************************************************
%%%% END OF WHILE COMMANDS ON STACK LOOP
%%*************************************************************************************************

%%*************************************************************************************************
%%%% RESET POINTER
%%*************************************************************************************************

  if ishandle(Handles.Figure),
%    set(Handles.Figure,'pointer','arrow');
  end;

end;

%*-------------------------------------------------------------------------------------------------
%* END OF EDITING LOOP 
%*-------------------------------------------------------------------------------------------------

%*-------------------------------------------------------------------------------------------------
%* DELETE FIGURE IF IT STILL EXISTS
%*-------------------------------------------------------------------------------------------------

if ishandle(Handles.Figure),
  delete(Handles.Figure);
end;

if nargout>0,
  EntriesOut=EditedEntries;
end;

function Str=EntryString(Entry);
if length(Entry.FieldSize)==1,
  Size=['[' num2str(Entry.FieldSize) ']'];
else,
  Size=xx_str(Entry.FieldSize);
end;
Str=[num2str(Entry.NumberOfFields) 'x ' Entry.EntryName ' ' Size ' < ' Entry.FileType ' : ' Entry.FileName];