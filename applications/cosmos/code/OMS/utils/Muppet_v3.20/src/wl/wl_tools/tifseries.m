function tifseries(argin,N),
% TIFSERIES Save a sequence of TIF files to disk.
%       TIFSERIES('FilesBase')
%          initiates the creation of a series of TIF files.
%          The TIFF filenames will be FileBase000.tif,
%          FileBase001.tif, FileBase002.tif, ...
%       TIFSERIES('FilesBase',N)
%          Start counting at N.
%
%       TIFSERIES(FigHandle)
%          Save the figure with the specified handle to a
%          TIFF file in the current series.
%
%       See also: TIF_INIT, TIF_FRAME

persistent TIF_animation
if (nargin>0) & ischar(argin),
  TIF_animation.Base = argin;
  if nargin>1,
    TIF_animation.Step = N;
  else,
    % automatic detect presence of previously saved files?
    TIF_animation.Step = 0;
  end;
elseif isempty(TIF_animation),
  error('No filebase specified for output series. See help tifseries.');
else,
  if nargin==0,
    H=gcf;
  else,
    H=argin;
  end;
  Props={'inverthardcopy','units','paperunits','paperposition'};
  TMPwindowProps=get(H,Props);
  set(H,'units','pixels','paperunits','inches','inverthardcopy','off');
  Pos=get(H,'position');
  set(H,'paperposition',[0 0 Pos(3:4)/100]); % 100 DPI reference situation

  FigStr=sprintf('-f%20.16f',H);
  filename=sprintf('%s%3.3i.tif',TIF_animation.Base,TIF_animation.Step);
  print(filename,FigStr,'-dtiff','-r100');

  TIF_animation.Step=TIF_animation.Step+1;
  set(H,Props,TMPwindowProps);
end;
