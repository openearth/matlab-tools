function [chld,names]=childlist(handle);
% CHILDLIST returns a list of all child objects
%    [ChildHandles,ChildNames]=CHILDLIST(Parent)
%
if ~isequal(size(handle),[1 1]) | ~isnumeric(handle) | ~ishandle(handle),
  chld=[];
  names={};
  warning('Invalid handle passed to function CHILDLIST.');
  return;
end;
chld=allchild(handle);
names=listnames(chld);