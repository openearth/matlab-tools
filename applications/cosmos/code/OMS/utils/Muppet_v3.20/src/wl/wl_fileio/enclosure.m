function varargout=enclosure(cmd,varargin)
%ENCLOSURE Read/write enclosure files and convert enclosures.
%   ENCLOSURE provides support for reading, writing
%   and applying enclosures.
%
%   MN=ENCLOSURE('read',FILENAME)
%   reads a Delft3D or Waqua enclosure file.
%
%   ENCLOSURE('write',FILENAME,MN)
%   ENCLOSURE('write',FILENAME,MN,'waqua')
%   writes a Delft3D (default) or Waqua enclosure file.
%
%   [X,Y]=ENCLOSURE('apply',MN,Xorg,Yorg)
%   applies the enclosure, replacing grid coordinates
%   outside the enclosure by NaN.
%
%   ENC=ENCLOSURE('extract',X,Y)
%   extracts the enclosure from X and Y matrices containing
%   NaN for points outside the enclosure.
%
%   [XC,YC]=ENCLOSURE('coordinates',MN,X,Y)
%   obtain X,Y coordinates from a M,N coordinates of the
%   enclosure.

%   Copyright 2000-2008 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

if nargin==0
   if nargout>0
      varargout=cell(1,nargout);
   end
   return
end

switch cmd
   case 'read'
      Enc=Local_encread(varargin{:});
      varargout={Enc};
   case 'extract'
      Enc=Local_encextract(varargin{:});
      varargout={Enc};
   case 'thindam'
      [MNu,MNv]=Local_enc2uv(varargin{:});
      varargout={MNu MNv};
   case 'apply',
      [X,Y]=Local_encapply(varargin{:});
      varargout={X Y};
   case 'coordinates'
      XY=Local_coordinates(varargin{:});
      if nargout==2
         varargout={XY(:,1) XY(:,2)};
      else
         varargout={XY};
      end
   case 'write'
      Out=Local_encwrite(varargin{:});
      if nargout>0
         varargout{1}=Out;
      end
   otherwise
      error('Unknown command');
end


function Enc=Local_encread(filename)
% * ENC=ENCLOSURE('read',FileName)
%   % Delft3D, Waqua
% read an enclosure file
Enc=[];

if (nargin==0) | strcmp(filename,'?')
   [fname,fpath]=uigetfile('*.*','Select enclosure file');
   if ~ischar(fname)
      return
   end
   filename=fullfile(fpath,fname);
end

% Grid enclosure file
fid=fopen(filename);
if fid>0
   while 1
      line=fgetl(fid);
      if ~ischar(line)
         break
      end
      X=sscanf(line,'%i',[1 2]);
      if length(X)==2,
         Enc=[Enc; X];
      end
   end
   fclose(fid);
else
   error('Error opening file.')
end


function Ind = Local_mask_DP(MN)
Ind=repmat(logical(0),max(MN));
i=1;
sMN1=size(MN,1);
while i<=sMN1
   j=find(MN(:,1)==MN(i,1) & MN(:,2)==MN(i,2));
   j=j(j>i);

   MNseg=MN(i:j,:);
   dMN1=diff(MNseg(:,1));
   ilist=find(dMN1);
   for i=ilist'
      if dMN1(i)>0
         m=MNseg(i,1):(MNseg(i+1,1)-1);
         n=1:MNseg(i,2)-1;
      else
         m=MNseg(i+1,1):(MNseg(i,1)-1);
         n=1:MNseg(i,2)-1;
      end
      Ind(m,n)=~Ind(m,n);
      %imagesc(setnan(~Ind)); drawnow; pause
   end

   i=j+1;
end


function Ind = Local_mask_WL(MN)
Ind=repmat(logical(0),max(MN)+1);
i=1;
first=1;
sMN1=size(MN,1);
while i<=sMN1
   j=find(MN(:,1)==MN(i,1) & MN(:,2)==MN(i,2));
   j=j(j>i);

   MNseg=MN(i:j,:);
   clockw = clockwise(MNseg(:,1),MNseg(:,2));
   outer = double(xor(clockw>0,~first));
   dMN1=diff(MNseg(:,1));
   dMN2=diff(MNseg(:,2));
   ilist=find(dMN1);
   for i=ilist'
      if i==1
         dMNp=dMN2(end);
      else
         dMNp=dMN2(i-1);
      end
      if i==size(dMN1,1)
         dMNn=dMN2(1);
      else
         dMNn=dMN2(i+1);
      end
      if dMN1(i)>0
         m=(MNseg(i,1)+(dMNp>0)*outer+(1-outer)*(dMNp<0)):(MNseg(i+1,1)-(dMNn<0)*outer-(1-outer)*(dMNn>0));
         n=MNseg(i,2)+1-outer:size(Ind,2);
      else
         m=(MNseg(i+1,1)+(dMNn>0)*outer+(1-outer)*(dMNn<0)):(MNseg(i,1)-(dMNp<0)*outer-(1-outer)*(dMNp>0));
         n=MNseg(i,2)+outer:size(Ind,2);
      end
      Ind(m,n)=~Ind(m,n);
      %imagesc(Ind); drawnow
   end

   first=0;
   i=j+1;
end


function [MNu,MNv]=Local_enc2uv(MN)
% * [MNu,MNv]=ENCLOSURE('thindam',MN)
Ind=Local_mask_WL(MN);
%imagesc(Ind)
[m,n]=find(Ind(1:end-1,:)~=Ind(2:end,:));
MNu=[m n m n];
[m,n]=find(Ind(:,1:end-1)~=Ind(:,2:end));
MNv=[m n m n];


function MN=Local_encextract(X,Y)
% * MN=ENCLOSURE('extract',X,Y)
%   % can be implemented using contour
%   % c=contourc((0:62)+0.5,(0:98)+0.5,[0 0;0 Act],[0.5 0.5])
%   %      ---> (i,j+.5)    ---> (i,j) (i,j+1)   ----> remove duplicates
if nargin==1
   Act=~isnan(X);
else
   Act=~isnan(X) & ~isnan(Y);
end
Z=zeros(size(Act)+2);
Z(2:end-1,2:end-1)=Act;
c=contours((0:size(Act,2)+1)+0.5,(0:size(Act,1)+1)+0.5, ...
   Z, [0.5 0.5]);
MN={};
i=1;
while i<size(c,2)
   N=c(2,i);
   mn=zeros(2,2*N);
   c(:,i+(1:N))=floor(c(:,i+(1:N)));
   j=0;
   for n=1:N
      i=i+1;
      if n>1
         if c(1,i)>c(1,i-1) & c(2,i)<c(2,i-1)
            j=j+1;
            mn(:,j)=c(:,i)+[0;1];
         elseif c(1,i)<c(1,i-1) & c(2,i)>c(2,i-1)
            j=j+1;
            mn(:,j)=c(:,i)+[1;0];
         end
      end
      j=j+1;
      mn(:,j)=c(:,i);
   end
   i=i+1;
   mn(:,j+1:end)=[];
   % simplify enclosure: delete double points
   dmn=diff(mn,1,2);
   mn(:,~any(dmn))=[];
   % simplify enclosure: delete points on straight lines
   dmn=diff(mn,1,2);
   mn(:,1+find(~any(diff(dmn,1,2))))=[];
   MN{end+1}=mn;
end
MN=cat(2,MN{:});
% transpose and flip
MN=MN([2 1],:)';


function [X,Y]=Local_encapply(MN,Xorg,Yorg)
% * [X,Y]=ENCLOSURE('apply',ENC,Xorg,Yorg)
%   % can be implemented using inpolygon
%   % in=inpolygon(XI,YI,x-0.5,y-0.5)
Ind = Local_mask_DP(MN);
if size(Ind,1)>size(Xorg,1)
   Ind=Ind(1:size(Xorg,1),:);
else
   Ind(size(Xorg,1),1)=0;
end
if size(Ind,2)>size(Xorg,2)
   Ind=Ind(:,1:size(Xorg,2));
else
   Ind(1,size(Xorg,2))=0;
end
Ind=Ind~=1;
X=Xorg; X(Ind)=NaN;
Y=Yorg; Y(Ind)=NaN;


function XY=Local_coordinates(MNall,X,Y)
% * [XC,YC]=ENCLOSURE('coordinates',ENC,X,Y)
% * [XC,YC]=ENCLOSURE('coordinates',X,Y)
%   % obtain X,Y coordinates from M,N enclosure
if nargin==2
   Y=X;
   X=MNall;
   MNall=Local_encextract(X);
end
XY=cell(0,1);
iMN=sub2ind(size(X)+1,MNall(:,1),MNall(:,2));
%
% Break enclosure up into segments
%
s1=1;
while s1<size(MNall,1)
   if s1>1
      XY{end+1,1}=[NaN NaN];
   end
   s2=find(iMN==iMN(s1));
   s2=min(s2(s2>s1));
   MN=MNall(s1:s2,:);
   s1=s2+1;
   %
   % Expand to single grid cell per step
   %
   dMN=diff(MN,1,1);
   ndMN=max(abs(dMN),[],2);
   mn=zeros(sum(ndMN)+1,2);
   mn(1,:)=MN(1,:);
   i0=1;
   for i=1:size(dMN,1)
      mn(i0+(1:ndMN(i)),:)=MN(repmat(i,1,ndMN(i)),:)+(1:ndMN(i))'*sign(dMN(i,:));
      i0=i0+ndMN(i);
   end
   %
   % Need to shift from surrounding water level points to corner points
   %
   dmn=diff(mn,1,1);
   dmn=dmn([end 1:end 1],:);
   rnm=[1 2 0 3 4]';
   d=rnm(dmn*[1;2]+3);
   x=[ 1 1 1 pi ; 2 1 pi 1 ; 1 pi 1 2 ; pi 3 1 1 ];
   n_mn1=sum(x(sub2ind([4 4],d(2:end),d(1:end-1))));
   mn1 = zeros(n_mn1,2);
   j=1;
   for i=1:size(d,1)-1
      switch d(i+1)+10*d(i)
         case 11 % -2,-2
            mn1(j,:)=mn(i,:);
         case 12 % -2,-1
            mn1(j,:)=mn(i,:);
            j=j+1;
            mn1(j,:)=mn(i,:)-[0 1];
         case 13 % -2,+1
            mn1(j,:)=mn(i,:);
         case 22 % -1,-1
            mn1(j,:)=mn(i,:)-[0 1];
         case 24 % -1,+2
            mn1(j,:)=mn(i,:)-[0 1];
            j=j+1;
            mn1(j,:)=mn(i,:)-[1 1];
            j=j+1;
            mn1(j,:)=mn(i,:)-[1 0];
         case 31 % +1,-2
            mn1(j,:)=mn(i,:);
         case 33 % +1,+1
            mn1(j,:)=mn(i,:);
         case 43 % +2,+1
            mn1(j,:)=mn(i,:)-[1 0];
            j=j+1;
            mn1(j,:)=mn(i,:);
         case 44 % +2,+2
            mn1(j,:)=mn(i,:)-[1 0];
         case 21 % -1,-2
            % will general result in double points, but is sometimes needed to close the path
            mn1(j,:)=mn(i,:)-[0 1];
         case 34 % +1,+2
            % will general result in double points, but is sometimes needed to close the path
            mn1(j,:)=mn(i,:)-[1 0];
         case 42 % +2,-1
            % will general result in double points, but is sometimes needed to close the path
            mn1(j,:)=mn(i,:)-[1 1];
         case {14  % -2,+2
               23  % -1,+1
               32  % +1,-1
               41} % +2,-2
            error('shouldn''t come here.')
      end
      j=j+1;
   end
   %
   % Remove double points
   %
   mn1(all(diff(mn1,1,1)==0,2),:)=[];
   %
   % Convert enclosure to X,Y coordinates
   %
   ind=sub2ind(size(X),mn1(:,1),mn1(:,2));
   XC=X(ind); YC=Y(ind);
   XY{end+1,1}=[XC(:) YC(:)];
end
XY=cat(1,XY{:});

function OK=Local_encwrite(filename,MN,waqopt)
% * ENCLOSURE('write',FileName,MN)
%   % ...,'waqua') for waqua file format
OK=0;

if size(MN,1)>2
   MN=transpose(MN);
end

fid=fopen(filename,'w');
if fid<0
   error('* Could not open output file.')
end
if nargin>3, % waqua format
   fprintf(fid,'e=\n');
end
fprintf(fid,'%5i%5i\n',MN);
fclose(fid);

OK=1;