function [IDX,MAP]=rgb2idx(X);
% RGB2IDX converts a true color RGB image into an indexed image
%     Usage: [IndexImage,ColorMap]=rgb2idx(RGBImage)

szX=size(X);
cDataType=class(X);
DX=double(X);
DX=reshape(DX,[prod(szX)/3 3]);
[MAP,I,IDX]=unique(DX,'rows');
switch cDataType
case 'uint8'
   MAP=MAP/255;
end
IDX=reshape(IDX,szX(1:2));
