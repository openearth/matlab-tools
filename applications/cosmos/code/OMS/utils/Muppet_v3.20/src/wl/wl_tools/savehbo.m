function savehbo(name, pattern, A)
% savehbo(name, pattern, A)
%
% save a sparse matrix as Harwell-Boeing file
% 
% name     filename of the output file
% pattern  filename extension. This should be 'RUA', 'rua', 'RSA' or 'rsa'
%          R,r stands for real
%          U,u stands for unsymmetric
%          S,s stands for symmetric
%          A,a stands for assembled
% A        matrix
 
[m,n]=size(A);
 
% number of character per line
nc=80;

filename=[name '.' pattern];
pattern=upper(pattern);
switch pattern,
case 'RSA',
  nnzA=nnz(tril(A)); 
case 'RUA',
  nnzA=nnz(A); 
otherwise,
  return;
end; % switch

% number of pointer elements per line
if (nnzA<9999)
  lp=4;
elseif (nnzA<99999)
  lp=5;
else
  lp=8;
end;
ptrfmt=sprintf('%%%dd',lp);
nop=fix(nc/lp); 
 
% number of index elements per line
if (max(m,n)<9999)
  li=4;
elseif (max(m,n)<99999)
  li=5;
else
  li=8;
end;
indfmt=sprintf('%%%dd',li);
noi=fix(nc/li); 
 
% number of value  elements per line
valfmt='%20.13e'; lv=20; nov=fix(nc/lv);  
 
 
ptrcrd=ceil((n+1)/nop);
indcrd=ceil(nnzA/noi);
valcrd=ceil(nnzA/nov);
 
rhscrd=0;
fp=fopen(filename,'w');
 
% write header 
% short form for name
if (length(name)>8)
  name=name(1:8);
elseif (length(name<8))
  name=[name blanks(8-length(name))];
end; % if
 
%if (pattern=='rsa' | pattern=='rua')
%  pattern=setstr(pattern + 'A' - 'a'); % replace by upper
%end;
 
fprintf(fp,'%s from MATLAB%s%s\n', ...
        filename,blanks(nc-20-length(filename)),name);
fprintf(fp,'%14d%14d%14d%14d%14d          \n', ...
        ptrcrd+indcrd+valcrd+rhscrd, ptrcrd, indcrd, valcrd, rhscrd);
fprintf(fp,['%s           %14d%14d%14d%14d          \n'],...
        pattern, m, n, nnzA, 0);
 
fprintf(fp, '(%dI%d)          ',nop,lp); % assumes 9<nop<100, lp<10
fprintf(fp, '(%dI%d)          ',noi,li); % assumes 9<noi<100, li<10
fprintf(fp, '(%dD20.13)                                       \n',nov); % assumes nov<10 
 
% build pointer vector
pointr=ones(1,n+1);
switch pattern,
case 'RSA',
  for i=1:n
      pointr(i+1)=pointr(i)+nnz(A(i:m,i));
  end;
case 'RUA',
  for i=1:n
      pointr(i+1)=pointr(i)+nnz(A(:,i));
  end;
end;
 
k=fix((n+1)/nop);
j=1;
for i=1:k,
  for l=1:nop
    fprintf(fp,ptrfmt,pointr(j));
    j=j+1;
  end;
  fprintf(fp,[blanks(nc-nop*lp) '\n']);
end;
l=0;
while (j<=n+1)
  fprintf(fp,ptrfmt,pointr(j));
  l=l+1;
  j=j+1;
end;
if (l>0)
  fprintf(fp,[blanks(nc-l*lp) '\n']);
end;

 
% build row index vector
l=0;
for i=1:n
  switch pattern,
  case 'RSA',
    [rowind,buff]=find(A(i:m,i));
    rowind=sort(rowind)+i-1;
  case 'RUA',
    [rowind,buff]=find(A(:,i));
    rowind=sort(rowind);
  end;
  j=1;
  while (j<=length(rowind))
    while (l<noi & j<=length(rowind))
      fprintf(fp,indfmt,rowind(j));
      j=j+1;
      l=l+1;
    end; % while
    % new line
    if (l>=noi)
      fprintf(fp,[blanks(nc-noi*li) '\n']);
      l=0;
    end; % if
  end; % while
end; % for i
if (l>0)
  fprintf(fp,[blanks(nc-l*li) '\n']);
end;
 
 
% build value vector
l=0;
for i=1:n
  switch pattern,
  case 'RSA',
    [rowind,buff,values]=find(A(i:m,i));
  case 'RUA',
    [rowind,buff,values]=find(A(:,i));
  end;
  [rowind,buff]=sort(rowind);
  values=values(buff);
  j=1;
  while (j<=length(values))
    while (l<nov & j<=length(values))
      fprintf(fp,valfmt,values(j));
      j=j+1;
      l=l+1;
    end; % while
    % new line
    if (l>=nov)
      fprintf(fp,[blanks(nc-nov*lv) '\n']);
      l=0;
    end; % if
  end; % while j
end; % for i
if (l>0)
  fprintf(fp,[blanks(nc-l*lv) '\n']);
end; % if 

fclose(fp);