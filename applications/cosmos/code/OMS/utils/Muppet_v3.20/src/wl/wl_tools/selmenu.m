function Answer=selmenu(h,varargin)
%SELMENU Contextmenu implementation for making a selection
%      ANSWER = SELMENU (H,STROPT1,STROPT2,STROPT3, ...)
%      Shows a contextmenu at the currentpoint in the specified
%      figure window. Waits until an answer is selected and
%      returns the string of the selected option. The answer
%      will be empty if no selection was made (the user clicked
%      outside the menu).

% (c) 2002 H.R.A. Jagers : bert.jagers@wldelft.nl
%      WL | Delft Hydraulics, The Netherlands

if nargin==1 & strcmp(h,'uim')
  set(get(gcbo,'parent'),'userdata',get(gcbo,'label'))
elseif nargin<2
  error('Too few input arguments');
else
  while ~strcmp(get(h,'type'),'figure')
    h=get(h,'parent');
  end
  ucm=uicontextmenu('parent',h);
  for i=1:length(varargin)
    uimenu('parent',ucm,'label',varargin{i},'callback','selmenu uim');
  end
  set(ucm,'position',get(h,'currentpoint'),'visible','on');
  waitfor(ucm,'visible','off');
  Answer=get(ucm,'userdata');
  delete(ucm);
end