function tagout=di_tag(tagin),
% Tag=DI_TAG     % Get a new tag
% DI_TAG(Tag)    % Free a tag

persistent LastTag
mlock

switch nargin,
case 0, % Tag=DI_TAG     % Get a new tag
  if isempty(LastTag),
    LastTag=1;
  else,
    LastTag=LastTag+1;
  end;
  tagout=['DI - ' num2str(LastTag)];
case 1, % DI_TAG(Tag)    % Free a tag
  % currently doing nothing
end;