function display(X)
%Units display function.
%  Called for assignments without terminating semicolon.

loose = isequal(get(0,'FormatSpacing'),'loose');
if loose, disp(' '), end
disp([inputname(1) ' =']);
if loose, disp(' '), end
disp(X)
