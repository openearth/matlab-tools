function varargout=dioread(dsh,varargin)
%DIOREAD  Read from DelftIO stream.
%        [Data,Flag]=DIOREAD(dsh,nElm,type)
%        where type can be
%           float32 (single), int32 (int), or
%           uint8
%        the returned data will be a 1xnElm
%        row vector of the indicated type.

lv=length(varargin);
if lv/2~=round(lv/2) | lv==0
  error('Incorrect number of input arguments.');
end
lv=lv/2;
nv=max(nargout,1);
if nv~=lv & nv~=lv+1
  error('Incorrect number of output arguments.');
end
varargout=cell(1,nv);
allflag=1;
for i=1:lv
  j=2*(i-1)+1;
  sz=varargin{j};
  if length(sz)<2
     sz(1,2)=1;
  end
  nel=prod(sz);
  [out,flag]=dio_core('read',dsh,nel,varargin{j+1});
  varargout{i}=reshape(out,sz);
  out=[];
  allflag=allflag & flag;
end
if nv==lv+1
  varargout{end}=allflag;
end
