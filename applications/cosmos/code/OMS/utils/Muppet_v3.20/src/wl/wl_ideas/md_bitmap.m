function md_bitmap(figlist,filename,scalefac),
% MD_BITMAP Create a TIF file.
%
%    MD_BITMAP(FigureHandle,FileName)
%    creates a bitmap of the same size as shown on the screen.
%
%    MD_BITMAP(FigureHandle,FileName,Alpha)
%    creates a bitmap Alpha times larger than shown on the screen.
%

% Created by H.R.A. Jagers, 1999
%            University of Twente, WL | Delft Hydraulics

if nargin==0,
   shh=get(0,'showhiddenhandles');
   set(0,'showhiddenhandles','on');
   figlist=get(0,'currentfigure');
   set(0,'showhiddenhandles',shh);
end;

if nargin<3,
  scalefac=1;
end;
if scalefac>20,
  error('The scale factor is probably too large.');
else,
  scalefac=round(scalefac*100);
end;

if isempty(figlist),
  return;
end;

i=0;
while i<length(figlist),
  i=i+1;
  if ishandle(figlist(i)),
    if strcmp(get(figlist(i),'type'),'figure'),
      hvis=get(figlist(i),'handlevisibility');
      set(figlist(i),'handlevisibility','on');
      % figure(figlist(i));
      FigStr=sprintf('-f%20.16f',figlist(i));

      PrtMth={'-zbuffer',sprintf('-r%i',scalefac)};
      
      Props={'inverthardcopy','units','paperunits','paperposition'};
      TMPwindowProps=get(figlist(i),Props);
      set(figlist(i),'units','pixels','paperunits','inches','inverthardcopy','off');
      Pos=get(figlist(i),'position');
      set(figlist(i),'paperposition',[0 0 Pos(3:4)/100]); % 100 DPI reference situation

      if nargin<2, % filename not specified
        [fn,pn]=uiputfile('default.tif','Specify file name');
        if ~ischar(pn), return; end;
        filename=[pn fn];
      end;
      try,
%        fprintf(['**** Creating file %s%s ...'],filename);
        print(filename,FigStr,'-dtiff',PrtMth{:});
%        fprintf(1,' done.\n\n');
      catch,
%        fprintf(1,' error encountered.\n\n');
      end;

      set(figlist(i),Props,TMPwindowProps);
      set(figlist(i),'handlevisibility',hvis);
    end;
  end;
end;
