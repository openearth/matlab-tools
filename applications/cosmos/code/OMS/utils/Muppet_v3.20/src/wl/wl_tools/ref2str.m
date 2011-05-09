function str=ref2str(ref)
% REF2STR creates a string from a reference list
%
%     See also SUBSINDEX

%     Copyright (c)  H.R.A. Jagers  12-05-1996
%     Updated                       14-08-2000

try,
  str=' ';
  for k=1:length(ref),
    tp=ref(k).type;
    sb=ref(k).subs;
    switch tp,
    case '.',
      str=strcat(str,'.',sb);
    case {'()','{}'},
      % Note: if X is a string num2str(X) equals X!
      %       this is used for X=':'
      str=strcat(str,tp(1),num2str(sb{1}));
      for l=2:length(sb),
        if length(sb{l})>1,
          str=strcat(str,',[',sprintf('%i,',sb{l}(1:end-1)),num2str(sb{l}(end)),']');
        else,
          str=strcat(str,',',num2str(sb{l}));
        end;
      end;
      str=strcat(str,tp(2));
    end;
  end;
catch,
  error('Invalid input to ref2str');
end;
