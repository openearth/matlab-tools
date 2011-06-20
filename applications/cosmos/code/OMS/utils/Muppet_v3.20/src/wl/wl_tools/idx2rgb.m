function X=idx2rgb(IDX,MAP);
% IDX2RGB converts an indexed image into a true color RGB image
%     Usage: RGBImage=idx2rgb(IndexImage,ColorMap)

szX=size(IDX);
if strcmp(class(IDX),'uint8'),
  IDX=double(IDX)+1;
end;
IDX=reshape(IDX,[prod(szX) 1]);
IDX=max(min(IDX,size(MAP,1)),1);

NaNs=isnan(IDX);
MAP=[MAP;NaN NaN NaN];
IDX(NaNs)=size(MAP,1);

X=MAP(IDX,:);
X=reshape(X,[szX 3]);