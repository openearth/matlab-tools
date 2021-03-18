function [H,nax] = cltext(clevels,PL)
%CLTEXT Places contour level text in the current window
%
% CALL: [h,ax] = cltext(levels,pl)
%            
%      h,ax    = handles to the lines of text and the axes, respectively.
%      levels  = vector of contour levels or the corresponding percent which the
%                contour line encloses
%      pl      = 0 if levels are the actual contour levels (default)
%                1 if levels are the corresponding percent which the
%                  contour line encloses
%
% CLTEXT creates new axes in the current figure and prints 
%        "Level curves at:"        if pl==0 and
%        "Level curves enclosing:" otherwise
%
%  NOTE: -The handles to the lines of text and the axes may also be found by 
%           h  = findobj(gcf,'tag','cltxt','type','text');
%           ax = findobj(gcf,'tag','cltxt','type','axes');
%        -If axis square command moves the cltext outside the figure box then
%            oax = gca; axes(ax); axis square; axes(oax); 
%         may be used to restore the look.
%
% Examples:
%  z=peaks;cl=max(z(:))-range(z(:))*(.1:.1:.9);contour(z,cl), cltext(cl)
%
%  data = wraylrnd(1,2000,2); f = kdebin(data,'epan',[],[],.5,128);
%  contour(f.x{:},f.f,f.cl),cltext(f.pl,1)
%
% See also  figtext, pdfplot



% History
% revised pab Feb2004
%  made it work with zoom to some extent  
% revised pab Jan2004
% changed todo comments: (+) -> TODO  
% revised pab 22.05.2000 minor changes
% revised pab 28.01.2000
% - prints the text in a separate axes in order to make the printed
%    text independent of the scaling of the rest of the figure etc.
% adopted from pdfplot

% TODO % should be changed to work in the same way as legend does.  
if nargin<1|isempty(clevels)
  return % nothing to do
end
if nargin<2|isempty(PL)
  PL=0;
elseif prod(size(PL))>1
  error('pl must bea scalar: 0 or 1')
end

cax    = gca; % get current axes
cfig   = get(cax,'Parent'); % get current figure
figold = gcf;
if figold~=cfig, 
  figure(cfig);
end

% delete cltext object if it exists 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nax = findobj(cfig,'tag','cltxt'); % find if any cltxt has been made before
if ~isempty(nax),
  % delete old cltext if it exists
  delete(nax),
end 
  
% create new axes for cltext 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cpos   = get(cax,'position'); % current size of axes
heigth = cpos(4)*1/4;
newpos = [cpos(1) cpos(2)+2.9*heigth cpos(3)/2 heigth];
nax    = axes('Position',newpos,'box','off','Visible','off','tag', ...
	      'cltxt');
%,'climmode',get(cax,'climmode'),'clim',get(cax,'clim')); %new axes


textstart_x = 0.036; 
textstart_y = 0.94; 
delta_y     = 2/33;

if (PL==1),
  h1=figtext(textstart_x,textstart_y,'Level curves enclosing:','norm','norm');
else
  h1=figtext(textstart_x,textstart_y,'Level curves at:','norm','norm');
end
set(h1,'FontWeight','Bold','tag','cltxt')

textstart_y = textstart_y - delta_y;

cltxt=num2str(clevels(:),4);
if 1, % removing spaces in front of each line
  [indx indy]=find(isspace(cltxt));
  for ix=indx(:).'
    cltxt=strvcat(cltxt(1:ix-1,:),cltxt(ix,~isspace(cltxt(ix,:))),cltxt(ix+1:end,:) );
  end
end
h2 = figtext(textstart_x,textstart_y,cltxt,'norm','norm','left','top');
set(h2,'tag','cltxt')
if nargout>0
  H=[h1 h2];
end

% create DeleteProxy objects (an invisible text object in
% the first axes) so that the other axes will be deleted
% properly.
DeleteProxy(1) = text('parent',cax,'visible','off',...
    'tag','cltxtDeleteProxy',...
    'handlevisibility','off',...
    'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
DeleteProxy(2) = text('units','normalized','parent',nax,'visible','off',...
    'tag','cltxtDeleteProxy',...
    'handlevisibility','off',...
    'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
set(DeleteProxy(1),'userdata',nax);%get(cfig,'children'));%nax);
set(DeleteProxy(2),'userdata',DeleteProxy(1));


% reset to the old state
%%%%%%%%%%%%%%%%%%%%%%%%%%
set(cfig,'currentaxes',cax(1))

if figold~=cfig,
  figure(figold); 
end

return