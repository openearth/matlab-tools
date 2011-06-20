function [out1,out2]=tdelft3d(in1,in2)
%TDELFT3D conversion procedure for Delft3D date & time
%
%      MatlabDateNumber=TDELFT3D(d3ddate,d3dtime)
%      [d3ddate,d3dtime]=TDELFT3D(MatlabDateNumber)

if nargin==0,

  error('Not enough input arguments.');

elseif (nargin==1) & isequal(size(in1),[1 1]), % [d3ddate,d3dtime]=TDELFT3D(MatlabDateNumber)

  dvec=datevec(in1);
  
  out1=dvec(1)*10000+dvec(2)*100+dvec(3);
  out2=dvec(4)*10000+dvec(5)*100+floor(dvec(6));
  
  if nargout<2,
    out1=[out1;out2];
  end;
  
else, % MatlabDateNumber=TDELFT3D(d3ddate,d3dtime)

  if nargin==1,
    if prod(size(in1))~=2,
      error('Invalid input argument.');
    end;
    in2=in1(2);
    in1=in1(1);
  end;

  Y=fix(in1/10000);
  in1=in1-10000*Y;
  M=fix(in1/100);
  in1=in1-100*M;
  D=in1;

  h=fix(in2/10000);
  in2=in2-10000*h;
  m=fix(in2/100);
  in2=in2-100*m;
  s=in2;

  out1=datenum(Y,M,D,h,m,s);

end;