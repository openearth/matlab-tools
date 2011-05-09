function AllParts=xx_allitems(OnePart),
% XX_ALLITEMS returns all objects belonging to the specified item
%       AllParts=XX_ALLITEMS(OnePart)
%       returns all objects AllParts belonging to the item of which
%       the one object is specified as OnePart. The main part is
%       returned is the first element of the array AllParts.

if ~isequal(size(OnePart),[1 1]),
  error('Input argument must be scalar.');
end;
if ~ishandle(OnePart),
  error('Input argument must be an object handle.');
end;
ItemTag=get(OnePart,'tag');
ItemParent=get(OnePart,'parent');

AllParts=findobj(allchild(ItemParent),'tag',ItemTag); % column vector with handles

MainPart=[];

if length(AllParts)==1,
  return;
end;

AllUserData=get(AllParts,'userdata');
for i=1:length(AllParts),
  if isstruct(AllUserData{i}),
    if isfield(AllUserData{i},'Type'), % main part contains 'Type' data
      MainPart=AllParts(i);
      AllParts=[MainPart; AllParts(setdiff(1:length(AllParts),i))];
      return;
    end;
  end;
end;
