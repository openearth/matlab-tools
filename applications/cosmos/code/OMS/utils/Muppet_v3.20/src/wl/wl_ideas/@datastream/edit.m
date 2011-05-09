function OutputStream=edit(InputStream,Title),

if nargin<2,
  Title=['Input for ',InputStream.Type,' stream.'];
end;

OutputStream=InputStream;
Specs=OutputStream.Specs;
switch lower(InputStream.Type),
case 'group',
  OutputStream=Local_edit_group(OutputStream,Title);
case 'loadfield',
  Specs.LoadField=ds_loadfield(Specs.LoadField);
  OutputStream.Specs=Specs;
case {'scalarmultiply'},
  prompt={'Value:'};
  def={num2str(Specs.Scalar)};
  lineNo=1;
  Correct=0;
  while ~Correct,
    answer=inputdlg(prompt,Title,lineNo,def);
    if isempty(answer),
      return;
    end;
    Correct=1;
    Specs.Scalar=eval(answer{1},NaN);
    if ~isequal(size(Specs.Scalar),[1 1]) | ~isnumeric(Specs.Scalar) | ~isfinite(Specs.Scalar),
      Correct=0;
    end;
    def=answer;
  end;
  OutputStream.Specs=Specs;
case {'power'},
  prompt={'Power:'};
  def={num2str(Specs.Scalar)};
  lineNo=1;
  Correct=0;
  while ~Correct,
    answer=inputdlg(prompt,Title,lineNo,def);
    if isempty(answer),
      return;
    end;
    Correct=1;
    Specs.Scalar=eval(answer{1},NaN);
    if ~isequal(size(Specs.Scalar),[1 1]) | ~isnumeric(Specs.Scalar) | ~isfinite(Specs.Scalar),
      Correct=0;
    elseif (abs(Specs.Scalar)<1e-3) | (abs(Specs.Scalar)>1e3),
      Correct=0;
    end;
    def=answer;
  end;
  OutputStream.Specs=Specs;
case {'constantmatrix'},
  prompt={'Size:','Value:'};
  def={gui_str(Specs.Size) num2str(Specs.Scalar)};
  lineNo=1;
  Correct=0;
  while ~Correct,
    answer=inputdlg(prompt,Title,lineNo,def);
    if isempty(answer),
      return;
    end;
    Correct=1;
    Specs.Size=eval(answer{1},NaN);
    if ~isnumeric(Specs.Size) | ~isequal(size(Specs.Size,1),1) | ~all(isfinite(Specs.Size(:))) | ~all(Specs.Size(:)>0) | ~isequal(Specs.Size,round(Specs.Size)),
      Correct=0;
    end;
    Specs.Scalar=eval(answer{2},NaN);
    if ~isequal(size(Specs.Scalar),[1 1]) | ~isnumeric(Specs.Scalar) | ~isfinite(Specs.Scalar),
      Correct=0;
    end;
    def=answer;
  end;
  OutputStream.Specs=Specs;
case 'fieldrenumber',
  prompt={'Pass fields:'};
  def={gui_str(Specs.Renumber)};
  lineNo=1;
  Correct=0;
  while ~Correct,
    answer=inputdlg(prompt,Title,lineNo,def);
    if isempty(answer),
      return;
    end;
    Correct=1;
    Specs.Renumber=eval(answer{1},NaN);
    if ~isnumeric(Specs.Renumber) | ~all(isfinite(Specs.Renumber(:))),
      Correct=0;
    end;
    def=answer;
  end;
  OutputStream.Specs=Specs;
case {'sum','multiply','inverse'},
otherwise,
  uiwait(msgbox(['No editing available for Process: ',InputStream.Type,'.'],'modal'));
end;


function OutStream=Local_edit_group(InStream,Title);
XX=xx_constants;

GridCell=20;
VirtualAreaWidth=100;
VirtualAreaHeight=100;

OutputProcessColor=XX.Clr.White;
ProcessColor=XX.Clr.LightGray;

EditStream=InStream;
Specs=EditStream.Specs;

Handles=ui_edit(Title);

[HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);

AllProcesses={'LoadField','ConstantMatrix','Sum','Multiply','ScalarMultiply','Inverse','Power','FieldRenumber'};
for i=1:length(AllProcesses),
  uimenu('parent',Handles.NewProcMenu, ...
         'label',AllProcesses{i}, ...
         'checked','off', ...
         'separator','off', ...
         'callback',['stackudf(gcbf,''CommandStack'',[1 1 ',num2str(i),'])'], ...
         'enable','on');
end;

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
    uiwait(msgbox('Unexpected removal of Edit window!','modal'));
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
    %%%% UICONTEXTMENU PLOTAXES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      switch cmd(2),
      case 1, % new process
        NewSubProcess=AllProcesses{cmd(3)};

        i=length(Specs.Process)+1;
        Specs.Process(i).Name=NewSubProcess;
        Specs.Process(i).InputData={};
        Specs.Process(i).Stream=edit(datastream(NewSubProcess));
        Specs.Process(i).InputFromProcess=cell(1,length(Specs.Process(i).Stream.InputType));
        Specs.Process(i).InputFromConnector=Specs.Process(i).InputFromProcess;
        Specs.Process(i).OutputData={};

        [Width,Height]=processbutton(Specs.Process(i));
        UDTemp.GridCell=GridCell;
        UDTemp.ContourX=[1 Width-1 Width-1 1 1];
        UDTemp.ContourY=[1 1 Height-1 Height-1 1];
        UDTemp.Min=[0 0];
        UDTemp.Max=[VirtualAreaWidth*GridCell-Width VirtualAreaWidth*GridCell-Height];
        HTemp=line(NaN,NaN,'parent',Handles.PlotAxes,'erasemode','xor','userdata',UDTemp,'linestyle',':','color','w','hittest','off');
        set(allchild(Handles.PlotAxes),'hittest','off');
        set(Handles.PlotAxes,'uicontextmenu',[]);
        set(Handles.Figure,'windowbuttonmotionfcn',['DragContour(hex2num(''',num2hex(HTemp),'''))']);
        WaitForClick(Handles.PlotAxes);
        UDTemp=get(HTemp,'userdata');
        delete(HTemp);
        set(allchild(Handles.PlotAxes),'hittest','on');
        set(Handles.PlotAxes,'uicontextmenu',Handles.PlotAxesMenu);
        set(Handles.Figure,'windowbuttonmotionfcn','');

        Specs.Process(i).PlotLocation=UDTemp.Point;

        % Add NewProcessProcess at Location
        HProc(i)=processbutton(Specs.Process(i), ...
           'uicontextmenu',Handles.ProcessMenu, ...
           'parent',Handles.PlotAxes, ...
           'userdata',i, ...
           'buttondownfcn','setudf(gcbf,''CallbackHandle'',gcbo)');

        if (i==1), % if this is the only process in the stream it must be the output process
          if  length(Specs.Process(i).Stream.OutputType)==1, % and it has one output
            set(HProc(1),'facecolor',OutputProcessColor);
            Specs.OutputProcess=1;
            Specs.OutputConnector=1;
          end;
        end;

      case 2, % done
        EditStream.Specs=Specs;
        ErrorMsg='';
        % check EditStream
        [EditStream,ErrorMsg]=numfields(EditStream);
        % if not valid, show why, otherwise quit
        if isempty(ErrorMsg),
          gui_quit=1;
        else,
          uiwait(msgbox(ErrorMsg,'modal'));
        end;

      case 3, % overview
        X=get(Handles.PlotAxes,'xlim');
        dX=X(2)-X(1);
        Y=get(Handles.PlotAxes,'ylim');
        dY=Y(2)-Y(1);
        set([Handles.Grid Handles.CoarseGrid],'visible','off');
        set([Handles.HorSlide Handles.VerSlide],'enable','off');
        set(HLink(:,1),'linewidth',1);
        dx=VirtualAreaWidth*GridCell;
        dy=VirtualAreaWidth*GridCell;
        set(Handles.PlotAxes,'xlim',[1 dx],'ylim',[1 dy]);

        UDTemp.GridCell=GridCell;
        UDTemp.ContourX=zeros(1,5);
        UDTemp.ContourX([1 4 5])=-floor(dX/2/GridCell)*GridCell;
        UDTemp.ContourX([2 3])=ceil(dX/2/GridCell)*GridCell;
        UDTemp.ContourY=zeros(1,5);
        UDTemp.ContourY([1 2 5])=-floor(dY/2/GridCell)*GridCell;
        UDTemp.ContourY([3 4])=ceil(dY/2/GridCell)*GridCell;
        UDTemp.Min=[floor(dX/GridCell/2) floor(dY/GridCell/2)]*GridCell+1;
        UDTemp.Max=[dx-floor(dX/GridCell/2)*GridCell dy-floor(dY/GridCell/2)*GridCell]-1;
        HTemp=line(NaN,NaN,'parent',Handles.PlotAxes,'erasemode','xor','userdata',UDTemp,'linestyle',':','color','w','hittest','off');
        set(allchild(Handles.PlotAxes),'hittest','off');
        set(Handles.PlotAxes,'hittest','off');
        set(Handles.Figure,'windowbuttonmotionfcn',['DragContour(hex2num(''',num2hex(HTemp),'''))']);
        set(Handles.BackGround,'hittest','on');
        WaitForClick(Handles.BackGround);
        set(Handles.BackGround,'hittest','off');
        UDTemp=get(HTemp,'userdata');
        delete(HTemp);
        set(Handles.PlotAxes,'hittest','on');
        set(allchild(Handles.PlotAxes),'hittest','on');
        set(Handles.PlotAxes,'uicontextmenu',Handles.PlotAxesMenu);
        set(Handles.Figure,'windowbuttonmotionfcn','');
        DD=UDTemp.Point-floor([dX dY]/2/GridCell)*GridCell;

        set(HLink(:,1),'linewidth',3);
        set(Handles.PlotAxes,'xlim',DD(1)+1+[0 dX],'ylim',DD(2)+1+[0 dY]);
        set([Handles.Grid Handles.CoarseGrid],'visible','on');
        set([Handles.HorSlide Handles.VerSlide],'enable','on');
        set(Handles.HorSlide,'value',DD(1)/GridCell);
        set(Handles.VerSlide,'value',DD(2)/GridCell);
      otherwise,
        uiwait(msgbox(['Unknown uicontextmenu command: ' gui_str(cmd)],'modal'));
      end;

    case 2,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% UICONTEXTMENU PROCESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      switch cmd(2),
      case 1, % move
        i=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
        [Width,Height]=processbutton(Specs.Process(i));
        UDTemp.GridCell=GridCell;
        UDTemp.Min=[0 0];
        UDTemp.Max=[VirtualAreaWidth*GridCell-Width VirtualAreaWidth*GridCell-Height];
        UDTemp.ContourX=[1 Width-1 Width-1 1 1];
        UDTemp.ContourY=[1 1 Height-1 Height-1 1];
        HTemp=line(NaN,NaN,'parent',Handles.PlotAxes,'erasemode','xor','userdata',UDTemp,'linestyle',':','color','w','hittest','off');
        set(allchild(Handles.PlotAxes),'hittest','off');
        set(Handles.PlotAxes,'uicontextmenu',[]);
        set(Handles.Figure,'windowbuttonmotionfcn',['DragContour(hex2num(''',num2hex(HTemp),'''))']);
        WaitForClick(Handles.PlotAxes);
        UDTemp=get(HTemp,'userdata');
        delete(HTemp);
        set(allchild(Handles.PlotAxes),'hittest','on');
        set(Handles.PlotAxes,'uicontextmenu',Handles.PlotAxesMenu);
        set(Handles.Figure,'windowbuttonmotionfcn','');
        % move
        Specs.Process(i).PlotLocation=UDTemp.Point;
        delete(allchild(Handles.PlotAxes));
        [HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);
      case 2, % delete
        i=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
        % delete(findobj(Handles.PlotAxes,'userdata',i));
        % HProc(i)=[];
        Specs.Process(i)=[];
        for j=1:length(Specs.Process),
          for k=1:length(Specs.Process(j).InputFromProcess),
            if ~isempty(Specs.Process(j).InputFromProcess{k}),
              FromI=Specs.Process(j).InputFromProcess{k}==i;
              Specs.Process(j).InputFromProcess{k}(FromI)=[];
              Specs.Process(j).InputFromConnector{k}(FromI)=[];
            end;
            if ~isempty(Specs.Process(j).InputFromProcess{k}),
              FromI=Specs.Process(j).InputFromProcess{k}>i;
              Specs.Process(j).InputFromProcess{k}(FromI)=Specs.Process(j).InputFromProcess{k}(FromI)-1;
            end;
          end;
        end;
        if isequal(Specs.OutputProcess,i),
          Specs.OutputProcess=[];
          Specs.OutputConnector=[];
        end;
        delete(allchild(Handles.PlotAxes));
        [HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);
      case 3, % edit
        i=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
        Specs.Process(i).Stream=edit(Specs.Process(i).Stream);
      case 4, % output process
        if ~isempty(Specs.OutputProcess),
          set(HProc(Specs.OutputProcess),'facecolor',ProcessColor);
        end;
        Specs.OutputProcess=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
        Specs.OutputConnector=1;
        set(HProc(Specs.OutputProcess),'facecolor',OutputProcessColor);
      case 5, % input from ...
        if length(Specs.Process)==1,
          uiwait(msgbox('no other process available','modal'));
        else,
          ToFrom=zeros(1,4);
          ToFrom(1)=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
          NConnect=length(Specs.Process(ToFrom(1)).Stream.InputCapacity);
          if NConnect==0,
            uiwait(msgbox('no input required','modal'));
          else,
            if NConnect>1,
              ToFrom(2)=ui_select({1 'TO connector'},1:NConnect);
              if ToFrom(2)>NConnect,
                ToFrom(2)=0; % cancel
              end;
            else,
              ToFrom(2)=1;
            end;
            if ToFrom(2)>0,
              set(allchild(Handles.PlotAxes),'uicontextmenu',[]);
              set(Handles.PlotAxes,'uicontextmenu',[]);
              setudf(Handles.Figure,'CallbackHandle',0);
              waitforudf(Handles.Figure,'CallbackHandle');
              set(allchild(Handles.PlotAxes),'uicontextmenu',Handles.ProcessMenu);
              set(Handles.PlotAxes,'uicontextmenu',Handles.PlotAxesMenu);
              ToFrom(3)=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
              if ToFrom(1)==ToFrom(3),
                uiwait(msgbox('input should be a different process.','modal'));
              else,
                NConnect=length(Specs.Process(ToFrom(3)).Stream.OutputType);
                if NConnect>1,
                  ToFrom(4)=ui_select({1 'FROM connector'},1:NConnect);
                  if ToFrom(2)>NConnect,
                    ToFrom(4)=0; % cancel
                  end;
                elseif NConnect>0,
                  ToFrom(4)=1;
                else,
                  ToFrom(4)=0;
                end;
                if ToFrom(4)>0,
                  switch Specs.Process(ToFrom(1)).Stream.InputCapacity(ToFrom(2)),
                  case {0,1},
                    Specs.Process(ToFrom(1)).InputFromProcess{ToFrom(2)}=ToFrom(3);
                    Specs.Process(ToFrom(1)).InputFromConnector{ToFrom(2)}=ToFrom(4);
                  otherwise, % inf
                    Specs.Process(ToFrom(1)).InputFromProcess{ToFrom(2)}(end+1)=ToFrom(3);
                    Specs.Process(ToFrom(1)).InputFromConnector{ToFrom(2)}(end+1)=ToFrom(4);
                  end;
                  delete(allchild(Handles.PlotAxes));
                  [HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);
                end;
              end;
            end;
          end;
        end;
      case 6, % rename
        i=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
        answer=inputdlg('New name','Rename ...',1,{Specs.Process(i).Name});
        if ~isempty(answer),
          Specs.Process(i).Name=answer{1};
          delete(allchild(Handles.PlotAxes));
          [HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);
        end;
      case 7, % output to ...
        if length(Specs.Process)==1,
          uiwait(msgbox('no other process available','modal'));
        else,
          ToFrom=zeros(1,4);
          ToFrom(1)=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
          NConnect=length(Specs.Process(ToFrom(1)).Stream.OutputType);
          if NConnect==0,
            uiwait(msgbox('no output available','modal'));
          else,
            if NConnect>1,
              ToFrom(2)=ui_select({1 'FROM connector'},1:NConnect);
              if ToFrom(2)>NConnect,
                ToFrom(2)=0; % cancel
              end;
            else,
              ToFrom(2)=1;
            end;
            if ToFrom(2)>0,
              set(allchild(Handles.PlotAxes),'uicontextmenu',[]);
              set(Handles.PlotAxes,'uicontextmenu',[]);
              setudf(Handles.Figure,'CallbackHandle',0);
              waitforudf(Handles.Figure,'CallbackHandle');
              set(allchild(Handles.PlotAxes),'uicontextmenu',Handles.ProcessMenu);
              set(Handles.PlotAxes,'uicontextmenu',Handles.PlotAxesMenu);
              ToFrom(3)=get(getudf(Handles.Figure,'CallbackHandle'),'userdata');
              if ToFrom(1)==ToFrom(3),
                uiwait(msgbox('input should be a different process.','modal'));
              else,
                NConnect=length(Specs.Process(ToFrom(3)).Stream.InputType);
                if NConnect>1,
                  ToFrom(4)=ui_select({1 'To connector'},1:NConnect);
                  if ToFrom(2)>NConnect,
                    ToFrom(4)=0; % cancel
                  end;
                elseif NConnect>0,
                  ToFrom(4)=1;
                else,
                  ToFrom(4)=0;
                end;
                if ToFrom(4)>0,
                  switch Specs.Process(ToFrom(3)).Stream.InputCapacity(ToFrom(4)),
                  case {0,1},
                    Specs.Process(ToFrom(3)).InputFromProcess{ToFrom(4)}=ToFrom(1);
                    Specs.Process(ToFrom(3)).InputFromConnector{ToFrom(4)}=ToFrom(2);
                  otherwise, % inf
                    Specs.Process(ToFrom(3)).InputFromProcess{ToFrom(4)}(end+1)=ToFrom(1);
                    Specs.Process(ToFrom(3)).InputFromConnector{ToFrom(4)}(end+1)=ToFrom(2);
                  end;
                  delete(allchild(Handles.PlotAxes));
                  [HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);
                end;
              end;
            end;
          end;
        end;

      otherwise,
        uiwait(msgbox(['Unknown uicontextmenu command: ' gui_str(cmd)],'modal'));
      end;

    case 3,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% UICONTEXTMENU INPUTLINK
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      switch cmd(2),
      case 1, % delete
        i=find(HLink(:,1)==getudf(Handles.Figure,'CallbackHandle'));
        j=find(HLink(i,4)==Specs.Process(HLink(i,2)).InputFromProcess{HLink(i,3)});
        Specs.Process(HLink(i,2)).InputFromProcess{HLink(i,3)}(j)=[];
        Specs.Process(HLink(i,2)).InputFromConnector{HLink(i,3)}(j)=[];
        delete(allchild(Handles.PlotAxes));
        [HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);
      otherwise,
        uiwait(msgbox(['Unknown uicontextmenu command: ' gui_str(cmd)],'modal'));
      end;

    case 4,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% FILE UIMENU
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      switch cmd(2),
      case 1, % load
        [filename,filepath]=uigetfile('*.ds');
        if ischar(filename), % open and load
          delete(allchild(Handles.PlotAxes));
          fid=fopen([filepath filename],'r');
          EditStream=datastream(fid);
          Specs=EditStream.Specs;
          fclose(fid);
          [HProc,HLink]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor);
        end;
      case 2, % save
        [filename,filepath]=uiputfile('*.ds');
        if ischar(filename), % open and save
          fid=fopen([filepath filename],'w');
          EditStream.Specs=Specs;
          ds_save(EditStream,fid);
          fclose(fid);
        end;
      otherwise,
        uiwait(msgbox(['Unknown uicontextmenu command: ' gui_str(cmd)],'modal'));
      end;

    otherwise,
      uiwait(msgbox(['Unknown command: ' gui_str(cmd)],'modal'));
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
  OutStream=EditStream;
  OutStream.Specs=Specs;
end;


function WaitForClick(AxesHandle),
TempObj=text('parent',AxesHandle,'visible','off');
set(AxesHandle,'buttondownfcn',['delete(hex2num(''',num2hex(TempObj),'''))']);
waitfor(TempObj);
if ishandle(AxesHandle),
  set(AxesHandle,'buttondownfcn','');
end;


function DragContour(ContourHandle);
DragOptions=get(ContourHandle,'userdata');
Point=get(get(ContourHandle,'parent'),'currentpoint');
Point=Point(1,1:2);
if isfield(DragOptions,'Max'),
  Point=max(min(Point,DragOptions.Max),DragOptions.Min);
end;
Point=DragOptions.GridCell*floor(Point/DragOptions.GridCell);
set(ContourHandle,'visible','off');
set(ContourHandle,'xdata',Point(1)+DragOptions.ContourX,'ydata',Point(2)+DragOptions.ContourY,'visible','on');
DragOptions.Point=Point;
set(ContourHandle,'userdata',DragOptions);
