function varargout=octree(cmd,varargin),
% OCTREE read OCTREE files
%
%    FILEINFO=OCTREE('open',FILENAME)
%    Open octree file and return a structure containing
%    information about the file.
%
%    X=OCTREE('read',FILEINFO,INDEX)
%    Read an image from the octree file. Time step indicated
%    by index.
%

% (c) copyright, Delft Hydraulics, 2002
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
   error('Missing command.');
end;

switch cmd,
case 'open',
   Out=Local_otopen(varargin{:});
   varargout={Out};
case 'read',
   [Out,FS]=Local_otread(varargin{:});
   varargout={Out,FS};
otherwise,
   error('Unknown command');
end;


function Structure=Local_otopen(filename),
Structure.Check='NotOK';
Structure.FileType='octree';

if nargin==0 | strcmp(filename,'?'),
   [fname,fpath]=uigetfile('*.oct','Select octree file');
   if ~ischar(fname),
      return;
   end;
   filename=[fpath,fname];
end;
Structure.FileName=filename;

fid=fopen(filename,'r','l');
if fid<0,
   error(['Cannot open ',filename,'.']);
end;

[X,nr]=fread(fid,[1 512],'uint16');
if nr<512
   fclose(fid);
   error('Octree file too small: cannot read header')
end
Structure.NrImage=X(1);
%Structure.MaxNrImage=X(2);
if X(2)==4096
   Structure.MaxNrImage=X(2);
else
   Structure.MaxNrImage=Structure.NrImage;
end
if Structure.NrImage>Structure.MaxNrImage
   fclose(fid);
   error('Unsupported octree file: too many images');
end
Structure.ReverseFlag=X(3)==1111;
Structure.ProducedMode=X(4)==1111;
% check if X(5:end)==0?

[X,Nr]=fread(fid,[1 Structure.MaxNrImage],'uint32');
if Nr<Structure.MaxNrImage
   fclose(fid);
   error('Octree file too small: cannot read image sizes')
end
% check if X(Structure.NrImage+1:end)==0?
Structure.ImSize=X(1:Structure.NrImage);

% check filesize ...
fseek(fid,0,1);
fs1=ftell(fid);
fs2=1024+4*Structure.MaxNrImage+sum(Structure.ImSize);
fclose(fid);
if fs1~=fs2
   error('Invalid octree filesize')
end
Structure.Index=0;
Structure.Data=[];
Structure.Check='OK';


function [Data,S2]=Local_otread(S,index0),
if index0>S.NrImage | index0<0
   error('Timestep out of range')
end
%Gray encoding
v=uint8([1 3 2 6 7 5 4 12 13 15 14 10 11 9 8]);
if index0==S.Index
   Data=S.Data;
   S2=S; 
   Data(Data>0)=v(Data(Data>0));
   return
elseif index0>S.Index
   II=(S.Index+1):index0;
elseif index0<(S.Index/2)
   II=1:index0;
   S.Data=[];
else
   II=S.Index:-1:(index0+1);
end
fid=fopen(S.FileName,'r','l');
try
   S2=S;
   if isempty(S.Data)
%      XX=repmat(uint8(0),4096,4096);
      XX=repmat(uint8(0),480,640);
   else
      XX=S.Data;
   end
   
   for index=II
      % index
      fseek(fid,1024+4*S.MaxNrImage+sum(S.ImSize(1:index-1)),-1);
      Data=fread(fid,[1 S.ImSize(index)],'uint8');
      ld=length(Data);
      
      G=dec2base(0:255,2);
      F=cell(256,1);
      if S.ReverseFlag
         for i=1:256
            F{i}=7-fliplr(find(G(i,:)=='1')-1);
         end
      else
         for i=1:256
            F{i}=fliplr(find(G(i,:)=='1')-1);
         end
      end
      
      i=1;
      %X=repmat(uint8(0),size(XX));
      nrw=size(XX,1);
      while i<=ld
         col=uint8(Data(i));
         if col==0, break; end
         FRI=Data(i+1);
         i=i+2;
         for fri=F{FRI+1}
            FCI=Data(i);
            i=i+1;
            for fci=F{FCI+1}
               ARI=Data(i);
               i=i+1;
               for ari=F{ARI+1}
                  ACI=Data(i);
                  i=i+1;
                  for aci=F{ACI+1}
                     SRI=Data(i);
                     i=i+1;
                     for sri=F{SRI+1}
                        SCI=Data(i);
                        i=i+1;
                        for sci=F{SCI+1}
                           CRI=Data(i);
                           i=i+1;
                           for cri=F{CRI+1}
                              CCI=Data(i);
                              %                        rr=512*fri+64*ari+8*sri+cri+1;
                              %                        cc=512*fci+64*aci+8*sci+F{CCI+1}+1;
                              %                        X(rr,cc)=col;
                              cc=(512*fci+64*aci+8*sci+F{CCI+1})*nrw+512*fri+64*ari+8*sri+cri+1;
%                              X(cc)=col;
                              XX(cc)=bitxor(XX(cc),col);
                              i=i+1;
                           end
                        end
                     end
                  end
               end
            end
         end
      end
%      XX=bitxor(XX,X);
   end
   S2.Data=XX;
   S2.Index=index0;
catch
end
fclose(fid);
Data=XX;
Data(Data>0)=v(Data(Data>0));
