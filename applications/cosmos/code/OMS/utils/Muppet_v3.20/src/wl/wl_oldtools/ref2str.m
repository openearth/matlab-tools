function str=ref2str(ref)
% REF2STR creates a string from a reference list
%
%     See also SUBSINDEX

%     Copyright (c)  H.R.A. Jagers  12-05-1996

if nargin>1,
  fprintf(1,' * Too many input arguments\n');
elseif nargin==1,
  if isempty(ref) | isstruct(ref),
    str='';
    for k=1:length(ref),
      if strcmp(ref(k).type,'.'),
        str=[str '.' ref(k).subs];
      elseif strcmp(ref(k).type,'()'),
        str=[str '('];
        for  l=1:length(ref(k).subs),
          if l~=1,
            str=[str ','];
          end;
          str=[str gui_str(ref(k).subs{l})];
        end;
        str=[str ')'];
      elseif strcmp(ref(k).type,'{}'),
        str=[str '{'];
        for  l=1:length(ref(k).subs),
          if l~=1,
            str=[str ','];
          end;
          str=[str gui_str(ref(k).subs{l})];
        end;
        str=[str '}'];
      end;
    end;
  else,
    fprintf(1,' * Expected a reference list as input.\n');
  end;
else
  fprintf(1,' * Too few input arguments\n');
end;