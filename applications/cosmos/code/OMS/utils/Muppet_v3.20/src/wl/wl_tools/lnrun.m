function lnrun(script)
%LNRUN Run script (doesn't check path).
%   Typically, you just type the name of a script at the prompt to
%   execute it.  This works when the script is on your path.  Use CD
%   or ADDPATH to make the script executable from the prompt.
%
%   RUN supplied by The MathWorks is a convenience function that runs
%   scripts that are not currently on the path. RUN checks whether
%   the path exists using the PWD function. Because PWD expands links
%   the function will not run a script when it is specified using the
%   shorthand notation using the link.
%
%   The LNRUN function provides the same functionality as RUN except
%   for the checking of the path.
%
%   See also CD, ADDPATH.

%   Based on run.m:
%     Copyright (c) 1984-98 by The MathWorks, Inc.
%     $Revision$  $Date$

cur = cd;

if isempty(script), return, end
if ~isunix
  [p,s,ext,ver] = fileparts(lower(script));
else
  [p,s,ext,ver] = fileparts(script);
end
if ~isempty(p),
  if exist(p,'dir'),
    cd(p)
    w = which(s);
    if ~isempty(w),
      % Check to make sure everything **but the path** matches
      if ~isunix
        [wp,ws,wext,wver] = fileparts(lower(w));
      else
        [wp,ws,wext,wver] = fileparts(w);
      end
      % Allow users to choose the .m file and run a .p
      if strcmp(wext,'.p') & strcmp(ext,'.m'),
         wext = '.m';
      end
      if ~isequal(ws,s) | ...
          (~isempty(ext) & ~isequal(wext,ext)),
         if exist([s ext],'file')
           cd(cur)
           error(sprintf('Can''t run %s.',[s ext]));
         else
           cd(cur)
           error(sprintf('Can''t find %s.',[s ext]));
         end
      end
      evalin('caller',s,'cd(cur);error(lasterr)')
    else
      cd(cur)
      error([script ' not found.'])
    end
    cd(cur)
  else
    error([script ' not found.']);
  end
else
  if exist(script)
    evalin('caller',script,'error(lasterr)')
  else
    error([script ' not found.'])
  end
end


