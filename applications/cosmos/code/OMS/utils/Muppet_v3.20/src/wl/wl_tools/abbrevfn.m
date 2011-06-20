function shortname=abbrevfn(longname,maxlength),
% ABBREVFN abbreviate filename
%     Removes as many subdirectory sections as are necessary
%     to make filename shorter than 
%
%     ShortName=abbrevfn(LongName,MaxLength)
%     default value for MaxLength equals 32
%

if nargin<2,
  maxlength=32;
end;

if strcmp(computer,'PCWIN'), % d:\...\dir\file
  if length(longname)<maxlength,
    shortname=longname;
    return;
  end;
  I=findstr(longname,filesep);
  if (~isempty(I)) & (I(end)==length(longname)),
    I(end)=[];
  end;
  if (length(I)<2) | ((length(I)==2) & (I(2)-I(1)<=4)),
    shortname=longname;
  else,
    L=I(1)+length(longname)-I+3;
    i=min(find(L<maxlength));
    if isempty(i), i=length(L); end;
    shortname=[longname(1:I(1)) '...' longname(I(i):end)];
  end;
elseif isvms,
  error(sprintf('%s not yet implemented for VMS.',mfilename));
else,
  if length(longname)<maxlength,
    shortname=longname;
    return;
  end;
  I=findstr(longname,filesep);
  if (~isempty(I)) & (I(end)==length(longname)),
    I(end)=[];
  end;
  if (length(I)<1) | ((length(I)==1) & (I(1)<=4)),
    shortname=longname;
  else,
    L=length(longname)-I+3;
    i=min(find(L<maxlength));
    if isempty(i), i=length(L); end;
    shortname=['...' longname(I(i):end)];
  end;
end;