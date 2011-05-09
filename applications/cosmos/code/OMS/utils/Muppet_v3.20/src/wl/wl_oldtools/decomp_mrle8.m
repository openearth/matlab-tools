function UnCodedImg=decomp_mrle8(CodedImg,szImg),
% DECOMP_MRLE8 expands an eight bit Microsoft Run Length Encoded Image
%       UnCodedImg=decomp_mrle8(CodedImg,X)
%       where X is either an image of appropriate size or
%       the size of the uncoded image.

if size(CodedImg,2)==1, % convert CodedImg to row vector
  CodedImg=CodedImg';
end;
if size(szImg)~=[1 2],
  UnCodedImg=szImg;
else,
  UnCodedImg=zeros(szImg);
end;

codenr=1;
horz=1;
vert=size(UnCodedImg,1);
while codenr<length(CodedImg),
  Code=CodedImg(codenr);
  if Code==0, % escape code
    Code=CodedImg(codenr+1);
    if Code==0, % end of line
      horz=1;
      vert=vert-1;
      codenr=codenr+2;
    elseif Code==1, % end of bitmap
      codenr=codenr+2;
      if codenr<=length(CodedImg),
        fprintf(1,'Warning: internal end of image!\n');
        codenr=length(CodedImg)+1;
      end;
    elseif Code==2, % shift
      horz=horz+CodedImg(codenr+2);
      vert=vert-CodedImg(codenr+3);
      codenr=codenr+4;
    else, % run length
      dh=0:(Code-1);
      UnCodedImg(vert,horz+dh)=CodedImg(codenr+2+dh);
      horz=horz+Code;
      codenr=codenr+2+2*ceil(Code/2);
    end;
  else, % repeat colour
    Color=CodedImg(codenr+1);
    dh=0:(Code-1);
    UnCodedImg(vert,horz+dh)=Color*ones(1,Code);
    horz=horz+Code;
    codenr=codenr+2;
  end;
end;
