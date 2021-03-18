function [H,ax]=wafostamp(varargin)
%WAFOSTAMP Prints a caption "made by WAFO" in current figure.
%
%  CALL: [h,ax] = wafostamp(stamp);
%        [h,ax] = wafostamp(caption,flag);
%
%     h,ax  = handles to the lines of text and the axes, respectively.
%     stamp = 0, do not print the text, (Default if nargin==0) 
%             1, print the text         (Default if nargin > 0)
%   caption = string caption before 'made by WAFO'  (default [])
%   flag    = string following 'made by WAFO'        (default [])
%             otherwise it is customary to give one of the following flags:
%             '(ER)' - figure is Easily Reproducible ( < 10min to make)
%             '(CR)' - figure is Conditionally Reproducible ( > 10min to make)
%             '(NR)' - figure is Non Reproducible 
%
%  WAFOSTAMP creates new axes and prints the following text near bottom of figure:
%  "caption"                        made by WAFO "date" "flag"
%  
%  NOTE: - wafostamp also install point-and-click editing of
%          all the text objects (title, xlabel, ylabel, etc) of the current figure
%        - The handles to the lines of text and the axes may also be found by 
%           h  = findobj(gcf,'tag','wafostmptxt','type','text');
%           ax = findobj(gcf,'tag','wafostmptxt','type','axes');
%  Edit wafostamp.m to change default values.
%
% Example:
%   plot(sin(0:.1:3)), wafostamp('Sinus plot','(ER)'), hold on
%   plot(sin((0:.1:3)+pi/2)),hold off
%
% See also  figtext

% TODO % may be further improoved by making it work like legend without the box

% Tested on matlab 5.2
% history:
% revised pab 22.05.2000 minor changes
% revised pab 05.02.2000
%  -added deleteproxy
% revised pab 28.01.2000
%  - updated help header
%  - Now writes the text in a separate axes in order to make the printed
%    text independent of the scaling of the figure etc.
%  - added tag to the wafostamp axes
%  - added  point-and-click editing of all the text objects (title, xlabel, ylabel) of the current figure:
% revised pab 21.12.1999
%  - added an extra plot(sin...) in example
% revised pab 20.12.1999
%   -added varargin (caption flag), axes, date
%   -returns matlab to the same state as it was before wafostamp was called  
% adopted from watstamp by ???


[stamp,caption,flag]=stmpchk(varargin);


if stamp
 % remember old axes and state
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %hold_state=ishold;
  cax=gca; % get current axes
  cfig=get(cax,'Parent'); 
  figold=gcf;
  if figold~=cfig, figure(cfig);  end
  if 1 
    % create new axes for caption and  delete old caption if it exists 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax = findobj(cfig,'tag','wafostmptxt'); 
    if ~isempty(ax), delete(ax), end % delete old wafostamp if it exists
    ax = axes('Position',[.01 .01 .99 .05],'Visible','off','tag','wafostmptxt');
  end
  if isempty(caption)
    h1=[];
  else
    h1=figtext(0,0,caption,'norm','norm','left','bottom');
    set(h1,'FontSize',10,'Tag','wafostmptxt')
  end
  h2=figtext(1,0,['made by WAFO ' date,' ',flag,' '],'norm','norm','right','bottom');
  % old call
  %h=figtext(0,-0.1,'made by WAFO','norm','norm','left');
  set(h2,'FontSize',10,'FontAngle','Italic','Tag','wafostmptxt')
  
  
  %  The following two commands install point-and-click editing of
  %   all the text objects (title, xlabel, ylabel) of the current figure:

  set(findall(cfig,'type','text'),'buttondownfcn','edtext')
  set(cfig,'windowbuttondownfcn','edtext(''hide'')')

  % create DeleteProxy objects (an invisible text object in
  % the first axes) so that the other axes will be deleted
  % properly.
  %'tag','wafostmptxt',...
  DeleteProxy(1) = text('parent',cax,'visible','off',...
      'handlevisibility','off',...
      'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
  DeleteProxy(2) = text('parent',ax,'visible','off',...
      'tag','wafostmptxt',...
      'handlevisibility','off',...
      'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
  set(DeleteProxy(1),'userdata',ax);%get(cfig,'children'));%[ax);
  set(DeleteProxy(2),'userdata',DeleteProxy(1));

  if nargout>0
    H=[h1 h2];
  end

  % reset to the old state
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %set(cfig,'currentaxes',cax)  % reset to old axes
  axes(cax)
  if (figold~=cfig), figure(figold); end
  
end


function [stamp,caption,flag]=stmpchk(P);
% gives the correct input values  
N=length(P);

caption=[];flag=[];
if  N==0
  stamp=0; %EDIT HERE to change default value
elseif (N == 1 & isnumeric( P{1}))
  stamp=P{1};
else
  stamp=1;
  caption=P{1};
  if N>1
    flag=P{2}; 
  end	
end

  
