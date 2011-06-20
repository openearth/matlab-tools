function clipboard(H)
% CLIPBOARD copies a figure to the clipboard as a bitmap
%   CLIPBOARD(Handle)

if isequal(computer,'PCWIN'),
  ih=get(H,'inverthardcopy');
  shh=get(0,'showhiddenhandles');
  set(H,'inverthardcopy','off');
  set(0,'showhiddenhandles','on');
  figure(H);
  print('-dbitmap');
  set(0,'showhiddenhandles',shh);
  set(H,'inverthardcopy',ih);
else,
  % No clipboard printing available
end;