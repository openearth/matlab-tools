function nwstr=sortvarlist(str);
% SORT A LIST OF VARIABLES FORTRAN SOURCE CODE
if ~iscell(str)
  str=cellstr(str);
end
X=strcat(str{:});
cmm=find(X==',');
opb=find(X=='(');
clb=find(X==')');
if length(opb)~=length(clb)
   error('Brackets mismatch');
elseif length(opb)>0
   for k=1:length(opb)
      cmm(cmm>opb(k) & cmm<clb(k))=[];
   end
end
Start=[1 cmm+1];
End=[cmm-1 length(X)];
for k=1:length(Start)
   Y{1,k}=deblank(X(Start(k):End(k)));
end
Y=sort(Y);
Y(2,:)={','};
X=strcat(Y{:});
cmm=cumsum(cellfun('length',Y(1,:)))+(1:size(Y,2));
j=0;
nwstr={};
while 1,
   i=sum(cmm<50);
   j=j+1;
   if i==length(cmm)
     nwstr{j,1}=X(1:end-1);
     break
   else
     nwstr{j,1}=X(1:cmm(i));
   end
   X=X(cmm(i)+1:end);
   cmm=cmm(i+1:end)-cmm(i);
end
disp(strvcat(nwstr{:}))