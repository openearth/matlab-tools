function display(obj)
%DISPLAY Display an INLINE object.

%   Steven L. Eddins, August 1995
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision$  $Date$

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

line1 = sprintf('%s =', inputname(1));

if prod(size(obj))>1,
  line2=[num2str(prod(size(obj))) ' IDEAS objects'];
else,
  if isempty(obj.Type),
    line2=['empty IDEAS object'];
  else,
    line2=['IDEAS ' obj.Type ' object'];
  end;
end;

if (isLoose)
  fprintf('\n');
end
fprintf('%s\n', line1);
if (isLoose)
  fprintf('\n');
end
fprintf('     %s\n', line2);
if (isLoose)
  fprintf('\n');
end
