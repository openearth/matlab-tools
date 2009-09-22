function testresult = corner2center_test()
%% CORNER2CENTER_TEST  Test for corner2center
%
% TestName: corner2center_test
%  
% This tests has only one testcase in which the result of corner2center is evaluated.
%
%
%   See also corner2center

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Aug 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $


%% #Description (Name = Corner2Center Unit test & IncludeCode = false & EvaluateCode = true)
% First we create two 3x3 matrix:
 
x1 = [1 2 3;4 5 6;7 8 9];
x2 = [1 2 3;4 5 6;7 8 9];
 
%%
% Then we convert the coordinates of the corners with the help of corner2center. The inverse of this
% function (center2corner) should give us the same coordinates. If so there are two possibilities:
%
% * Both functions are correct
% * Both function contain the same mistake
%

%% #RunCode
testresult = false;
try
%CORNER2CENTER_TEST   regular grid test for center2corner & corner2center
%
%See also: CORNER2CENTER, CENTER2CORNER_TEST

y1 = corner2center(center2corner(x1));
y2 = center2corner(corner2center(x2));

% non-regular matrices are not reversible
%x3 = rand(3);
%y3 = center2corner(corner2center(x2));

testresult = all(y1(:)==x1(:)) & all(y2(:)==x2(:));
end
