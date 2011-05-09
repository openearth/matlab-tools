function c = base(u)
%UNITS/BASE Converts .bas and .pow fields to character string.
%  base(u) expands u.pow in terms of powers of u.bas.
%  Eg. if u.bas = {'m','kg','s','A','K','mol','cd'}
%      and u.pow = [3 1 -2 0 0 0 0],
%      then base(u) = 'm^3.kg/s^2'

s = u.bas;
p = u.pow;
c = '';
sep = '*';
if any(p)
   for j = 1:2
      for k = find(p > 0);
         if p(k) == 1
            c = [c sep s{k}];
         else
            c = [c sep s{k} '^' int2str(p(k))];
         end
      end
      p = -p;
      sep = '/';
      if isempty(c)
         c = ' 1';
      end
   end
   c(1) = [];
end
