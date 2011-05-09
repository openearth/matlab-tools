function t = transpose(u)
%Units transpose.  Called for u.'.

t = (u.val.')*units(base(u));
