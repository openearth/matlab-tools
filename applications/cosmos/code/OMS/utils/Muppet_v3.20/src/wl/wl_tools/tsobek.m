function [out1,out2]=tsobek(in1,in2)
%TSOBEK conversion procedure for sobek date & time
%
%      MatlabDateNumber=TSOBEK(sbkdate,SobekTime)
%      [sbkdate,SobekTime]=TSOBEK(MatlabDateNumber)

if nargin==0,
  error('Not enough input arguments.');
elseif nargin==1, % [sbkdate,SobekTime]=TSOBEK(MatlabDateNumber)

  dvec=datevec(in1);
  
  out1=sprintf('%4.4i%2.2i%2.2i',dvec(1:3));
  if in1==round(in1), % integer datenum -> midnight
    out2='24000000';
  else,
    out2=sprintf('%2.2i%2.2i%4.4i',dvec(4:5),floor(dvec(6)*100));
  end;

else, % MatlabDateNumber=TSOBEK(sbkdate,SobekTime)

  sbkdate=abs(in1)-48;
  sbktime=abs(in2)-48;
  
  D=sbkdate(8)+10*sbkdate(7);
  M=sbkdate(6)+10*sbkdate(5);
  Y=sbkdate(4)+10*sbkdate(3)+100*sbkdate(2)+1000*sbkdate(1);
  if isequal(sbktime(1:2),[2 4]), % 24000000 -> 00000000
    dnum=datenum(Y,M,D);
  else,
    s=sbktime(8)/100+sbktime(7)/10+sbktime(6)+10*sbktime(5);
    m=sbktime(4)+10*sbktime(3);
    h=sbktime(2)+10*sbktime(1);
    dnum=datenum(Y,M,D,h,m,s);
  end;

  out1=dnum;

end;