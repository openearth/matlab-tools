function [ImOut,Size]=logicalregions(ImIn,NeighbH,ThresH),
% LOGICALREGIONS segments an image similar to BWLABEL of image processing toolbox
%       [IMOUT,SIZE]=LOGICALREGIONS(IMIN,NEIGHBH) with NEIGHBH=4 or 8
%       [IMOUT,SIZE]=LOGICALREGIONS(IMIN,NEIGHBH,THRESH) removes segments containing
%                    less than THRESH points.

% (c) Copyright 1997, H.R.A. Jagers
%              University of Twente / Delft Hydraulics

if (nargin<2) | (nargin>3),
  fprintf(1,'LOGICALREGIONS requires two or three input arguments.\n');
  return;
end;
M=size(ImIn,1);
N=size(ImIn,2);
ImOut=ImIn+0; % +0 to remove 'logical' status
S=0;
if NeighbH==8,
  i=1;
  for j=1:N,
    if ImOut(i,j)>0,
      if j>1,
        if ImOut(i,j-1)>0,
          ImOut(i,j)=ImOut(i,j-1);
        else,
          S=S+1;
          ImOut(i,j)=S;
        end;
      else,
        S=S+1;
        j=S;
      end;
    end;
  end;
  for i=2:M,
    for j=1:N,
      if ImOut(i,j)>0,
        Sm=max(ImOut(i-1,max(1,j-1):min(N,j+1)));
        if j>1,
          Sm=max(Sm,ImOut(i,j-1));
          if Sm>0,
            ImOut(i,j)=Sm;
          else,
            S=S+1;
            ImOut(i,j)=S;
          end;
        else,
          if Sm>0,
            ImOut(i,j)=Sm;
          else,
            S=S+1;
            ImOut(i,j)=S;
          end;
        end;
      end;
    end;
  end;
  SegmBec=1:S;
  SegmSize=zeros(1,S);
  i=1;
  for j=1:N,
    if ImOut(i,j)>0,
      SegmSize(ImOut(i,j))=SegmSize(ImOut(i,j))+1;
    end;
  end;
  for i=2:M,
    for j=1:N,
      if ImOut(i,j)>0,
        SegmSize(ImOut(i,j))=SegmSize(ImOut(i,j))+1;
        S=[ImOut(i-1,max(1,j-1):min(N,j+1)) ImOut(i,max(1,j-1):min(N,j))];
        S=S(find(S>0));
        Sm=min(SegmBec(S));
        for s=S,
          L=find(SegmBec(S)==s);
          SegmBec(S(L))=Sm*ones(1,length(L));
        end;
      end;
    end;
  end;
elseif NeighbH==4,
  i=1;
  for j=1:N,
    if ImOut(i,j)>0,
      if j>1,
        if ImOut(i,j-1)>0,
          ImOut(i,j)=ImOut(i,j-1);
        else,
          S=S+1;
          ImOut(i,j)=S;
        end;
      else,
        S=S+1;
        j=S;
      end;
    end;
  end;
  for i=2:M,
    for j=1:N,
      if ImOut(i,j)>0,
        Sm=ImOut(i-1,j);
        if j>1,
          Sm=max(Sm,ImOut(i,j-1));
          if Sm>0,
            ImOut(i,j)=Sm;
          else,
            S=S+1;
            ImOut(i,j)=S;
          end;
        else,
          if Sm>0,
            ImOut(i,j)=Sm;
          else,
            S=S+1;
            ImOut(i,j)=S;
          end;
        end;
      end;
    end;
  end;
  SegmBec=1:S;
  SegmSize=zeros(1,S);
  i=1;
  for j=1:N,
    if ImOut(i,j)>0,
      SegmSize(ImOut(i,j))=SegmSize(ImOut(i,j))+1;
    end;
  end;
  for i=2:M,
    for j=1:N,
      if ImOut(i,j)>0,
        SegmSize(ImOut(i,j))=SegmSize(ImOut(i,j))+1;
        S=[ImOut(i-1,j) ImOut(i,max(1,j-1):min(N,j))];
        S=S(find(S>0));
        Sm=min(SegmBec(S));
        for s=S,
          L=find(SegmBec(S)==s);
          SegmBec(S(L))=Sm*ones(1,length(L));
        end;
      end;
    end;
  end;
end;
S=0;
for i=1:length(SegmBec),
  if SegmBec(i)~=i,
    Sm=SegmBec(SegmBec(i));
    SegmBec(i)=Sm;
    SegmSize(Sm)=SegmSize(Sm)+SegmSize(i);
    SegmSize(i)=0;
  else,
    S=S+1;
    SegmBec(i)=S;
    SegmSize(SegmBec(i))=SegmSize(i);
  end;
end;
[SegmSize,SizeOrder]=sort(-SegmSize(1:S));
SegmSize=-SegmSize;
Sm=S;
if nargin>2,
  L=min(find(SegmSize<ThresH));
  if ~isempty(L),
    for i=1:length(SizeOrder),
      if SizeOrder(i)>=L,
        SizeOrder(i)=0;
        Sm=Sm-1;
      end;
    end;
  end;
end;
for i=1:M,
  for j=1:N,
    if ImOut(i,j)>0,
      ImOut(i,j)=SizeOrder(SegmBec(ImOut(i,j)));
    end;
  end;
end;
Size=SegmSize(1:Sm)';