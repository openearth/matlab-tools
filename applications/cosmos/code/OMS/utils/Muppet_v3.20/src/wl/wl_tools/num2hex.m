function s = num2hex(x)
%NUM2HEX double precision number to IEEE hexadecimal conversion.
%       complementary function to HEX2NUM

%	Copyright (c) H.R.A. Jagers 11-29-96

s1=sprintf('%bx',x);
s1=abs(s1);
if isunix,
  s2=s1;
else,
  for i=0:7
    s2(2*(7-i)+1)=s1(2*i+1);
    s2(2*(7-i)+2)=s1(2*i+2);
  end;
end;
s2=setstr(s2);
s=s2;