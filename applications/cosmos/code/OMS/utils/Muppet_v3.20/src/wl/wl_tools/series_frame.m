function [OSERIES,Ofilename]=series_frame(varargin)
% SERIES_FRAME saves a figure in one of a series of bitmap images.
%
%   SERIES_FRAME(Handle)
%   Save the figure with the specified handle to a bitmap file in the
%   active series. Default: current figure.
%
%   S=SERIES_FRAME(...,S)
%   Add to the specified series, where S obtained from SERIES_INIT.
%   The number record of S is updated. The active series is changed
%   according to the settings of S.
%
%   S=SERIES_FRAME('state')
%   Return the state of the active series.
%
%   [S,FileName]=SERIES_FRAME(...)
%   Return the name of the created bitmap file.
%
%   Examples:
%
%     series_init('base','bmp')
%     for i=1:10
%       imagesc(magic(i))
%       series_frame
%     end
%
%     S=series_init('base','bmp')
%     for i=1:10
%       imagesc(magic(i))
%       S=series_frame(S,gcf);
%     end
%
%   See also: SERIES_INIT

% (c) copyright 18/10/2000
%     H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

persistent SERIES_animation

if (nargin==2) & strcmp(varargin{1},'store'),
  SERIES_animation=varargin{2};
  if nargout>0,
    OSERIES=[];
    Ofilename='';
  end;
  return;
elseif (nargin==1) & strcmp(lower(varargin{1}),'state'),
  OSERIES=SERIES_animation;
  return;
end;

i=1;
H=[];
SERIES=[];
while i<=nargin,
  if isstruct(varargin{i}),
    SERIES=varargin{i};
  elseif ishandle(varargin{i}) & isequal(size(varargin{i}),[1 1]),
    H=varargin{i};
  else,
    error(sprintf('Error reading argument %i.',i));
  end;
  i=i+1;
end;

if isempty(H),
  H=gcf;
end;

if isempty(SERIES),
  if ~isstruct(SERIES_animation),
    error('Please initiate series creation first using SERIES_INIT');
  else,
    SERIES=SERIES_animation;
  end;
end;
  
if isequal(SERIES.Type(end),'_'),
  % Printing image ...

  Type=SERIES.Type(1:end-1);
  switch lower(Type),
  case {'tif','tiff','png','jpg','jpeg'}
    Ext=Type;
  otherwise % jpgXX or jpegXX
    Ext=Type(Type>57); % keep only the characters
  end
  Type=lower(Type);
  if strcmp(Type(1:3),'jpg')
    Type=strcat('jpeg',Type(4:end));
  elseif strcmp(Type,'tif')
    Type='tiff';
  end
  Props={'inverthardcopy','units','paperunits','paperposition'};
  TMPwindowProps=get(H,Props);
  set(H,'units','pixels','paperunits','inches','inverthardcopy','off');
  Pos=get(H,'position');
  set(H,'paperposition',[0 0 Pos(3:4)/100]); % 100 DPI reference situation

  FigStr=sprintf('-f%20.16f',H);
  FrmtString=strcat('%s%',num2str(SERIES.Digits),'.',num2str(SERIES.Digits),'i.',Ext);
  filename=sprintf(FrmtString,SERIES.Base,SERIES.Number);
  Renderer=strcat('-',lower(get(H,'renderer')));
  MLBversion=version;
  if strcmp(Renderer,'-opengl') & MLBversion(1)<'6',
    % openGL renderer not supported for printing
    % in MATLAB versions before version 6.
    Renderer='-zbuffer';
  end;
  print(filename,FigStr,strcat('-d',Type),'-r100',Renderer);
  set(H,Props,TMPwindowProps);
else,
  % Grabbing and saving image ...
  pause(0.01) % when excluded a scrambled display is obtained, does it depend on the complexity of the figure?
  F=getframe(H);
  M=frame2im(F);
  FrmtString=strcat('%s%',num2str(SERIES.Digits),'.',num2str(SERIES.Digits),'i.%s');
  filename=sprintf(FrmtString,SERIES.Base,SERIES.Number,SERIES.Type);
  imwrite(M,filename);
end;

SERIES.Number=SERIES.Number+1;
SERIES_animation=SERIES;
if nargout>0,
  OSERIES=SERIES;
  Ofilename=filename;
end;

