function seagull(cmd)
%SEAGULL user interface for vessel motion and Triton output
%        To start the interface type: seagull

% (c) 2001 WL | Delft Hydraulics
%     Author: H.R.A.Jagers

% V1.00.00 (12/ 3/2001): created
% V2.00.00 (16/10/2001): extended with 3D hull and Triton options

InActive=[.8 .8 .8];
Active=[1 1 1];

if nargin==0,
  cmd='initialize';
end;
cmd=lower(cmd);

if isempty(gcbf) | ~strcmp(get(gcbf,'tag'),'vesselui'),
  mfig=findobj(allchild(0),'flat','tag','vesselui');
else,
  mfig=gcbf;
end;

if strcmp(cmd,'initialize')
  try,
    mfig=vesselui;
    set(mfig,'tag','vesselui');
  catch
    uiwait(msgbox('Interface file not found.','modal'));
    return
  end
  UD.SfWave=1;
  UD.SfShip=1;
  UD.AFac=1;
  UD.Time=[];
  % vessel files
  UD.VesselActive=1;
  UD.VesselType=1;
  UD.ContourFile='';
  UD.Contour=[];
  UD.HullFile='';
  UD.HullXYZ=[];
  UD.HullRefPos=[];
  UD.MotionFile='';
  UD.Motion=[0;0;0;0;0;0;0];
  % triton file
  UD.TritonActive=0;
  UD.TritonFile='';
  UD.Triton=[];
  % graphics handles
  UD.VesselH=[];
  UD.TritonH=[];
  UD.Figure=[];
  % plot options
  UD.PlotType=0;
  UD.PlotLogo=1;
  UD.FilesOut=0;
  UD.FigPos=[232  258  560  420];
  set(findobj(mfig,'tag','sfwave'),'string','1')
  set(findobj(mfig,'tag','sfship'),'string','1')
  set(findobj(mfig,'tag','afac'),'string','1')
  set(findobj(mfig,'tag','slider'),'enable','off')
  set(findobj(mfig,'tag','play'),'enable','off')
  set(findobj(mfig,'tag','vesselcheck'),'value',1)
  set(findobj(mfig,'tag','tritoncheck'),'value',0)
  set(findobj(mfig,'tag','loadtriton'),'enable','off')
  set(mfig,'userdata',UD,'closerequestfcn','seagull close');
end

UD=get(mfig,'userdata');

switch cmd,
case 'rotate'
  putdowntext('rotate3d',gcbo)
  if strcmp(get(gcbo,'state'),'on')
    set(UD.Figure,'WindowButtonDownFcn','seagull rotdown'); %rotate3d('down')
    set(UD.Figure,'WindowButtonUpFcn'  ,'seagull rotup'  ); %rotate3d('up')
  end
case 'rotdown'
  rotate3d('down')
case 'rotup'
  rotate3d('up')
  ae=get(gca,'view');
  %camlight(findobj(UD.Figure,'tag','Light1'),37.50,140-ae(2))
  camlight(findobj(UD.Figure,'tag','Light2'))
case 'switchlogo'
  switch get(gcbo,'checked')
  case 'on'
    UD.PlotLogo=0;
    set(gcbo,'checked','off')
  case 'off'
    UD.PlotLogo=1;
    set(gcbo,'checked','on')
  end
  UD=PlotLogo(UD);
  set(mfig,'userdata',UD);
case 'switchfilesout'
  switch get(gcbo,'checked')
  case 'on'
    UD.FilesOut=0;
    set(gcbo,'checked','off')
  case 'off'
    [f,p]=uiputfile('*.tif','Specify output location');
    if ~ischar(p)
      return;
    end
    filename=[p f];
    [p,f,e]=fileparts(f);
    if isempty(p)
      p=pwd;
    end
    if isempty(e)
      e='.tif';
    end
    nDigits=-1;
    i=length(f);
    while i>0 & 48<=f(i) & f(i)<=57
      i=i-1;
    end
    UD.FilesOut=1;
    UD.FileDigits=length(f)-i;
    if UD.FileDigits==0,
      UD.FileDigits=3;
      UD.FileNr=0;
    else
      UD.FileNr=str2double(f(i+1:end));
    end
    UD.FileBase=[p filesep f(1:i)];
    UD.FileExt=e;
    set(gcbo,'checked','on')
  end
  set(mfig,'userdata',UD);
case 'close'
  delete(mfig)
  if ishandle(UD.Figure)
    delete(UD.Figure);
  end
case 'slider'
  hslid=findobj(mfig,'tag','slider');
  t=round(get(hslid,'value'));
  set(hslid,'value',t)
  UD=checkupdateplot(mfig,UD);
  set(mfig,'userdata',UD);
case 'stop'
  play=findobj(mfig,'tag','play');
  set(play,'userdata',0);
case 'play'
  if isempty(UD.Figure) | ~ishandle(UD.Figure)
    return
  else
    Pos=get(UD.Figure,'position');
    set(UD.Figure,'paperposition',[0 0 Pos(3:4)/100]); % 100 DPI reference situation for creating bitmap files
  end
  hslid=findobj(mfig,'tag','slider');
  NT=get(hslid,'max');
  t0=round(get(hslid,'value'));
  play=findobj(mfig,'tag','play');
  set(play,'string','stop','callback','seagull stop','userdata',1);
  t=t0;
  try,
    while ishandle(play) & get(play,'userdata') & t<=NT-UD.AFac
      t=t+UD.AFac;
      set(hslid,'value',t)
      UD=checkupdateplot(mfig,UD);
      drawnow
      UD=WriteFig(UD);
      set(mfig,'userdata',UD);
    end
  catch
  end
  if ishandle(play)
    set(play,'string','play','callback','seagull play');
  end
case 'loadmotion'
  [fn,pn]=uigetfile('motions.*');
  if ~ischar(fn), return; end
  filename=[pn fn];
  fid=fopen(filename,'r');
  fseek(fid,2,0); % skip first byte (75?), and first record byte (28)
  Motion=fread(fid,[7 inf],'7*float32',2);
  fclose(fid);
  UD.MotionFile=filename;
  UD.Motion=Motion;
  set(findobj(mfig,'tag','motionfile'),'string',abbrevfn(filename,30))
  UD.PlotType=-1; % always refresh
  UD=checkupdateplot(mfig,UD);
  set(mfig,'userdata',UD);
case 'vesselcheck'
  va=findobj(mfig,'tag','vesselcheck');
  UD.VesselActive=get(va,'value');
  if UD.VesselActive
    set(findobj(mfig,'tag','contourradio'),'enable','on')
    set(findobj(mfig,'tag','hullradio'),'enable','on')
    set(findobj(mfig,'tag','loadvessel'),'enable','on')
    set(findobj(mfig,'tag','vesselfile'),'enable','inactive')
    set(findobj(mfig,'tag','motionfiletext'),'enable','on')
    set(findobj(mfig,'tag','loadmotion'),'enable','on')
    set(findobj(mfig,'tag','motionfile'),'enable','inactive')
    if UD.VesselType==1
      set(findobj(mfig,'tag','tritoncheck'),'enable','off')
    else
      set(findobj(mfig,'tag','tritoncheck'),'enable','on')
    end
    set(findobj(mfig,'tag','sfshiptext'),'enable','on')
    set(findobj(mfig,'tag','sfship'),'enable','on','backgroundcolor',Active)
  else
    set(findobj(mfig,'tag','contourradio'),'enable','off')
    set(findobj(mfig,'tag','hullradio'),'enable','off')
    set(findobj(mfig,'tag','loadvessel'),'enable','off')
    set(findobj(mfig,'tag','vesselfile'),'enable','off')
    set(findobj(mfig,'tag','motionfiletext'),'enable','off')
    set(findobj(mfig,'tag','loadmotion'),'enable','off')
    set(findobj(mfig,'tag','motionfile'),'enable','off')
    set(findobj(mfig,'tag','tritoncheck'),'enable','on')
    set(findobj(mfig,'tag','sfshiptext'),'enable','off')
    set(findobj(mfig,'tag','sfship'),'enable','off','backgroundcolor',InActive)
  end
  set(mfig,'userdata',UD);
  seagull tritoncheck
case 'contourradio'
  set(findobj(mfig,'tag','contourradio'),'value',1)
  set(findobj(mfig,'tag','hullradio'),'value',0)
  UD.VesselType=1;
  set(findobj(mfig,'tag','vesselfile'),'string',UD.ContourFile);
  set(findobj(mfig,'tag','tritoncheck'),'enable','off')
  set(mfig,'userdata',UD);
  seagull tritoncheck
case 'hullradio'
  set(findobj(mfig,'tag','contourradio'),'value',0)
  set(findobj(mfig,'tag','hullradio'),'value',1)
  UD.VesselType=2;
  set(findobj(mfig,'tag','vesselfile'),'string',UD.HullFile);
  set(findobj(mfig,'tag','tritoncheck'),'enable','on')
  set(mfig,'userdata',UD);
  seagull tritoncheck
case 'loadvessel'
  switch UD.VesselType
  case 1
    [fn,pn]=uigetfile('contour.*');
    if ~ischar(fn), return; end
    filename=[pn fn];
    fid=fopen(filename,'r');
    Contour=fscanf(fid,'%f %f',[2 inf]);
    if ~feof(fid)
      fclose(fid);
      return;
    end
    fclose(fid);
    UD.ContourFile=filename;
    UD.Contour=Contour;
    set(findobj(mfig,'tag','vesselfile'),'string',abbrevfn(filename,30))
  case 2
    [fn,pn]=uigetfile('hullform.dat');
    if ~ischar(fn), return; end
    filename=[pn fn];
    OK=1;
    R={};
    fid=fopen(filename,'r');
%    RefPos=fscanf(fid,'%f',[1 4]);
%    i=0;
%    while ~feof(fid)
%      x0=fscanf(fid,'%f',[1 1]);
%      if feof(fid), break; end
%      n0=fscanf(fid,'%i',[1 1]);
%      if isempty(n0) | n0>200 | n0<1, break; end
%      y0z0=fscanf(fid,'%f',[2 n0]);
%      i=i+1;
%      R{i,1}=x0;
%      R{i,2}=y0z0;
%    end
    NProf=fscanf(fid,'%i',1);
    for i=1:NProf
      R{i+1,1}=fscanf(fid,'%f',1);
      n0=fscanf(fid,'%i',[1 1]);
      if isempty(n0) | n0>200 | n0<1, OK=0; break; end
      y0z0=fscanf(fid,'%f',[2 n0]);
      R{i+1,2}=cat(2,y0z0,[0;y0z0(end)]);
    end
    R{1,1}=R{2,1};
    R{1,2}=R{2,2}(:,end);
    d0=R{end,2}(1,end-1);
    R{end+1,1}=R{end,1}+d0;
    R{end,2}=R{end-1,2}(:,end);
    if OK
      RefPos1=fscanf(fid,'%f',[3 1]);
      for i=1:size(R,1)
        R{i,1}=R{i,1}-RefPos1(1);
        R{i,2}=R{i,2}-repmat(RefPos1(2:3),1,size(R{i,2},2));
      end
      RefPos=fscanf(fid,'%f',[1 4]);
    end
    fclose(fid);
    if ~OK, return; end
%    RefPos=[0 0 0 0];
%    R={};
%    R{1,1}=0;
%    R{1,2}=[0;3];
%    R{2,1}=5;
%    R{2,2}=[0 5 5 0;2 2 -3 -8];
%    R{3,1}=45;
%    R{3,2}=[0 5 5 0;2 2 -3 -8];
%    R{4,1}=45;
%    R{4,2}=[0;2];
    UD.HullRefPos=RefPos;
    NPnt=0;
    for i=1:size(R,1)
      NPnt=NPnt+size(R{i,2},2);
    end
    NTri=2*NPnt-size(R{1,2},2)-size(R{end,2},2)-2*size(R,1);
    UD.HullTri=zeros(NTri,3);
    UD.HullXYZ=zeros(NPnt,3);
    n0=0;
    n1=size(R{1,2},2);
    UD.HullXYZ(1:n1,1)=R{1,1};
    Tmp=R{1,2}';
    UD.HullXYZ(1:n1,2:3)=Tmp;
    p1=pathdistance(Tmp(:,1),Tmp(:,2));
    if max(p1)~=0, p1=p1/max(p1); else, p1=0.5; end
    t0=0;
    for i=2:size(R,1)
      pn0=n0;
      pn1=n1;
      n0=n0+n1;
      pp1=p1;
      n1=size(R{i,2},2);
      UD.HullXYZ(n0+(1:n1),1)=R{i,1};
      Tmp=R{i,2}';
      UD.HullXYZ(n0+(1:n1),2:3)=Tmp;
      p1=pathdistance(Tmp(:,1),Tmp(:,2));
      if max(p1)~=0, p1=p1/max(p1); else, p1=0.5; end
      j0=1;
      j1=1;
      while (j0<pn1) | (j1<n1)
        t0=t0+1;
        if j0==pn1
          UD.HullTri(t0,1)=pn0+j0;
          UD.HullTri(t0,2)=n0+j1;
          j1=j1+1;
          UD.HullTri(t0,3)=n0+j1;
        elseif j1==n1
          UD.HullTri(t0,1)=pn0+j0;
          j0=j0+1;
          UD.HullTri(t0,3)=pn0+j0;
          UD.HullTri(t0,2)=n0+j1;
        elseif pp1(j0+1)<p1(j1+1)
          UD.HullTri(t0,1)=pn0+j0;
          j0=j0+1;
          UD.HullTri(t0,3)=pn0+j0;
          UD.HullTri(t0,2)=n0+j1;
        else
          UD.HullTri(t0,1)=pn0+j0;
          UD.HullTri(t0,2)=n0+j1;
          j1=j1+1;
          UD.HullTri(t0,3)=n0+j1;
        end
      end
    end
    UD.HullTri=[UD.HullTri;size(UD.HullXYZ,1)+UD.HullTri(:,[1 3 2])];
    Tmp=UD.HullXYZ; Tmp(:,2)=-Tmp(:,2);
    UD.HullXYZ=[UD.HullXYZ;Tmp];
    UD.HullFile=filename;
    set(findobj(mfig,'tag','vesselfile'),'string',abbrevfn(filename,30))
  end
  UD.PlotType=-1; % always refresh
  UD=checkupdateplot(mfig,UD);
  set(mfig,'userdata',UD);
case 'tritoncheck'
  ta=findobj(mfig,'tag','tritoncheck');
  UD.TritonActive=get(ta,'value');
  if UD.TritonActive & strcmp(get(ta,'enable'),'on')
    set(findobj(mfig,'tag','loadtriton'),'enable','on')
    set(findobj(mfig,'tag','tritonfile'),'enable','inactive')
    set(findobj(mfig,'tag','sfwavetext'),'enable','on')
    set(findobj(mfig,'tag','sfwave'),'enable','on','backgroundcolor',Active)
  else
    set(findobj(mfig,'tag','loadtriton'),'enable','off')
    set(findobj(mfig,'tag','tritonfile'),'enable','off')
    set(findobj(mfig,'tag','sfwavetext'),'enable','off')
    set(findobj(mfig,'tag','sfwave'),'enable','off','backgroundcolor',InActive)
  end
  UD=checkupdateplot(mfig,UD);
  set(mfig,'userdata',UD);
case 'loadtriton'
  [fn,pn]=uigetfile('bsq_*.ani');
  if ~ischar(fn), return; end
  filename=[pn fn];
  TritonInfo=triton('open',filename);
  if strcmp(TritonInfo.Check,'OK')
    UD.TritonFile=filename;
    UD.Triton=TritonInfo;
    set(findobj(mfig,'tag','tritonfile'),'string',abbrevfn(filename,30))
    UD.PlotType=-1; % always refresh
    UD=checkupdateplot(mfig,UD);
  end
  set(mfig,'userdata',UD);
case 'afac'
  Str=get(findobj(mfig,'tag','afac'),'string');
  Val=round(str2num(Str));
  if isequal(size(Val),[1 1]) & Val>0
    UD.AFac=Val;
  end
  set(findobj(mfig,'tag','afac'),'string',num2str(UD.AFac))
  set(mfig,'userdata',UD);
case 'sfwave'
  Str=get(findobj(mfig,'tag','sfwave'),'string');
  Val=str2num(Str);
  if isequal(size(Val),[1 1])
    UD.SfWave=Val;
  end
  set(findobj(mfig,'tag','sfwave'),'string',num2str(UD.SfWave))
  UD=checkupdateplot(mfig,UD);
  set(mfig,'userdata',UD);
case 'sfship'
  Str=get(findobj(mfig,'tag','sfship'),'string');
  Val=str2num(Str);
  if isequal(size(Val),[1 1])
    UD.SfShip=Val;
  end
  set(findobj(mfig,'tag','sfship'),'string',num2str(UD.SfShip))
  UD=checkupdateplot(mfig,UD);
  set(mfig,'userdata',UD);
end


function UD=checkupdateplot(mfig,UD);
if UD.VesselActive
  if (UD.VesselType==1) & ~isempty(UD.Contour) & ~isempty(UD.Motion)
    Tp=1; % contour
  elseif ~isempty(UD.HullXYZ)
    if UD.TritonActive & ~isempty(UD.Triton)
      Tp=2; % hull & triton
    else
      Tp=3; % hull
    end
  elseif UD.TritonActive & ~isempty(UD.Triton)
    Tp=4; % triton
  else
    Tp=0; % nothing
  end
elseif UD.TritonActive & ~isempty(UD.Triton)
  Tp=4; % hull
else
  Tp=0; % nothing
end
NT=0;
switch Tp,
case 0, % nothing
case {1,2,3} % contour | hull
  NT=size(UD.Motion,2);
case 4, % triton
  NT=length(UD.Triton.Time);
end
if UD.PlotType~=Tp;
  if ishandle(UD.Figure)
    UD.FigPos=get(UD.Figure,'position');
    delete(UD.Figure)
  end
  UD.Figure=[];
  UD.VesselH=[];
  UD.TritonH=[];
  switch Tp,
  case 0, % nothing
    t=[];
    UD.Time=[];
  case {1,2,3} % contour | hull
    if isempty(UD.Time)
      UD.Time=UD.Motion(1,1);
    end
    i=max(1,sum(UD.Motion(1,:)<=UD.Time));
    if NT==1
      set(findobj(mfig,'tag','slider'),'value',1,'min',1,'max',2,'enable','off')
      set(findobj(mfig,'tag','play'),'enable','off')
    else
      set(findobj(mfig,'tag','slider'),'min',1,'max',NT,'value',i,'sliderstep',min([0.5 1],[1 10]/NT))
    end
    UD.Time=UD.Motion(1,i);
  case 4, % triton
    if isempty(UD.Time)
      UD.Time=UD.Triton.Time(1);
    end
    i=max(1,sum(UD.Triton.Time<=UD.Time));
    if NT==1
      set(findobj(mfig,'tag','slider'),'value',1,'min',1,'max',2,'enable','off')
      set(findobj(mfig,'tag','play'),'enable','off')
    else
      set(findobj(mfig,'tag','slider'),'min',1,'max',NT,'value',i,'sliderstep',min([0.5 1],[1 10]/NT))
    end
    UD.Time=UD.Triton.Time(i);
  end
end
switch Tp,
case 0, % nothing
  t=[];
  UD.Time=[];
case {1,2,3} % contour | hull
  t=get(findobj(mfig,'tag','slider'),'value');
  UD.Time=UD.Motion(1,t);
case 4, % triton
  t=get(findobj(mfig,'tag','slider'),'value');
  UD.Time=UD.Triton.Time(t);
end
UD.PlotType=Tp;
switch Tp,
case 0, % nothing
  % do nothing
case 1, % contour
  if NT>1
    set(findobj(mfig,'tag','slider'),'enable','on')
    set(findobj(mfig,'tag','play'),'enable','on')
  end
  t=get(findobj(mfig,'tag','slider'),'value');
  UD=plottopview(UD,t);
case {2,3,4} % hull | triton
  if NT>1
    set(findobj(mfig,'tag','slider'),'enable','on')
    set(findobj(mfig,'tag','play'),'enable','on')
  end
  t=get(findobj(mfig,'tag','slider'),'value');
  UD=plot3Dview(UD,t);
end
set(mfig,'userdata',UD);


function UD=plot3Dview(UD,t);
setit=0;
Time=UD.Time;
if isempty(UD.Figure) | ~ishandle(UD.Figure)
  UD.Figure=figure('renderer','zbuffer','units','pixels','position',UD.FigPos,'paperunits','inches','inverthardcopy','off');
  A=axes('parent',UD.Figure,'tag','3Daxes','units','normalized','position',[0 0 1 1]);
  B=axes('parent',UD.Figure,'units','normalized','position',[0 0 1 1],'visible','off','hittest','off','tag','Taxes','handlevisibility','off');
  set(UD.Figure,'currentaxes',A)
  Bt=text(0.05,0.95,'string','parent',B,'horizontalalignment','left','verticalalignment','top','hittest','off','handlevisibility','off','tag','Tstring');
  R3D=findall(UD.Figure,'tag','figToolRotate3D');
  set(R3D,'ClickedCallback','seagull rotate'); %'putdowntext(''rotate3d'',gcbo)')
  setit=1;
else
  A=findobj(UD.Figure,'tag','3Daxes');
  Bt=findall(UD.Figure,'tag','Tstring');
end
nulp=[0 0 0];
if UD.TritonActive & ~isempty(UD.Triton)
  minx=min(UD.Triton.Grid.X(:));
  miny=min(UD.Triton.Grid.Y(:));
  maxx=max(UD.Triton.Grid.X(:));
  maxy=max(UD.Triton.Grid.Y(:));
  nulp=[(minx+maxx)/2 (miny+maxy)/2 0];
end
if UD.VesselActive & ~isempty(UD.HullXYZ) & ~isempty(UD.Motion)
  nulp=UD.HullRefPos;
  x=UD.HullXYZ(:,1);
  y=UD.HullXYZ(:,2);
  z=UD.HullXYZ(:,3);
  [X0,Y0,Z0]=transform(UD,t,x,y,z,UD.SfWave);
  alf=UD.HullRefPos(4)*pi/180;
  X=X0*cos(alf)-Y0*sin(alf);%+UD.HullRefPos(1);
  Y=Y0*cos(alf)+X0*sin(alf);%+UD.HullRefPos(2);
  Z=Z0+UD.HullRefPos(3)*UD.SfWave;
  if isempty(UD.VesselH) | ~ishandle(UD.VesselH)
    UD.VesselH=patch(1,1,1,'vertices',[X Y Z],'faces',UD.HullTri,'parent',A);
    set(UD.VesselH,'clipping','off','facecolor',[1.0000    0.8980    0.1434],'edgecolor','none','cdata',[]);
  else
    set(UD.VesselH,'vertices',[X Y Z])
  end
end
if UD.TritonActive & ~isempty(UD.Triton)
  if isempty(UD.TritonH) | ~ishandle(UD.TritonH)
    S1=triton('read',UD.Triton,Time);
    UD.TritonH=surface(UD.Triton.Grid.X-nulp(1),UD.Triton.Grid.Y-nulp(2),S1*UD.SfWave,1,'parent',A,'facecolor',[ 0.2043    0.6272    0.7660]);
    set(UD.TritonH,'clipping','off','edgecolor','none','facelighting','gouraud','DiffuseStrength',1,'AmbientStrength',0,'SpecularStrength',0)
  else
    S1=triton('read',UD.Triton,Time);
    set(UD.TritonH,'zdata',S1*UD.SfWave)
  end
end
if setit
  set(A,'dataaspectratio',[1 1 1],'view',[0 90],'box','on');
  %set(A,'xlimmode','manual','ylimmode','manual','zlimmode','manual');
  xlim=get(A,'xlim'); xlim=[-1 1]*max(abs(xlim));
  ylim=get(A,'ylim'); ylim=[-1 1]*max(abs(ylim));
  zlim=get(A,'zlim'); zlim=[-1 1]*max(abs(zlim));
  set(A,'xlim',xlim,'ylim',ylim,'zlim',zlim)
  set(A,'view',[  -36.5000   16.0000],'visible','off') %-37.50 30
  %set(camlight(37.50,110),'tag','Light1','color',[.8 .8 .8])
  light('position',[0 0 1e8],'color',[0.1830    0.1830    0.1830])
  set(camlight,'tag','Light2','color',[1 1 1])
end
set(Bt,'string',sprintf('after %.2f seconds',Time),'visible','on');
UD=PlotLogo(UD);


function UD=plottopview(UD,t);
x=UD.Contour(1,:);
y=UD.Contour(2,:);
z=zeros(size(x));
[X,Y,Z]=transform(UD,t,x,y,z);
Time=UD.Time;
if isempty(UD.VesselH) | ~ishandle(UD.VesselH)
  UD.Figure=figure('renderer','zbuffer','units','pixels','position',UD.FigPos,'paperunits','inches','inverthardcopy','off');
  A=axes('parent',UD.Figure);
  [X0,Y0,Z0]=transform(UD,1,x,y,z);
  line(X0,Y0,Z0,'parent',A,'color','b','linestyle',':');
  UD.VesselH=line(X,Y,Z,'parent',A,'color','b','linestyle','-');
  set(A,'dataaspectratio',[1 1 1],'view',[0 90],'box','on');
  drawnow
  set(A,'xlimmode','manual','ylimmode','manual','zlimmode','manual');
else
  set(UD.VesselH,'xdata',X,'ydata',Y,'zdata',Z)
  A=get(UD.VesselH,'parent');
end
set(get(A,'title'),'string',sprintf('after %.2f seconds',Time));
UD=PlotLogo(UD);


function UD=WriteFig(UD);
if isempty(UD.Figure) | ~ishandle(UD.Figure) | ~UD.FilesOut
  return
end
FigStr=sprintf('-f%20.16f',UD.Figure);
FrmtString=strcat('%s%',num2str(UD.FileDigits),'.',num2str(UD.FileDigits),'i.',UD.FileExt);
filename=sprintf(FrmtString,UD.FileBase,UD.FileNr);
Renderer=strcat('-',lower(get(UD.Figure,'renderer')));
print(filename,FigStr,'-dtiff','-r100',Renderer);
UD.FileNr=UD.FileNr+1;


function UD=PlotLogo(UD);
if isempty(UD.Figure) | ~ishandle(UD.Figure)
  return
end
A=findobj(UD.Figure,'tag','LOGOaxes');
if isempty(A)
  Pos=get(UD.Figure,'position');
  A=axes('parent',UD.Figure,'visible','off','tag','LOGOaxes','units','pixels','position',[1 3 10 10], ...
     'xlim',[1 10],'ylim',[1 10]);
  LG= [ 1 1 1 1 1 1 1 1 1 1 1 1 4 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
        1 1 1 1 1 1 1 1 1 1 1 1 4 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
        1 1 1 1 1 1 1 1 1 1 1 1 4 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
        1 1 1 1 1 1 1 1 1 1 1 1 4 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
        1 1 1 1 1 1 1 1 1 1 1 1 4 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
        1 1 1 1 1 1 1 1 1 1 1 1 4 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1
        1 4 2 2 2 2 2 4 2 2 2 2 4 4 2 2 2 2 2 3 3 3 3 3 4 3 3 3 3 3 4 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 2 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 3 3 4 4 2 2 3 3 3 3 3 3 3 3 3 3 1
        1 4 2 2 2 2 2 4 2 2 2 2 2 2 3 3 3 3 4 4 2 3 3 3 4 3 3 3 3 3 4 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 4 2 2 2 2 2 4 2 2 2 2 3 3 4 4 3 3 4 3 3 3 3 3 4 3 3 3 3 3 4 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 4 4 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 4 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 1
        1 4 2 2 2 2 2 4 2 2 2 2 2 2 4 4 2 2 2 2 2 3 3 3 4 3 3 3 3 3 4 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 2 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 4 4 2 2 2 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 3 3 4 4 2 2 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 4 4 2 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 1
        1 4 2 2 2 2 2 4 2 2 2 2 3 3 3 3 3 3 4 4 3 3 3 3 4 3 3 3 3 3 4 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 2 2 2 2 2 2 2 2 2 2 2 3 3 4 4 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1
        1 4 2 2 2 2 2 4 2 2 2 2 4 4 4 3 3 4 3 3 3 3 3 3 4 3 3 3 3 3 4 1
        1 1 1 1 1 1 1 1 1 1 1 1 4 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ];
  M=[get(UD.Figure,'color');0 0 1; 0 1 1; 1 1 1];
  I=image('cdata',idx2rgb(flipud(LG'),M),'parent',A,'xdata',[1 37],'ydata',[1 32],'clipping','off','visible','off');
  WL=[87 76 32 124 32 68 101 108 102 116 32 72 121 100 114 97 117 108 105 99 115];
  T=text('parent',A,'position',[42 1],'string',char(WL),'clipping','off','verticalalignment','bottom','visible','off');
end
if UD.PlotLogo
  set(get(A,'children'),'visible','on');
else
  set(allchild(A),'visible','off');
end


function [X,Y,Z]=transform(UD,t,x,y,z,sf)
if nargin==5
  sf=1;
end
SURGE=UD.Motion(2,t)*UD.SfShip;
SWAY=UD.Motion(3,t)*UD.SfShip;
HEAVE=UD.Motion(4,t)*UD.SfShip*sf; z=z*sf;
ROLL=UD.Motion(5,t)*UD.SfShip*pi/180;
PITCH=UD.Motion(6,t)*UD.SfShip*pi/180;
YAW=UD.Motion(7,t)*UD.SfShip*pi/180;
X = SURGE + (cos(YAW)*cos(PITCH)-sin(YAW)*sin(ROLL)*sin(PITCH))*x - sin(YAW)*cos(ROLL)*y + (cos(YAW)*sin(PITCH)+sin(YAW)*sin(ROLL)*cos(PITCH))*z;
Y = SWAY  + (sin(YAW)*cos(PITCH)+cos(YAW)*sin(ROLL)*sin(PITCH))*x + cos(YAW)*cos(ROLL)*y + (sin(YAW)*sin(PITCH)-cos(YAW)*sin(ROLL)*cos(PITCH))*z;
Z = HEAVE - cos(ROLL)*sin(PITCH)                               *x + sin(ROLL)         *y + cos(ROLL)*cos(PITCH)                               *z;
%X = SURGE +       x -  YAW*y + PITCH*z;
%Y = SWAY  +   YAW*x +      y -  ROLL*z;
%Z = HEAVE - PITCH*x + ROLL*y +       z;


function mfig = vesselui
InActive=[.8 .8 .8];
Active=[1 1 1];

SS=get(0,'screensize');
Pos=[SS(3)-305 SS(4)-300 289 250];

WL=[87 76 32 124 32 68 101 108 102 116 32 72 121 100 114 97 117 108 105 99 115];
h0 = figure('CloseRequestFcn','seagull close', ...
	'Color',[0.8 0.8 0.8], ...
	'IntegerHandle','off', ...
   'MenuBar','none', ...
   'Name',char(WL), ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperUnits','points', ...
	'Position',Pos, ...
	'Tag','vesselui', ...
	'ToolBar','none');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull slider', ...
	'Enable','off', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[21 21 150 20], ...
	'Style','slider', ...
	'Tag','slider');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull play', ...
	'Enable','off', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[221 21 50 20], ...
	'String','play', ...
	'Tag','play');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull loadmotion', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[221 160 50 20], ...
	'String','load', ...
	'Tag','loadmotion');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Enable','inactive', ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 161 190 20], ...
	'Style','edit', ...
	'Tag','motionfile');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 181 150 16], ...
	'String','Motion file', ...
	'Style','text', ...
	'Tag','motionfiletext');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 81 150 20], ...
	'String','Scale factor ship motion:', ...
	'Style','text', ...
	'Tag','sfshiptext');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',Active, ...
	'Callback','seagull sfship', ...
	'FontSize',12, ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[181 81 90 20], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','sfship');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',InActive, ...
	'Callback','seagull sfwave', ...
	'FontSize',12, ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[181 51 90 20], ...
	'String','1', ...
	'Style','edit', ...
	'Enable','off', ...
	'Tag','sfwave');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 51 150 20], ...
	'String','Scale factor wave field:', ...
	'Style','text', ...
	'Enable','off', ...
	'Tag','sfwavetext');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull contourradio', ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[91 221 80 20], ...
	'String','Contour', ...
	'Style','radiobutton', ...
	'Tag','contourradio', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Enable','inactive', ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 201 190 20], ...
	'Style','edit', ...
	'Tag','vesselfile');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull loadvessel', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[221 201 50 20], ...
	'String','load', ...
	'Tag','loadvessel');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','seagull afac', ...
	'FontSize',12, ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[181 21 30 20], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','afac');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull vesselcheck', ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 221 70 20], ...
	'String','Vessel', ...
	'Style','checkbox', ...
	'Tag','vesselcheck', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull hullradio', ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[181 221 50 20], ...
	'String','Hull', ...
	'Style','radiobutton', ...
	'Tag','hullradio');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull tritoncheck', ...
	'FontSize',12, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 131 150 20], ...
	'String','Triton wave file', ...
	'Enable','off', ...
	'Style','checkbox', ...
	'Tag','tritoncheck');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'Enable','inactive', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[21 111 190 20], ...
	'Style','edit', ...
	'Tag','tritonfile');
h1 = uicontrol('Parent',h0, ...
	'FontUnits','pixels', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','seagull loadtriton', ...
	'Enable','off', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[221 111 50 20], ...
	'String','load', ...
	'Tag','loadtriton');
m1=uimenu('Parent',h0, ...
   'Label','&Options');
uimenu('Parent',m1, ...
   'Label','Plot &WL logo', ...
   'Checked','on', ...
   'Callback','seagull switchlogo', ...
   'Tag','plotlogo');
uimenu('Parent',m1, ...
   'Label','Save &frames when playing', ...
   'Callback','seagull switchfilesout', ...
   'Tag','saveframes');
mfig=h0;
