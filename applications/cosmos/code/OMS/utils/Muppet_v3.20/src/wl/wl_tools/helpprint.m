function varargout=helpprint(varargin)
%HELPPRINT Print or save a help topic
%    HELPPRINT supports the syntax of the normal HELP command,
%    but it is also possible to redirect the help information
%    to a file or printer. Only the extended syntax is described
%    here.
%
%    HELPPRINT <list of help subjects>   > FileName
%    Write help information on the requested subjects to file.
%
%    HELPPRINT <list of help subjects>   >> FileName
%    Append help information on the requested subjects to file.
%
%    HELPPRINT <list of help subjects>   -d PrinterName
%    Print help information on the requested subjects.
%
%    See also HELP, HELPWIN, HELPDESK.

% (c) copyright 13/10/2000
%     H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

if nargin<2,
  if nargout>0,
    [varargout{1:nargout}]=help(varargin{:});
  else,
    help(varargin{:});
  end;
  return;
elseif strcmp(lower(varargin{end-1}),'-d'), % print to ...
  Printer=varargin{end};
  tempfil=tempname;
  fileopenmode='w';
else,
  Printer='';
  Redirect=varargin{end-1};
  tempfil=varargin{end};
  switch Redirect,
  case '>',
    fileopenmode='w';
  case '>>',
    fileopenmode='a';
  otherwise, % no redirect command found
    if nargout>0,
      [varargout{1:nargout}]=help(varargin{:});
    else,
      help(varargin{:});
    end;
    return;
  end
end

if nargout>0, error('Too many output arguments.'); end;

[fid,emsg]=fopen(tempfil,fileopenmode);
if fid<0,
  error(emsg);
end;

% obtain help text ...
[Txt{1:max(1,nargin-2)}]=help(varargin{1:end-2});

% reshape text ...
for i=1:length(Txt),
  if ~isempty(Txt{i});
    Txt{i}=cellstr(multiline(Txt{i}));
  else
    Txt{i}={sprintf('%s.m not found.',varargin{i});''};
  end;
end;
Txt=cat(1,Txt{:});

% save to (temporary) file ...
fprintf(fid,'%s\n',Txt{:});
fclose(fid);

if ~isempty(Printer),
  % print temporary file ...
  if isunix,
    unix(['lp -c -d',Printer,' ',tempfil]);
    unix(['rm ',tempfil]);
  else,
    dos(['copy ',tempfil,' ',Printer,' | del ',tempfil,' | exit &']);
  end;
end;