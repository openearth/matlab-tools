function tagout=ideastag(tagin),
% Tag=IDEASTAG     % Get a new tag
% IDEASTAG(Tag)    % Free a tag

persistent LastTag
mlock

switch nargin,
case 0, % Tag=IDEASTAG     % Get a new tag
  if isempty(LastTag),
    LastTag=1;
  else,
    LastTag=LastTag+1;
  end;
  tagout=['IDEAS - ' num2str(LastTag)];
case 1, % IDEASTAG(Tag)    % Free a tag
  % currently doing nothing
end;