function Out=tif_frame(H)
% TIF_FRAME saves a figure in one of a series of TIFF images.
%
%   TIF_FRAME(Handle)
%   Save the figure with the specified handle to a TIFF file.
%
%   See also: TIF_INIT

% (c) 1998-2000
% Author:  H.R.A.Jagers
%          University of Twente / Delft Hydraulics, The Netherlands
%          bert.jagers@wldelft.nl

persistent TIF_animation

if (nargin>0) & isstruct(H),
  TIF_animation=H;
  if nargout>0,
    Out='';
  end;
elseif ~isstruct(TIF_animation),
  error('Please initiate TIFF series creation first using TIF_INIT');
else,
  if nargin==0,
    H=gcf;
  end;
  Props={'inverthardcopy','units','paperunits','paperposition'};
  TMPwindowProps=get(H,Props);
  set(H,'units','pixels','paperunits','inches','inverthardcopy','off');
  PosPix=get(H,'position');
  set(H,'units','inches');
  PosInch=get(H,'position');
  DPI=round(PosPix(3)/PosInch(3));
  set(H,'paperposition',[0 0 PosInch(3:4)+[0.000001 0]/DPI]); % DPI reference situation

  FigStr=sprintf('-f%20.16f',H);
  filename=sprintf('%s%3.3i.tif',TIF_animation.Base,TIF_animation.Step);
  Renderer=strcat('-',lower(get(H,'renderer')));
  MLBversion=version;
  if strcmp(Renderer,'-opengl') & MLBversion(1)<'6',
    % openGL renderer not supported for printing
    % in MATLAB versions before version 6.
    Renderer='-zbuffer';
  end;
  print(filename,FigStr,'-dtiff',sprintf('-r%i',DPI),Renderer);

  TIF_animation.Step=TIF_animation.Step+1;
  set(H,Props,TMPwindowProps);
  if nargout>0,
    Out=filename;
  end;
end;
