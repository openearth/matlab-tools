function val1=dph(Nfs,t)
%DPH  Read the depth in waterlevel points from file.
if nargin==1
  info=vs_disp('BOTTIM',[]);
  t=info.SizeDim;
end
[val1,Chk]=vs_get(Nfs,'BOTTIM',{t},'DP','quiet');
[nfltp,Chk]=vs_get(Nfs,'PARAMS','NFLTYP','quiet');
switch nfltp
case 2 % MAX
  dp22=val1(2:end,2:end);
  dp22=max(val1(1:end-1,1:end-1),dp22);
  dp22=max(val1(2:end,1:end-1),dp22);
  dp22=max(val1(1:end-1,2:end),dp22);
  val1(2:end,2:end)=dp22;
case 3 % MIN
  dp22=val1(2:end,2:end);
  dp22=min(val1(1:end-1,1:end-1),dp22);
  dp22a=val1(2:end,1:end-1);
  dp22a=min(val1(1:end-1,2:end),dp22a);
  val1(2:end,2:end)=(dp22+dp22a)/2;
otherwise % 0, NO, 1, MEAN
  m=2:size(val1,1);
  n=2:size(val1,2);
  val1(m,n)=(val1(m,n)+val1(m-1,n)+val1(m,n-1)+val1(m-1,n-1))/4;
  val1(1,:)=NaN;
  val1(:,1)=NaN;
end

