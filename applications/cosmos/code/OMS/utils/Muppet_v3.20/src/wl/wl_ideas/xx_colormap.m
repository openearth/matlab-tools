function h = xx_colormap(MapName,M)
%XX_COLORMAP colormaps
%   XX_COLORMAP(MName,M) returns an M-by-3 matrix containing colormap MName.
%   XX_COLORMAP(MName) is colormap of default length.
%   XX_COLORMAP returns the names of all available maps.

switch nargin,
case 0,
  h={'BrYeCr','GrBrCr','ReOrGr','BlOrGr','BlCrBr','BlGrRd', ...
     'avs','hsv','gray','pink','hot','cool','bone','copper','flag','jet', ...
     'bluemap','reversed bluemap','brownmap','sedconc','white','black'};
  return;
case 1,
  M=32;
end;

if M==0,
  h=[];
  return;
end;
switch lower(MapName),
case 'blgrrd', % Blue (Cyan) Green (Yellow) Red
  C=[0 0   0.75;
     0 1   1;
     0 .8 0;
     1 1   0;
     1 0   0];
  f=[0 .25 .4 .6 1];
  h=zeros(M,3);
  N=size(C,1)-1;
  for i=1:N,
    M1=max(1,min(ceil(f(i)*M)+1,M));
    M2=max(1,min(ceil(f(i+1)*M),M));
    h(M1:M2,:)=ones((M2-M1+1),1)*C(i,:)+transpose(0:(M2-M1))*(C(i+1,:)-C(i,:))/(M2-M1+1);
  end;
case 'bryecr', % brown yellow cream
  C1=[0.675 0.241 0.000];
  C2=[1.000 0.880 0.254];
  C3=[1.000 0.930 0.750];
  M1=ceil(M/2)-1;
  M2=M-M1-2;
  X=ones((M1+1),1)*C1+transpose(0:M1)*(C2-C1)/M1;
  Y=ones((M2+1),1)*C2+transpose(0:M2)*(C3-C2)/M2;
  h=[X;Y];
case 'grbrcr', % gray brown cream
  C1=[0.447 0.447 0.447];
  C2=[0.833 0.514 0.000];
  C3=[1.000 0.930 0.750];
  M1=ceil(M/2)-1;
  M2=M-M1-2;
  X=ones((M1+1),1)*C1+transpose(0:M1)*(C2-C1)/M1;
  Y=ones((M2+1),1)*C2+transpose(0:M2)*(C3-C2)/M2;
  h=[X;Y];
case 'reorgr', % red orange green
  C1=[0.737 0.084 0.149];
  C2=[0.965 0.595 0.000];
  C3=[0.420 0.860 0.000];
  M1=ceil(M/2)-1;
  M2=M-M1-2;
  X=ones((M1+1),1)*C1+transpose(0:M1)*(C2-C1)/M1;
  Y=ones((M2+1),1)*C2+transpose(0:M2)*(C3-C2)/M2;
  h=[X;Y];
case 'blorgr', % blue orange green
  C1=[0.220 0.487 0.737];
  C2=[0.965 0.595 0.000];
  C3=[0.420 0.860 0.000];
  M1=ceil(M/2)-1;
  M2=M-M1-2;
  X=ones((M1+1),1)*C1+transpose(0:M1)*(C2-C1)/M1;
  Y=ones((M2+1),1)*C2+transpose(0:M2)*(C3-C2)/M2;
  h=[X;Y];
case {'blcrbr','sedconc'} % blue cream brown
  C1=[0.220 0.487 0.737];
  C2=[1.000 0.930 0.750];
  C3=[0.833 0.514 0.000];
  M1=ceil(M/4)-1;
  M2=M-M1-2;
  X=ones((M1+1),1)*C1+transpose(0:M1)*(C2-C1)/M1;
  Y=ones((M2+1),1)*C2+transpose(0:M2)*(C3-C2)/M2;
  h=[X;Y];
case 'avs', % AVS/Express
  h=2/3*transpose((M-1):-1:0)/max(M-1,1);
  h=hsv2rgb([h ones(M,2)]);
case 'hsv', % hsv
  h=hsv(M);
case 'gray', % gray
  h=gray(M);
case 'pink', % pink
  h=pink(M);
case 'hot', % hot
  h=hot(M);
case 'cool', % cool
  h=cool(M);
case 'bone', % bone
  h=bone(M);
case 'copper', % coppper
  h=copper(M);
case 'flag', % flag
  h=flag(M);
case 'jet', % jet
  h=jet(M);
case 'bluemap',
  Ix=transpose((1:M)-1)/max(M-1,1);
  r=max(0,Ix-0.3);
  g=max(0,Ix);
  b=min(1,0.5+0.8*Ix);
  h = [r g b];
case 'reversed bluemap',
  h = flipud(xx_colormap('bluemap',M));
case 'brownmap',
  Ix=transpose((1:M)-1)/max(M-1,1);
  r = 0.3+0.6*Ix;
  g = 0.2+0.5*Ix.^2;
  b = 0.2-0.1*Ix;
  h = [r g b];
case 'white',
  h = [ 1 1 1 ; 1 1 1 ];
case 'black',
  h = [ 0 0 0 ; 0 0 0 ];
otherwise, % default all black
  h=zeros(M,3);
end;