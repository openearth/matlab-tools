function t = ctranspose(u)
%Units conjugate transpose.  Called for u'.

t = (u.val')*units(base(u));
