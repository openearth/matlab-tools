function AxOut=subplots(I,J,K),

switch nargin,
case 0,
  error('Not enough input arguments');
case 1,
  J=I;
  K=1:(I^2);
case 2,
  K=1:(I*J);
end;

ax=zeros(1,length(K));
for k=1:length(K),
  ax(k)=subplot(I,J,K(k));
end;

if nargout>0,
  AxOut=ax;
end;