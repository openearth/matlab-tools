function HOut=scalebar(ax,pos,Width,Str)
% SCALEBAR creates a scalebar in the specified axes.
%
%   Handles = SCALEBAR(AxesHandle,LowerLeft,Width,WidthStr)
%   plots a scalebar in the specified axes with the
%   lowerleft corner at the specified coordinates.
%
%   Handles = SCALEBAR(AxesHandle,LowerLeft)
%   plots a scalebar in the specified axes with the
%   lowerleft corner at the specified coordinates.
%
%   handles = SCALEBAR(AxesHandle)
%   interactively specify lowerleft corner.
%
%   handles = SCALEBAR(...,'?')
%   Asks interactively for the remaining arguments. Otherwise the function will
%   assume default values.

% (c) Copyright, 1998. H.R.A. Jagers
%                      WL | Delft Hydraulics, University of Twente, The Netherlands
%                      bert.jagers@wldelft.nl

if nargin==0
   ax=gca;
end

Ask=0;
if nargin==1 & strcmp(ax,'?')
   Ask=1;
   ax=gca;
end

if nargin==2 & strcmp(pos,'?')
   Ask=1;
end

if nargin<2 | Ask
   % determine location of lower left corner
   CPointer=get(gcf,'pointer');
   set(gcf,'pointer','fullcrosshair');
   Local_waitforbutton(ax);
   XRef=get(ax,'currentpoint');
   set(gcf,'pointer',CPointer);
   YRef=XRef(1,2);
   XRef=XRef(1,1);
else
   XRef=pos(1);
   YRef=pos(2);
end

if nargin==3 & strcmp(Width,'?')
   Ask=1;
end

if nargin<3 | Ask
   % determine useful length of scalebar
   XLim=get(ax,'xlim');
   XScale=(XLim(2)-XLim(1))/2;
   Width=10^floor(log10(XScale));
   if (5*Width)<XScale
      Width=5*Width;
   elseif (2.5*Width)<XScale
      Width=2.5*Width;
   end
end

if Ask
   answer=inputdlg('scalebar length','Please enter',1,{num2str(Width)});
   if ~isempty(answer)
      answer=eval(answer{1},'Width');
      if isnumeric(answer) & isequal(size(answer),[1 1]) & answer>0 & isfinite(answer)
         Width=answer;
      end
   else
      if nargout>0
         HOut=[];
      end
      return
   end
end

% create position coordinates
%  XRelative=ones(3,1)*[(0:5)*Width/5];
%  YRelative=[1;.5;0]*ones(1,6)*Width/25;
XRelative=[0 2 4 6 8; 0 2 4 6 8; 2 4 6 8 10; 2 4 6 8 10]*Width/10;
YRelative=[0 5 0 5 0; 5 10 5 10 5; 5 10 5 10 5; 0 5 0 5 0]*Width/250;
ZLim=get(ax,'zlim'); % ZLocation

% create true color black/white image
Color=[0 1 0 1 0; 1 0 1 0 1];
Color(:,:,3)=Color(:,:,1);
Color(:,:,2)=Color(:,:,1);

if nargin==4 & strcmp(Width,'?')
   Ask=1;
end

if nargin<4 | Ask
   Str=[num2str(Width) ' m'];
end

if Ask
   if nargin<3
      % ask user for string to go with the scalebar
      answer=inputdlg('scalebar text','Please enter',1,{Str});
      if isempty(answer)
         if nargout>0
            HOut=[];
         end
         return
      end
      Str=answer{1};
   end
end

% create scalebar and text
h(3) = patch(XRef+XRelative,YRef+YRelative,ZLim(2)*ones(size(XRelative)),1, ...
   'parent',ax, ...
   'facecolor','k', ...
   'edgecolor','k', ...
   'clipping','off');
h(2) = patch(XRef+XRelative,YRef+Width/25-YRelative,ZLim(2)*ones(size(XRelative)),1, ...
   'parent',ax, ...
   'facecolor','w', ...
   'edgecolor','k', ...
   'clipping','off');
%    h(2) = surface(XRef+XRelative,YRef+YRelative,ZLim(2)*ones(size(XRelative)),Color, ...
%        'parent',ax, ...
%        'clipping','off');
h(1) = text(XRef+Width/2,YRef+1.5*Width/25,ZLim(2),Str, ...
   'parent',ax, ...
   'fontunits','points', ...
   'fontsize',6, ...
   'clipping','off', ...
   'fontname','helvetica', ...
   'horizontalalignment','center', ...
   'verticalalignment','bottom');
if nargout>0
   HOut=h;
end


function Local_waitforbutton(ax)

Fig=get(ax,'parent');

% get children of figure, axes and UI items with callback field
shh=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
FigChild=findobj(get(Fig,'children'));
UIChild=[findobj(Fig,'style','uicontrol');findobj(Fig,'style','uimenu')];
AxChild=findobj(ax);
set(0,'showhiddenhandles',shh);

% backup and set functions and figure userdata
FigChildBDF=get(FigChild,'buttondownfcn');
set(FigChild,'buttondownfcn','');
UIChildCB=get(UIChild,'callback');
set(UIChild,'callback','');
FigDataFields={'userdata','windowbuttondownfcn','windowbuttonmotionfcn','windowbuttonupfcn'};
FigData=get(Fig,FigDataFields);
set(Fig,FigDataFields,{[] '' '' ''});
%set(AxChild,'buttondownfcn','set(gcbf,''userdata'',1);');
set(Fig,'windowbuttondownfcn','set(gcbf,''userdata'',1);');

% wait for press on axes or child of axes
figure(Fig);
waitfor(Fig,'userdata');

% if figure still exists
if ishandle(Fig)
   % restore all functions and callbacks
   set(Fig,FigDataFields,FigData);
   if ~iscell(FigChildBDF)
      FigChildBDF={FigChildBDF};
   end
   for i=1:length(FigChild)
      set(FigChild(i),'buttondownfcn',FigChildBDF{i});
   end
   if ~iscell(UIChildCB)
      UIChildCB={UIChildCB};
   end
   for i=1:length(UIChild)
      set(UIChild(i),'callback',UIChildCB{i});
   end
end