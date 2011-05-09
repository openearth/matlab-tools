function wd=mypwd
%MYPWD Show (print) current working directory.
%   MYPWD  displays the current working directory.
%   MYPWD returns the path as visible in the unix
%   shell.
%
%   S = MYPWD returns the current directory in the string S.
%
%   See also CD and PWD.

if ~isunix,
  wd=pwd;
else,
  [s,wd]=unix('pwd');
end;
