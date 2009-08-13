function unittest = center2corner_test
%CORNER2CENTER_TEST   regular grid test for center2corner & corner2center
%
%See also: CORNER2CENTER, CENTER2CORNER_TEST

 x1 = [1 2 3;4 5 6;7 8 9];
 y1 = corner2center(center2corner(x1));

 x2 = [1 2 3;4 5 6;7 8 9];
 y2 = center2corner(corner2center(x2));

% non-regular matrices are not reversible
%x3 = rand(3);
%y3 = center2corner(corner2center(x2));

if all(y1(:)==x1(:)) & all(y2(:)==x2(:))
   unittest = 1;
else
   unittest = 0;
end

