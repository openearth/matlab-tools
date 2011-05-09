function outvalue=inlasgn(varname,value),
%INLASGN Inline assignment
%        Combines the command
%           I=F2(J);
%           Y=F1(I,I);
%        into
%           Y=F1(INLASGN('I',F2(J)),I);
%        In other languages written as
%           Y=F1(I=F2(J),I)

% Copyright (c), April 11th, 2000
% H.R.A. Jagers, bert.jagers@wldelft.nl
% WL | Delft Hydraulics, The Netherlands, http://www.wldelft.nl

assignin('caller',varname,value);
outvalue=value;