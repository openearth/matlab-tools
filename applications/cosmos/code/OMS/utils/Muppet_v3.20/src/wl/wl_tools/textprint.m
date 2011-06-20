function varargout=textprint(varargin)
%TEXTPRINT Print or save a text
%    TEXTPRINT <variable names>   > FileName
%    Write the contents of the variables to file.
%
%    TEXTPRINT <variable names>   >> FileName
%    Write the contents of the variables to file.
%
%    TEXTPRINT <variable names>   -d PrinterName
%    Write the contents of the variables to file.
%
%    See also FPRINTF, EVALC.

% (c) copyright 13/10/2000
%     H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

if nargin<2,
  error('Not enough input arguments.');
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
    error('Syntax error: cannot determine destination.');
  end
end

if nargout>0, error('Too many output arguments.'); end;

[fid,emsg]=fopen(tempfil,fileopenmode);
if fid<0,
  error(emsg);
end;

% obtain help text ...
Txt{1:max(1,nargin-2)}='';
for i=1:length(Txt),
  Txt{i}=evalin('caller',varargin{i});
end;

% reshape text ...
for i=1:length(Txt),
  printit(fid,Txt{i})
end;

% save to (temporary) file ...
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

function printit(fid,Str)
if iscellstr(Str)
  fprintf(fid,'%s\n',Str{:});
elseif iscell(Str)
  for i=1:length(Str(:))
    printit(fid,Str{i})
  end
elseif ischar(Str)
  Str=cellstr(multiline(Str));
  fprintf(fid,'%s\n',Str);
else
  fprintf(fid,'<Non CHAR contents>\n');
end
