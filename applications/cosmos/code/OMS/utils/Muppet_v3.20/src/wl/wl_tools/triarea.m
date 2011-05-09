function [TotalArea,TotalVolume]=triarea(Tri,X,Y,Z);
% TRIAREA Computes the area (and volume) covered by a triangulation
%
%      TotalArea=triarea(Tri,X,Y);
%      computes the area covered by a triangulation
%
%      [TotalArea,TotalVolume]=triarea(Tri,X,Y,Z);
%      computes the area and total volume between the surface and the
%      Z=0 plane (above positive, below negative), such that
%      AverageElevation=TotalVolume/TotalArea
%
%      If X, Y, or Z contains NaNs then NaN will be returned as answer.

I=Tri(:,1);
J=Tri(:,2);
K=Tri(:,3);

TriArea=abs((X(I)-X(J)).*(Y(K)-Y(J))-(Y(I)-Y(J)).*(X(K)-X(J)));

TotalArea=sum(TriArea);

if (nargin>3) & (nargout>1),
  TriVol=mean(Z(Tri),2).*TriArea;
  
  TotalVolume=sum(TriVol);
end;