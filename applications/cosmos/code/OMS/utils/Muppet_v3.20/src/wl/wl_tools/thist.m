function no=thist(y,thresh),
%THIST  Histogram.
%    N = THIST(Y,X), where X is a vector, returns the distribution of Y
%    among bins with thresholds/boundaries specified by X.
%
%    See also: HIST    
    
Nthr=length(thresh);
if isempty(thresh),
  if any(size(y)==1), % vector
    no=length(y);
  else,
    no=repmat(size(y,1),1,size(y,2));
  end;
  return
end;
thresh=sort(thresh);
dist=min(diff(thresh))/3;
if isempty(dist), dist=thresh/2; end;
thresh=sort(cat(1,thresh(:)+dist,thresh(:)-dist));
noh=hist(y,thresh);
if size(noh,1)==1,
  no=zeros(1,Nthr+1);
  no(1:Nthr)=noh(1:2:end);
  no(2:Nthr+1)=no(2:Nthr+1)+noh(2:2:end);
else,
  no=zeros(Nthr+1,size(y,2));
  no(1:Nthr,:)=noh(1:2:end,:);
  no(2:Nthr+1,:)=no(2:Nthr+1,:)+noh(2:2:end,:);
end;


