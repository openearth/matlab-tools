function s1 = deblank2(s)
%DEBLANK2 Remove leading and trailing blanks.
%   DEBLANK2(S) removes trailing blanks from string S.

%   Based on DEBLANK by L. Shure, 6-17-92.
%                       Copyright (c) 1984-98 by The MathWorks, Inc.

if ~isempty(s) & ~isstr(s) & ~iscellstr(s)
    warning('Input must be a string.')
end

if isempty(s)
   s1 = s([]);
else
   noncell=0;
   if ~iscellstr(s)
      s={s};
      noncell=1;
   end
   s1=s;
   for i=1:length(s1)
      sloc=s{i};
      % remove trailing blanks
      [r,c] = find(sloc ~= ' ' & sloc ~= 0);
      if isempty(c)
         s1{i} = sloc([]);
      else
         s1{i} = sloc(:,min(c):max(c));
      end
   end
   if noncell
      s1=s1{1};
   end
end
