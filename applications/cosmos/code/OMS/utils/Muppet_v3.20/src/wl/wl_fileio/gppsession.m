function Out=gppsession(cmd,varargin),
%GPPSESSION Read a GPP session file
%       Struct=GPPSESSION('open',FileName)
%       Who will ever need this?
%
%       Struct=GPPSESSION('open',FileName,'debug')
%       Generates a gppsession.dbg file in the
%       current directory containing debug information.
%
%       Handle=GPPSESSION('plot',Struct,PlotNr)
%       Handle=GPPSESSION('plot',Struct,PlotName)
%       Recreates the requested plot (outline only).

%Author: Bert Jagers

if nargin==0,
  error('Missing command');
end;

switch lower(cmd),
case {'open','read'},
  Out=Local_readsession(varargin{:});
case {'plot'},
  Out=Local_plot(varargin{:});
otherwise,
  error(sprintf('Unknown command: %s',cmd));
end;


function H=Local_plot(Session,plotnr),
switch nargin
case 0,
  error('Not enought input arguments.');
case 1,
  if length(Session.Plot)==1
    plotnr=1;
  end
case 2,
  if ischar(plotnr) & size(plotnr,1)==1,
    i=ustrcmpi(plotnr,{Session.Plot.Name});
    if i<0
      error(sprintf('Specified plot (%s) could not be identified.',plotnr));
    end
    plotnr=i;
  elseif isnumeric(plotnr) & isequal(size(plotnr),[1 1])
    if (length(Session.Plot)<plotnr) | (plotnr<1) | (plotnr~=round(plotnr))
      error('Invalid plot number');
    end
  else
    error('Invalid plot indicator');
  end
end
Plot=Session.Plot(plotnr).Layout;

H=figure('visible','on', ...
         'name',deblank(Session.Plot(plotnr).Name), ...
         'numbertitle','off', ...
         'color','w', ...
         'integerhandle','off');
switch Plot.Unit
case {'cm','stretch'}
  set(H,'paperunits','centimeters', ...
        'papertype','a4', ...
        'paperorientation',Plot.Orientation);
  PaperSize=get(H,'papersize');
  PlotOffset=(PaperSize-Plot.Size)/2;
  PlotSize=Plot.Size;
  set(H,'paperposition',[0 0 PaperSize]);
otherwise
  delete(H)
  error(sprintf('Unknown unit: %s',Plot.Unit));
end;

units0=get(0,'units');
set(0,'units','centimeters');
maxdim=get(0,'screensize');
set(0,'units',units0);

maxdim=maxdim(3:4);
units0=get(H,'units');
set(H,'units','centimeters');
psize=get(H,'papersize');
pos1=0.85*psize*min(maxdim./psize);
pos=[(maxdim-pos1)/2 pos1];
set(H,'position',pos,'units',units0);

if isfield(Plot,'Frame')
  BorderColor='k';
  switch Plot.Frame
  case 0,
    % no frame
  case 1,
    % default frame
    A=axes('parent',H, ...
           'visible','off', ...
           'units','normalized', ...
           'position',[PlotOffset./PaperSize PlotSize./PaperSize], ...
           'xlim',[0 1], ...
           'ylim',[0 1]);
    BDFunction='md_paper edit';
    plottext={{'' '' ''},'','','','','',''};
    for i=1:length(Plot.FrameText)
      switch lower(Plot.FrameText(i).Name)
      case 'company',
        plottext{7}=Plot.FrameText(i).Text;
      case 'main text 1'
        plottext{1}{1}=Plot.FrameText(i).Text;
      case 'main text 2'
        plottext{1}{2}=Plot.FrameText(i).Text;
      case 'main text 3'
        plottext{1}{3}=Plot.FrameText(i).Text;
      case 'upper left'
        plottext{2}=Plot.FrameText(i).Text;
      case 'lower left'
        plottext{5}=Plot.FrameText(i).Text;
      case 'middle'
        plottext{4}=Plot.FrameText(i).Text;
      case 'upper right'
        plottext{3}=Plot.FrameText(i).Text;
      case 'lower right'
        plottext{6}=Plot.FrameText(i).Text;
      end
    end
    switch get(H,'paperorientation')
    case 'portrait',
      b1=0.68;
      b2=(b1+1)/2;
      line([ 0  1 1 0  0 NaN  0 1 1 0 NaN b1 b1 b1 1 NaN b2 b2 NaN b2 b2], ...
           [30 30 0 0 30 NaN  1 1 3 3 NaN  0  3  2 2 NaN  0  1 NaN  2  3]/30, ...
           'parent',A, ...
           'color',BorderColor, ...
           'linewidth',1.5);
      tx=[b1/2 (b2+b1)/2 (b2+1)/2 (b1+1)/2 (b2+b1)/2 (b2+1)/2 b1/2  ];
      ty=[2/30 2.5/30    2.5/30   1.5/30   0.5/30    0.5/30   0.5/30];
      TxtRotate=0;
    case 'landscape',
      b1=0.32;
      b2=b1/2;
      line([30 30 0 0 30 NaN  1 1 3 3 NaN  0  3  2 2 NaN  0  1 NaN  2  3]/30, ...
           [ 0  1 1 0  0 NaN  0 1 1 0 NaN b1 b1 b1 0 NaN b2 b2 NaN b2 b2], ...
           'parent',A, ...
           'color',BorderColor, ...
           'linewidth',1.5);
      tx=[2/30 2.5/30    2.5/30   1.5/30   0.5/30    0.5/30   0.5/30];
      ty=[(b1+1)/2 (b2+b1)/2 b2/2 b1/2 (b2+b1)/2 b2/2 (b1+1)/2  ];
      TxtRotate=270;
    end
    %plottext={{'x1' 'x2' 'x3'},'b1','b2','b3','b4','b5','b6'};
    for i=1:7,
      t=text(tx(i),ty(i),plottext{i}, ...
          'horizontalalignment','center', ...
          'verticalalignment','middle', ...
          'fontname','helvetica', ...
          'tag',sprintf('plottext%i',i), ...
          'buttondownfcn',BDFunction, ...
          'color',BorderColor, ...
          'rotation',TxtRotate);
      if i==7,
        set(t,'fontweight','bold');
      end
    end
  case 2,
    % simple frame
    A=axes('parent',H, ...
           'visible','off', ...
           'units','normalized', ...
           'position',[PlotOffset./PaperSize PlotSize./PaperSize], ...
           'xlim',[0 1], ...
           'ylim',[0 1]);
    line([0 1 1 0 0],[1 1 0 0 1],'parent',A,'color',BorderColor,'linewidth',1.5);
  end
end

for pa=1:length(Plot.PlotArea)
  PA=Plot.PlotArea(pa);
  A=axes('parent',H, ...
         'units','normalized', ...
         'xtick',[], ...
         'ytick',[], ...
         'box','off', ...
         'position',[(PlotOffset+PA.Position)./PaperSize PA.Size./PaperSize]);
  for i=1:length(PA.Axis)
    switch lower(PA.Axis(i).Location)
    case {'bottom','left'}
      X='x';
      if strcmp(lower(PA.Axis(i).Location),'left')
        X='y';
      end
      xlim=[PA.Axis(i).Start PA.Axis(i).Stop];
      xdir='normal';
      if xlim(2)<xlim(1)
        xlim=fliplr(xlim);
        xdir='reverse';
      end
      set(A,[X 'lim'],xlim,[X 'dir'],xdir)
      set(get(A,[X 'label']),'string',PA.Axis(i).Text)
      if isequal(PA.Axis(i).StepSize,999.999)
        set(A,[X 'tickmode'],'auto')
      else
        xt=xlim(1):PA.Axis(i).StepSize:xlim(2);
        if xt(end)~=xlim(2),
          xt(end+1)=xlim(2);
        end
        switch PA.Axis(i).Type
        case 'time-axis'
          %xtl(1:length(xt))={''};
          if PA.Axis(i).StepSize>365
            xtl=cellstr(datestr(xt,10));
          elseif PA.Axis(i).StepSize>30
            xtl=cellstr(datestr(xt,12));
          elseif PA.Axis(i).StepSize>1
            xtl=cellstr(datestr(xt,6));
          elseif PA.Axis(i).StepSize>1
            xtl=cellstr(datestr(xt,6));
          else
            st=PA.Axis(i).StepSize*24*60;
            if abs(st-round(st))<1/60 % no seconds
              xtl=cellstr(datestr(xt,15));
            else % seconds
              xtl=cellstr(datestr(xt,13));
            end
          end
          xtl{1}=datestr(xlim(1),0);
          xtl{end}=datestr(xlim(2),0);
          set(A,[X 'tick'],xt, ...
                [X 'ticklabel'],xtl)
        otherwise,
          set(A,[X 'tick'],xt)
        end
      end
    case 'right',
      if PA.Axis(i).Visible
        set(A,'box','on');
      end
    end
  end
  xm=mean(get(A,'xlim'));
  ym=mean(get(A,'ylim'));
  if isstruct(PA.Dataset)
    Str={PA.Dataset.Name};
  else
    Str='Empty plot';
  end;
  text(xm,ym,Str, ...
         'parent',A, ...
         'horizontalalignment','center', ...
         'verticalalignment','middle');
  if ~isempty(PA.Legend)
    L=axes('parent',H, ...
         'units','normalized', ...
         'xtick',[], ...
         'ytick',[], ...
         'box','on', ...
         'position',[(PlotOffset+PA.Legend.Position)./PaperSize PA.Legend.Size./PaperSize]);
  end
end


function Session=Local_readsession(filename,dbg),
if nargin>1,
  dbg=fopen('gppsession.dbg','w');
  fprintf('Writing debug information to %i: %s\n',dbg,fopen(dbg));
else
  dbg=0;
end
Session.Check='NotOK';
if nargin==0,
  [fn,pn]=uigetfile('*.ssn','Select GPP session file ...');
  if ~ischar(fn)
    return
  end;
  filename=[pn fn];
end;
Session.Check='NotOK';
Session.FileName=filename;
Session.Type='GPP-Session';
Session.Dataset=[];
Session.Plot=[];
Session.Description={};
Session.Version=[1 0];
fid=fopen(filename,'r');

while ~feof(fid),
  Line=getnext(fid,dbg);
  if feof(fid), break; end;
  
  Field=strtok(lower(Line));
  switch Field,
  case 'dataset-def',
    Session.Dataset(end+1)=Local_readdatasetdef(fid,Line,dbg);
  case 'resultant-dataset',
    Session.Dataset(end+1)=Local_readresultantdatasetdef(fid,Line,dbg);
  case 'plot',
    Session.Plot(end+1)=Local_readplot(fid,Line,dbg);
  case 'version',
    % version 2 minor 0
    Session.Version=sscanf(Line,'%*s %i %*s %i',[1 2]);
  case 'description',
    Session.Description=Local_readdescription(fid,Line,dbg);
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
end;

fclose(fid);
if dbg,
  fclose(dbg);
end
Session.Check='OK';


function Str=Local_readdescription(fid,Line,dbg);
%description
Str={};
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'end-description',
    %end-description
    break
  otherwise
    Str{end+1}=Line;
  end;
  Line=getnext(fid,dbg);
end;


function Dataset=Local_readdatasetdef(fid,Line,dbg);
%dataset-def 'Salinity - layer 10'
[Quotes,Line]=findquotes(Line);
Dataset.Name=Line(Quotes(1)+1:Quotes(2)-1);
Dataset.Props=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'parent',
    %   parent     'Salinity-raai 24-meter'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Parent=Line(Quotes(1)+1:Quotes(2)-1);
  case 'type',
    %   type       'TIMESERIES'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Type=Line(Quotes(1)+1:Quotes(2)-1);
  case 'subtype',
    %   subtype    'SINGLE'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Subtype=Line(Quotes(1)+1:Quotes(2)-1);
  case 'topography',
    %   topography 'NONE'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Topography=Line(Quotes(1)+1:Quotes(2)-1);
  case 'model',
    %   model      'DELFT3D'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Model=Line(Quotes(1)+1:Quotes(2)-1);
  case 'filetype',
    %   filetype   'ODS_TRISULA_HIS_NEFIS'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Filetype=Line(Quotes(1)+1:Quotes(2)-1);
  case 'files',
    %   files
    %      "trih-tfl.dat"
    %      "trih-tfl.def"
    %      ""
    %   end-files
    i=1;
    Line=getnext(fid,dbg);
    while ~strcmp(strtok(lower(Line)),'end-files'),
      Quotes=findstr(Line,'"');
      Dataset.Props.File{i}=Line(Quotes(1)+1:Quotes(2)-1);
      i=i+1;
      Line=getnext(fid,dbg);
    end;
  case 'parameter',
    %   parameter 'water level'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Parameter=Line(Quotes(1)+1:Quotes(2)-1);
  case 'parameters',
    %   parameters
    %      'Salinity' 20
    %   end-parameters
    i=1;
    Line=getnext(fid,dbg);
    while ~strcmp(strtok(lower(Line)),'end-parameters'),
      [Quotes,Line]=findquotes(Line);
      Dataset.Props.Parameter(i).Name=Line(Quotes(1)+1:Quotes(2)-1);
      Dataset.Props.Parameter(i).Value=str2num(Line(Quotes(2)+1:end));
      i=i+1;
      Line=getnext(fid,dbg);
    end;
  case 'time',
    %   time 1998/01/01 00:00:00
    [str,remainder]=strtok(Line);
    Dataset.Props.Time=sscanf(remainder,'%4i/%2i/%2i %2i:%2i:%2i');
  case 'all-times',
    %   all-times
    Dataset.Props.Times='all';
  case 'times',
    %   times
    %      number     1001
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      Dataset.Props.Times.Number=str2num(remainder);
    %      start-time 1992/09/01 00:00:00
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      V=sscanf(remainder,'%d/%2d/%2d %2d:%2d:%2d');
      Dataset.Props.Times.Start=datenum(V(1),V(2),V(3),V(4),V(5),V(6));
    %      stop-time  1992/09/01 01:40:00
    Line=getnext(fid,dbg);
      V=sscanf(remainder,'%d/%2d/%2d %2d:%2d:%2d');
      Dataset.Props.Times.Stop=datenum(V(1),V(2),V(3),V(4),V(5),V(6));
    %      timestep   0:00:00:06
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      V=sscanf(remainder,'%d:%d:%d:%d');
      Dataset.Props.Times.Step=(((V(1)*24+V(2))*60+V(3))*60+V(4))/3600/24;
    %   end-times
    Line=getnext(fid,dbg);
  case 'layer',
    %   layer 1
    [str,remainder]=strtok(Line);
    Dataset.Props.Layer=sscanf(remainder,'%i');
  case 'whole-grid',
    %   whole-grid
    Dataset.Props.WholeGrid=1;
  case 'location',
    %   location 'm  2'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Location=Line(Quotes(1)+1:Quotes(2)-1);
  case 'list-locations',
    %   list-locations
    %      '(12,4)'
    %   end-list-locations
    i=1;
    Line=getnext(fid,dbg);
    while ~strcmp(strtok(lower(Line)),'end-list-locations'),
      [Quotes,Line]=findquotes(Line);
      Dataset.Props.Location(i).Name=Line(Quotes(1)+1:Quotes(2)-1);
      i=i+1;
      Line=getnext(fid,dbg);
    end;
  case 'location-names',
    %   location-names
    %      'raai 24-meter' 3
    %   end-location-names
    i=1;
    Line=getnext(fid,dbg);
    while ~strcmp(strtok(lower(Line)),'end-location-names'),
      [Quotes,Line]=findquotes(Line);
      Dataset.Props.Location(i).Name=Line(Quotes(1)+1:Quotes(2)-1);
      Dataset.Props.Location(i).Value=str2num(Line(Quotes(2)+1:end));
      i=i+1;
      Line=getnext(fid,dbg);
    end;
  case 'location-matrix',
    %   location-matrix
    %      start    3 0 9
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      Dataset.Props.LocationMatrix.Start=sscanf(remainder,'%i',[1 3]);
    %      stop     3 0 9
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      Dataset.Props.LocationMatrix.Stop=sscanf(remainder,'%i',[1 3]);
    %      stepsize 1 1 1
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      Dataset.Props.LocationMatrix.StepSize=sscanf(remainder,'%i',[1 3]);
    %   end-location-matrix
    Line=getnext(fid,dbg);
  case 'end-dataset-def',
    %end-dataset-def
    break
  case '#',
    %skip comment
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function Dataset=Local_readresultantdatasetdef(fid,Line,dbg);
%resultant-dataset 'water level-1998/01/01 00:00:00 - N-line 2'
[Quotes,Line]=findquotes(Line);
Dataset.Name=Line(Quotes(1)+1:Quotes(2)-1);
Dataset.Props=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case {'operation','binary-operation'},
    %   operation 'SelectGridLine'
    %   binary-operation 'SubtractData'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Operation=Line(Quotes(1)+1:Quotes(2)-1);
  case 'first-operand'
    %   first-operand    'DP-1992/11/11 00:00:00'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Operand1=Line(Quotes(1)+1:Quotes(2)-1);
  case 'second-operand'
    %   second-operand    'DP-1993/02/03 21:40:00'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Operand2=Line(Quotes(1)+1:Quotes(2)-1);
  case 'operand',
    %   operand   'water level-1998/01/01 00:00:00'
    [Quotes,Line]=findquotes(Line);
    Dataset.Props.Operand=Line(Quotes(1)+1:Quotes(2)-1);
  case 'default-options'
    %   default-options
    Dataset.Props.Options=[];
  case 'options',
    %   options
    Dataset.Props.Options=Local_readoptions(fid,Line,dbg);
  case 'parameters',
    %   parameters
    %      'Salinity' 20
    %   end-parameters
    i=1;
    Line=getnext(fid,dbg);
    while ~strcmp(strtok(lower(Line)),'end-parameters'),
      [Quotes,Line]=findquotes(Line);
      Dataset.Props.Parameter(i).Name=Line(Quotes(1)+1:Quotes(2)-1);
      Dataset.Props.Parameter(i).Value=str2num(Line(Quotes(2)+1:end));
      i=i+1;
      Line=getnext(fid,dbg);
    end;
  case 'end-resultant-dataset',
    %end-resultant-dataset
    break
  case '#',
    %skip comment
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function Plot=Local_readplot(fid,Line,dbg);
%plot 'plot-Three plot areas (vertically; portrait)'
[Quotes,Line]=findquotes(Line);
Plot.Name=Line(Quotes(1)+1:Quotes(2)-1);
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'layout',
    %layout 'portrait-s2a' 'Two plot areas (vertically; portrait)'
    Plot.Layout=Local_readlayout(fid,Line,dbg);
  case 'end-plot',
    %end-plot
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function Layout=Local_readlayout(fid,Line,dbg);
%layout 'portrait-s2a' 'Two plot areas (vertically; portrait)'
[Quotes,Line]=findquotes(Line);
Layout.Str1=Line(Quotes(1)+1:Quotes(2)-1);
Layout.Str2=Line(Quotes(3)+1:Quotes(4)-1);
Layout.PlotArea=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'units',
    %units cm
    [str,remainder]=strtok(Line);
      Layout.Unit=strtok(remainder);
  case 'size',
    %size 18 27
    [str,remainder]=strtok(Line);
      Layout.Size=sscanf(remainder,'%f',[1 2]);
  case 'orientation',
    %orientation portrait
    [str,remainder]=strtok(Line);
      Layout.Orientation=strtok(remainder);
  case 'no',
    %no frame
    Layout.Frame=0;
  case 'simple',
    %simple frame
    Layout.Frame=2;
  case {'standard','contains'},
    %standard frame
    %contains frame
    Layout.Frame=1;
  case 'frame',
    %frame
    Line=getnext(fid,dbg);
    i=0;
    while ~feof(fid),
      switch strtok(lower(Line)),
      case 'end-frame',
        %end-frame
        break
      otherwise,
        %'company' 'WL | DELFT HYDRAULICS' font 'simplex roman' 3.5 normal 'Black'
        i=i+1;
        [Quotes,Line]=findquotes(Line);
        Layout.FrameText(i).Name=Line(Quotes(1)+1:Quotes(2)-1);
        Layout.FrameText(i).Text=Line(Quotes(3)+1:Quotes(4)-1);
        Layout.FrameText(i).Font=Local_extractfont(Line(Quotes(4)+1:end),dbg);
      end;
      Line=getnext(fid,dbg);
    end;
  case 'plotarea',
    %plotarea 'upper-area' 'Upper plot area'
    Layout.PlotArea(end+1)=Local_readplotarea(fid,Line,dbg);
  case 'end-layout',
    %end-layout
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function PlotArea=Local_readplotarea(fid,Line,dbg);
%plotarea 'upper-area' 'Upper plot area'
[Quotes,Line]=findquotes(Line);
PlotArea.Str1=Line(Quotes(1)+1:Quotes(2)-1);
PlotArea.Str2=Line(Quotes(3)+1:Quotes(4)-1);
PlotArea.Axis=[];
PlotArea.Dataset=[];
PlotArea.Position=[];
PlotArea.Size=[];
PlotArea.Legend=[];
PlotArea.AreaSettings=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'position',
    %position 3 21
    [str,remainder]=strtok(Line);
      PlotArea.Position=sscanf(remainder,'%f',[1 2]);
  case 'size',
    %size 12 5
    [str,remainder]=strtok(Line);
      PlotArea.Size=sscanf(remainder,'%f',[1 2]);
  case 'legend',
    %legend
    %   position 14.5 22.6
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      PlotArea.Legend.Position=sscanf(remainder,'%f',[1 2]);
    %   size 15 1
    Line=getnext(fid,dbg);
      [str,remainder]=strtok(Line);
      PlotArea.Legend.Size=sscanf(remainder,'%f',[1 2]);
    %   font 'simplex roman' 3 normal 'Black'
    Line=getnext(fid,dbg);
      PlotArea.Legend.Font=Local_extractfont(Line,dbg);
    %end-legend
    Line=getnext(fid,dbg);
  case 'default-area-settings',
    %default-area-settings
    PlotArea.AreaSettings=[];
  case 'area-settings',
    %area-settings
    PlotArea.AreaSettings=Local_readareasettings(fid,Line,dbg);
  case 'axis',
    %axis bottom
    PlotArea.Axis(end+1)=Local_readaxis(fid,Line,dbg);
  case 'dataset',
    PlotArea.Dataset(end+1)=Local_readdataset(fid,Line,dbg);
  case 'end-plotarea',
    %end-plotarea
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function AreaSettings=Local_readareasettings(fid,Line,dbg);
%area-settings
AreaSettings.Font=[];
AreaSettings.SymbolSize=0;
AreaSettings.SymbolDistance=0;
AreaSettings.ColorRamp='';
AreaSettings.Series=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'font',
    %font 'simplex roman' 2.5 normal 'Black'
    AreaSettings.Font=Local_extractfont(Line,dbg);
  case 'symbol-size',
    %symbol-size 2
    [str,remainder]=strtok(Line);
    AreaSettings.SymbolSize=str2num(remainder);
  case 'symbol-distance',
    %symbol-distance 5
    [str,remainder]=strtok(Line);
    AreaSettings.SymbolDistance=str2num(remainder);
  case 'colour-ramp',
    %colour-ramp 'Rainbow'
    [Quotes,Line]=findquotes(Line);
    AreaSettings.ColorRamp=Line(Quotes(1)+1:Quotes(2)-1);
  case 'series-settings',
    %series-settings
    %   'solid  - black'
    %   'dashed - black3'
    %   'dashed - black1'
    %   'dotted - black1'
    %end-series-settings
    Line=getnext(fid,dbg);
    i=0;
    AreaSettings.Series=[];
    while ~feof(fid),
      switch strtok(lower(Line)),
      case 'end-series-settings',
        %end-series-settings
        break
      otherwise,
        i=i+1;
        [Quotes,Line]=findquotes(Line);
        SeriesSettings=Line(Quotes(1)+1:Quotes(2)-1);
        [AreaSettings.Series(i).Line,remainder]=strtok(SeriesSettings);
        [AreaSettings.Series(i).Marker,remainder]=strtok(remainder);
        [AreaSettings.Series(i).Color,remainder]=strtok(remainder);
      end;
      Line=getnext(fid,dbg);
    end;
  case 'end-area-settings',
    %end-area-settings
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function Axis=Local_readaxis(fid,Line,dbg);
%axis bottom
[str,remainder]=strtok(Line);
Axis.Location=strtok(remainder);
Axis.DefaultSettings=0;
Axis.Type='';
Axis.Visible=0;
Axis.Text=0;
Axis.Start=0;
Axis.Stop=0;
Axis.StepSize=0;
Axis.AxisSettings=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  [Keyw,remainder]=strtok(Line);
  switch Keyw,
  case 'type',
    %type     linear-axis
    %type     time-axis
    [str,remainder]=strtok(Line);
    Axis.Type=strtok(remainder);
  case 'visible',
    %visible  yes
    [str,remainder]=strtok(Line);
    Axis.Visible=strcmp(lower(strtok(remainder)),'yes');
  case 'text',
    %text     'current u'
    [Quotes,Line]=findquotes(Line);
    Axis.Text=Line(Quotes(1)+1:Quotes(2)-1);
  case 'start',
    %start    -0.5
    %start    1992/09/01 01:30:00
    switch Axis.Type,
    case 'time-axis',
      V=sscanf(remainder,'%d/%d/%d %d:%d:%d');
      Axis.Start=datenum(V(1),V(2),V(3),V(4),V(5),V(6));
    otherwise,
      [str,remainder]=strtok(Line);
      Axis.Start=str2num(remainder);
    end;
  case 'stop',
    %stop     0.305155
    %stop     1992/09/01 01:40:00
    switch Axis.Type,
    case 'time-axis',
      V=sscanf(remainder,'%d/%d/%d %d:%d:%d');
      Axis.Stop=datenum(V(1),V(2),V(3),V(4),V(5),V(6));
    otherwise,
      [str,remainder]=strtok(Line);
      Axis.Stop=str2num(remainder);
    end;
  case 'stepsize',
    %stepsize 0.1
    %stepsize 0:00:02:00
    switch Axis.Type,
    case 'time-axis',
      V=sscanf(remainder,'%d:%d:%d:%d');
      Axis.StepSize=(((V(1)*24+V(2))*60+V(3))*60+V(4))/3600/24;
    otherwise,
      [str,remainder]=strtok(Line);
      Axis.StepSize=str2num(remainder);
    end;
  case 'default-axis-settings',
    %default-axis-settings
    Axis.DefaultSettings=1;
  case 'axis-settings',
    %axis-settings
    Axis.AxisSettings=Local_readaxissettings(fid,Line,dbg);
  case 'end-axis',
    %end-axis
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function AxisSettings=Local_readaxissettings(fid,Line,dbg);
%axis-settings
AxisSettings=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'axis-colour',
    %axis-colour            'Black'
    [Quotes,Line]=findquotes(Line);
    Axis.Color=Line(Quotes(1)+1:Quotes(2)-1);
  case 'thickness',
    %thickness              0.250000
    [str,remainder]=strtok(Line);
    AxisSettings.Thickness=str2num(strtok(remainder));
  case 'text-font',
    %text-font 'complex roman' 2.5 normal 'Black'
    AxisSettings.TextFont=Local_extractfont(Line,dbg);
  case 'label-font',
    %label-font 'simplex roman' 2.5 normal 'Black'
    AxisSettings.LabelFont=Local_extractfont(Line,dbg);
  case 'major-tick-size',
    %major-tick-size        2.000000
    [str,remainder]=strtok(Line);
    AxisSettings.MajTickSize=str2num(strtok(remainder));
  case 'major-tick-orientation',
    %major-tick-orientation out
    [str,remainder]=strtok(Line);
    AxisSettings.MajTickOrient=lower(strtok(remainder));
  case 'major-ticklines',
    %major-ticklines        no
    [str,remainder]=strtok(Line);
    AxisSettings.MajTickLines=strcmp(lower(strtok(remainder)),'yes');
  case 'minor-ticks',
    %minor-ticks            1
    [str,remainder]=strtok(Line);
    AxisSettings.MinTicks=str2num(strtok(remainder));
  case 'minor-tick-size',
    %minor-tick-size        1.000000
    [str,remainder]=strtok(Line);
    AxisSettings.MinTickSize=str2num(strtok(remainder));
  case 'minor-tick-orientation',
    %minor-tick-orientation in
    [str,remainder]=strtok(Line);
    AxisSettings.MinTickOrient=lower(strtok(remainder));
  case 'minor-ticklines',
    %minor-ticklines        no
    [str,remainder]=strtok(Line);
    AxisSettings.MinTickLines=strcmp(lower(strtok(remainder)),'yes');
  case 'numeric-format',
    %numeric-format         size-dependent
    [str,remainder]=strtok(Line);
    AxisSettings.NumFormat=strtok(remainder);
  case 'decimals',
    %decimals               0
    [str,remainder]=strtok(Line);
    AxisSettings.Decimals=str2num(strtok(remainder));
  case 'end-axis-settings',
    %end-axis-settings
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function Dataset=Local_readdataset(fid,Line,dbg);
%dataset 'current u - layer 4'
[Quotes,Line]=findquotes(Line);
Dataset.Name=Line(Quotes(1)+1:Quotes(2)-1);
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case 'plotroutine'
    %plotroutine 'PlotTimeseries'
    [Quotes,Line]=findquotes(Line);
    Dataset.PlotRoutine=Line(Quotes(1)+1:Quotes(2)-1);
  case 'default-options',
    %default-options
    Dataset.Options=[];
  case 'options',
    %options
    Dataset.Options=Local_readoptions(fid,Line,dbg);
  case 'end-dataset',
    %end-dataset
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function Options=Local_readoptions(fid,Line,dbg);
%options
Options=[];
Line=getnext(fid,dbg);
while ~feof(fid),
  switch strtok(lower(Line)),
  case {'logical','list','string','real','classes-list','integer'},
    [Type,remainder]=strtok(Line);
    Quotes=findstr(remainder,'''');
    Name=remainder(Quotes(1)+1:Quotes(2)-1);
    remainder=remainder(Quotes(2)+1:end);
    switch lower(Type),
    case 'classes-list',
      %classes-list
      Vl=[];
      Line=getnext(fid,dbg);
      while ~feof(fid),
        switch strtok(lower(Line)),
        case 'end-values'
          %end-values -> end of values
          break
        case 'automatic-scaling'
          %automatic-scaling -> no values
          Vl='auto';
          break
        case 'values'
          %values -> start of values
        otherwise
          Vl(end+1)=str2num(Line);
        end
        Line=getnext(fid,dbg);
      end
    case 'logical',
      %logical 'UseAxisRight' false
      Vl=strcmp(strtok(remainder),'true');
    case 'list',
      %list 'TypeLegend' 'Dataset name'
      Quotes=findstr(remainder,'''');
      Vl=remainder(Quotes(1)+1:Quotes(2)-1);
    case 'real',
      %real 'ExtraMissVal' -999
      Vl=sscanf(remainder,'%f',1);
    case 'integer',
      %integer 'SelectedDirection' 2
      Vl=sscanf(remainder,'%i',1);
    case 'string',
      %string 'DateDigitChar' ':'
      Quotes=findstr(remainder,'''');
      Vl=remainder(Quotes(1)+1:Quotes(2)-1);
    end;
    Options=setfield(Options,Name,Vl);
  case 'end-options',
    %end-options
    break
  otherwise
    if dbg, fprintf(dbg,'---> ???\n'); end
  end;
  Line=getnext(fid,dbg);
end;


function Txt=Local_extractfont(Line,dbg),
[str,remainder]=strtok(Line);
Quotes=findstr(remainder,'''');
Txt.Name=remainder(Quotes(1)+1:Quotes(2)-1);
Txt.Color=remainder(Quotes(3)+1:Quotes(4)-1);
remainder=remainder(Quotes(2)+1:Quotes(3)-1);
[str,remainder]=strtok(remainder);
Txt.Size=str2num(str);
Txt.Weight=strrep(remainder,' ','');


function skipuntil(fid,StrSkip,dbg);
Line='';
BlockFirst=1;
while ~strcmp(strtok(lower(Line)),StrSkip),
  if dbg,
    if BlockFirst
      BlockFirst=0;
    else
      fprintf(dbg,'skipping -> %s\n',Line);
    end
  end
  Line=fgetl(fid);
end;
if dbg, fprintf(dbg,'%s\n',Line); end

function Line=getnext(fid,dbg);
Line=fgetl(fid);
if dbg, fprintf(dbg,'%s\n',Line); end
while ~feof(fid) & isempty(deblank(Line)) | isequal(strtok(Line),'#'),
  Line=fgetl(fid);
  if dbg, fprintf(dbg,'%s\n',Line); end
end;

function [Quotes,NLine]=findquotes(Line);
Quotes=findstr('''',Line);
Slash=findstr('\',Line);
SlashQuote=intersect(Quotes-1,Slash);
if isempty(SlashQuote)
  NLine=Line;
else
  NLine=Line;
  NLine(SlashQuote)=[]; % remove slashes before quotes
  SlashQuote=SlashQuote+1-(0:length(SlashQuote)-1); % correct slashquote indices for slash removal
  Quotes=findstr('''',Line); % repeat find quotes
  Quotes=setdiff(Quotes,SlashQuote); % don't return the slashquotes
end
