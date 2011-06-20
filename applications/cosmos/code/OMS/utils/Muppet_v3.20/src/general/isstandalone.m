function I=isstandalone,
%ISSTANDALONE determines stand alone execution
%
%   I=ISSTANDALONE
%   returns 1 if the program is executed in stand
%   alone (compiled) mode and 0 otherwise.
%
%   See also: ISRUNTIME
 
% Author: 17-07-2000, H.R.A. Jagers
%                     Delft, The Netherlands
 
I=0;
try,
  X=whos;
catch,
  I=1;
end;
