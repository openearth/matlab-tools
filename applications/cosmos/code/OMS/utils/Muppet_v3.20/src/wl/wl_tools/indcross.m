function [xc,yc,zc,val1c,varargout]=indcross(M,N,x,y,z,val1,varargin)
%INDCROSS Arbitrary indexed cross-section
%  [xc,yc,zc,valc]=INDCROSS(M,N,x,y,z,val)
%  where M,N are the reference points for the cross-section:
%  beginpoint, endpoint, direction change points.
%  Supports both data at corners and data at cell centres. The
%  indexing refers to the value matrix.
%
%  [xc,yc,zc,val1c,val2c,...]=INDCROSS(M,N,x,y,z,val1,val2,...)
%  supports arbitrary number of value fields (the values should
%  either all be given at cell corners or all be given at the
%  cell centres).
% 
%  EXAMPLE:
%    figure
%    subplot(1,2,1);
%    [x,y,z]=ndgrid(1:10,1:10,1:10);
%    v=rand(10,10,10);
%    [xc,yc,zc,vc]=indcross([1 5 9 9 5 5 4 4 3 3], ...
%                           [1 5 5 9 9 8 8 7 7 6],x,y,z,v);
%    surf(xc,yc,zc,vc);
%    surface(x(:,:,3),y(:,:,3),z(:,:,3),v(:,:,3));
%    shading interp;
%    daspect([1 1 1])
%    camlight
%
%    subplot(1,2,2);
%    w=rand(9,9,9);
%    [xc,yc,zc,wc]=indcross([1 5 9 9 5 5 4 4 3 3], ...
%                           [1 5 5 9 9 8 8 7 7 6],x,y,z,v);
%    surf(xc,yc,zc,wc);
%    surface((x(:,:,3)+x(:,:,4))/2,(y(:,:,3)+y(:,:,4))/2, ...
%            (z(:,:,3)+z(:,:,4))/2,w(:,:,3));
%    daspect([1 1 1])
%    camlight
%

% (c) 2001, H.R.A.Jagers, bert.jagers@wldelft.nl
%           WL | Delft Hydraulics, The Netherlands

% File history:
%   19/08/2001: created

varargout=cell(1,max(0,nargout-4));
if nargin~=nargout+2
end
OK=isequal(size(M),size(N));
if ~OK, error('M and N vectors have different length.'); end

dM=diff(M(:));
dN=diff(N(:));
OK=all((dM==0) | (dN==0) | abs(dM)==abs(dN));
if ~OK, error('M and N indices variation invalid.'); end

sz=size(val1);
if max(M)>sz(1) | min(M)<1
  error('M value out of range.');
elseif max(N)>sz(2) | min(N)<1
  error('N value out of range.');
end

if isequal(size(x),size(y),size(z),size(val1))
  % expand M,N ...
  npnt=1+sum(max(abs(dM),abs(dN)));
  mm=zeros(npnt,1); nn=mm;
  j=1;
  mm(1)=M(1);
  nn(1)=N(1);
  for i=1:length(dM)
    k=max(abs(dM(i)),abs(dN(i)));
    mm(j+(1:k))=mm(j)+sign(dM(i))*(1:k);
    nn(j+(1:k))=nn(j)+sign(dN(i))*(1:k);
    j=j+k;
  end
  % reshape matrices for data extraction ...
  sz12=sz(1:2); psz12=sz(1)*sz(2);
  szrem=sz(3:end);
  ind=sub2ind(sz12,mm,nn);
  x=reshape(x,[psz12 szrem 1]);
  y=reshape(y,[psz12 szrem 1]);
  z=reshape(z,[psz12 szrem 1]);
  val1=reshape(val1,[psz12 szrem 1]);
  % extract data ...
  xc=x(ind,:); %xc=reshape(xc,[npnt 1 szrem]);
  yc=y(ind,:); %yc=reshape(yc,[npnt 1 szrem]);
  zc=z(ind,:); %zc=reshape(zc,[npnt 1 szrem]);
  val1c=val1(ind,:); %val1c=reshape(val1c,[npnt 1 szrem]);
  for c=1:length(varargout)
    varargin{c}=reshape(varargin{c},[psz12 szrem 1]);
    varargout{c}=varargin{c}(ind,:);
    %val2c=reshape(val2c,[npnt 1 szrem]);
  end
else
  % reshape matrices for data extraction ...
  %
  szx=size(x);
  szx12=szx(1:2); pszx12=szx(1)*szx(2);
  szxrem=szx(3:end);
  x=reshape(x,[pszx12 szxrem 1]);
  y=reshape(y,[pszx12 szxrem 1]);
  %
  szz=size(z);
  szz12=szz(1:2); pszz12=szz(1)*szz(2);
  szzrem=szz(3:end);
  z=reshape(z,[pszz12 szzrem 1]);
  %
  sz12=sz(1:2); psz12=sz(1)*sz(2);
  szrem=sz(3:end);
  val1=reshape(val1,[psz12 szrem 1]);
  for c=1:length(varargout)
    varargin{c}=reshape(varargin{c},[psz12 szrem 1]);
  end
  % expand M,N and extract data ...
  npnt=sum(1+max(abs(dM),abs(dN)));
  xc=zeros([npnt+1 szxrem 1]);
  yc=zeros([npnt+1 szxrem 1]);
  zc=zeros([npnt+isequal(szz12,szx12) szzrem 1]);
  val1c=zeros([npnt szrem 1]);
  for c=1:length(varargout)
    varargout{c}=zeros([npnt szrem 1]);
  end
  j=1;
  indx=sub2ind(szx12,M(1)+(sign(dM(1))<0),N(1)+(sign(dN(1))<0));
  xc(1,:)=(x(indx,:)+ ...
           x(indx+1*(dM(1)==0),:)+ ...
           x(indx+szx(1)*(dN(1)==0),:)+ ...
           x(indx+szx(1)*(dN(1)==0)+1*(dM(1)==0),:))/4;
  yc(1,:)=(y(indx,:)+ ...
           y(indx+1*(dM(1)==0),:)+ ...
           y(indx+szx(1)*(dN(1)==0),:)+ ...
           y(indx+szx(1)*(dN(1)==0)+1*(dM(1)==0),:))/4;
  ind=sub2ind(sz12,M(1),N(1));
  val1c(1,:)=val1(ind,:);
  for c=1:length(varargout)
    varargout{c}(1,:)=varargin{c}(ind,:);
  end
  if isequal(szz12,szx12)
    zc(1,:)=(z(indx,:)+ ...
             z(indx+1*(dM(1)==0),:)+ ...
             z(indx+szx(1)*(dN(1)==0),:)+ ...
             z(indx+szx(1)*(dN(1)==0)+1*(dM(1)==0),:))/4;
  else
    zc(1,:)=z(ind,:);
  end
  for i=1:length(dM)
    k=max(abs(dM(i)),abs(dN(i)));

    mm=M(i)+sign(dM(i))*(1:k);
    nn=N(i)+sign(dN(i))*(1:k);
    indx=sub2ind(szx12,mm+(sign(dM(i))<0),nn+(sign(dN(i))<0));
    ind=sub2ind(sz12,mm-sign(dM(i)),nn-sign(dN(i)));
    if dM(i)==0
      xc(j+(1:k),:)=(x(indx,:)+x(indx+1,:))/2;
      yc(j+(1:k),:)=(y(indx,:)+y(indx+1,:))/2;
      val1c(j+(0:k-1),:)=val1(ind,:);
      for c=1:length(varargout)
        varargout{c}(j+(0:k-1),:)=varargin{c}(ind,:);
      end
      if isequal(szz12,szx12)
        zc(j+(1:k),:)=(z(indx,:)+z(indx+1,:))/2;
      else
        zc(j+(0:k-1),:)=z(ind,:);
      end
    elseif dN(i)==0
      xc(j+(1:k),:)=(x(indx,:)+x(indx+szx(1),:))/2;
      yc(j+(1:k),:)=(y(indx,:)+y(indx+szx(1),:))/2;
      val1c(j+(0:k-1),:)=val1(ind,:);
      for c=1:length(varargout)
        varargout{c}(j+(0:k-1),:)=varargin{c}(ind,:);
      end
      if isequal(szz12,szx12)
        zc(j+(1:k),:)=(z(indx,:)+z(indx+szx(1),:))/2;
      else
        zc(j+(0:k-1),:)=z(ind,:);
      end
    else
      xc(j+(1:k),:)=x(indx,:);
      yc(j+(1:k),:)=y(indx,:);
      val1c(j+(0:k-1),:)=val1(ind,:);
      for c=1:length(varargout)
        varargout{c}(j+(0:k-1),:)=varargin{c}(ind,:);
      end
      if isequal(szz12,szx12)
        zc(j+(1:k),:)=z(indx,:);
      else
        zc(j+(0:k-1),:)=z(ind,:);
      end
    end

    j=j+k+1;
    indx=sub2ind(szx12,M(i+1),N(i+1));
    xc(j,:)=(x(indx,:)+x(indx+1,:)+x(indx+szx(1),:)+x(indx+szx(1)+1,:))/4;
    yc(j,:)=(y(indx,:)+y(indx+1,:)+y(indx+szx(1),:)+y(indx+szx(1)+1,:))/4;
    ind=sub2ind(sz12,M(i+1),N(i+1));
    val1c(j-1,:)=val1(ind,:);
    for c=1:length(varargout)
      varargout{c}(j-1,:)=varargin{c}(ind,:);
    end
    if isequal(szz12,szx12)
      zc(j,:)=(z(indx,:)+z(indx+1,:)+z(indx+szx(1),:)+z(indx+szx(1)+1,:))/4;
    else
      zc(j-1,:)=z(ind,:);
    end
  end
  indx=sub2ind(szx12,M(end)+(sign(dM(end))>0),N(end)+(sign(dN(end))>0));
  xc(end,:)=(x(indx,:)+ ...
           x(indx+1*(dM(end)==0),:)+ ...
           x(indx+szx(1)*(dN(end)==0),:)+ ...
           x(indx+szx(1)*(dN(end)==0)+1*(dM(end)==0),:))/4;
  yc(end,:)=(y(indx,:)+ ...
           y(indx+1*(dM(end)==0),:)+ ...
           y(indx+szx(1)*(dN(end)==0),:)+ ...
           y(indx+szx(1)*(dN(end)==0)+1*(dM(end)==0),:))/4;
  if isequal(szz12,szx12)
    zc(end,:)=(z(indx,:)+ ...
             z(indx+1*(dM(end)==0),:)+ ...
             z(indx+szx(1)*(dN(end)==0),:)+ ...
             z(indx+szx(1)*(dN(end)==0)+1*(dM(end)==0),:))/4;
  end
  %xc=reshape(xc,[size(xc,1) 1 szxrem]);
  %yc=reshape(yc,[size(xc,1) 1 szxrem]);
  %zc=reshape(zc,[size(zc,1) 1 szzrem]);
  %val1c=reshape(val1c,[size(val1c,1) 1 szrem]);
  %if nargin>6
  %  val2c=reshape(val2c,[size(val1c,1) 1 szrem]);
  %end
end
