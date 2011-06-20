function ordersurf(A)
%ORDERSURF move patches to back
if nargin==0
  A=findall(gcf,'type','axes');
end
for i=1:length(A)
  chA=allchild(A(i));

  pt=findall(A(i),'type','patch');
  sf=findall(A(i),'type','surface');

  ln=setdiff(chA,[pt(:);sf(:)]);
  set(A(i),'children',[ln(:);pt(:);sf(:)])
end
