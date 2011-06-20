function newstack=cmdstack(oldstack,cmd,opt)
% CMDSTACK Adds a command code to a stack of command codes
%     NEWSTACK = CMDSTACK(OLDSTACK,CMD)
%     Adds the command code CMD to the bottom of the OLDSTACK
%     NEWSTACK = CMDSTACK(OLDSTACK,CMD,'top')
%     Adds the command code CMD to the top of the OLDSTACK
%
%     The stack can be either an array or cell array. If it is
%     an array, each command is a row of fixed length. If it is
%     a cell array, the commands may vary in shape.
%
%     Example 1:
%        stack = [1 2; 1 4];
%        stack = cmdstack(stack,[0 6]);
%        results in stack = [1 2; 1 4; 0 6];
%
%     Example 2:
%        stack = { {'cmd1' 1 2} , {'cmd2' 2} };
%        stack = cmdstack(stack,'cmd3');
%        results in stack = { {'cmd1' 1 2} , {'cmd2' 2} , 'cmd3' };

% Copyright (c) H.R.A. Jagers Jan 3 1997

if iscell(oldstack),
  if isempty(oldstack),
    newstack={cmd};
  else,
    if (nargin==3) & strcmp(opt,'top'),
      newstack={cmd,oldstack{:}};
    else,
      newstack={oldstack{:},cmd};
    end;
  end;
else,
  if isempty(oldstack),
    newstack=cmd;
  elseif size(oldstack,2)==size(cmd,2),
    if (nargin==3) & strcmp(opt,'top'),
      newstack=[cmd; oldstack];
    else,
      newstack=[oldstack; cmd];
    end;
  else
    warning('command codes vary in length! New command not added.')
    newstack=oldstack;
  end;
end;