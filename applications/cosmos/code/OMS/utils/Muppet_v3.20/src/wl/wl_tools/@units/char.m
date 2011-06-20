function c = char(u)
%Units char function.

c = base(u);
if all(size(u.val) == 1)
   c = [num2str(u.val) ' ' c];
else
   c = ['[' num2str(size(u.val,1)) 'x' num2str(size(u.val,2)) 'double] * ' c];
end
