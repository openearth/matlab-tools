function display(u)
%Units disp function.
%  Called by display.

c = base(u);
if all(size(u.val) == 1)
   disp(['     ' num2str(u.val) ' ' c])
   if isequal(get(0,'FormatSpacing'),'loose'), disp(' '), end
else
   if ~isempty(c), disp(['  ' c ' * ']), end
   if isequal(get(0,'FormatSpacing'),'loose'), disp(' '), end
   disp(u.val)
end
