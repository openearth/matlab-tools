function roman = int2roman(n)
%INT2ROMAN Convert integer into roman numeral
%     Str=INT2ROMAN(i)
%     Converts integer i into a roman numeral string.

r = {'','I','V','X','L','C','D','M'};
p = {[],2,[2 2],[2 2 2],[2 3],3,[3 2],[3 2 2],[3 2 2 2],[2 4],4};
x = sprintf('%04d',n) - '0';
roman = [r{p{x(1)+1}+6},r{p{x(2)+1}+4},r{p{x(3)+1}+2},r{p{x(4)+1}}];
