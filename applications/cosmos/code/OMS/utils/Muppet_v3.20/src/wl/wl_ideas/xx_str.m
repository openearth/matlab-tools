function t = xx_str(x,f)
%XX_STR Number to string conversion for editing.
%       T = XX_STR(X) converts the scalar number  X into a string
%       representation  T  with about  4  digits and an exponent if
%       required. This is useful for labeling plots with the
%       TITLE, XLABEL, YLABEL, and TEXT commands.
%
%       T=XX_STR(X,'vec') converts a vector of numbers into
%       a column vector of strings (i.e. a string matrix).
%
%       See also NUM2STR, INT2STR, SPRINTF, FPRINTF.

%       Copyright (c) H.R.A. Jagers 12-05-1996

if nargin==0,
  fprintf(1,'* At least one input argument expected.\n');
  return;
end;

if ischar(x)
  t = x;
  return;
end;

if isnumeric(x),
  x=double(x);
end;

if nargin==2,
  if strcmp(f,'clock') | strcmp(f,'date'),
    if all(size(x)==[1 3]),
      if strcmp(f,'clock'),
        x=[NaN NaN NaN x];
      elseif strcmp(f,'date'),
        x=[x NaN NaN NaN];
      end;
    end;
    if all(size(x)==[1 6]),
      if ~isnan(x(4)),
        t=[num2str(x(4)) ':'];
        if x(5)<10,
          t=[t '0' num2str(x(5)) ':'];
        else
          t=[t num2str(x(5)) ':'];
        end;
        if x(6)<10,
          t=[t '0' num2str(floor(x(6)))];
        else
          t=[t num2str(floor(x(6)))];
        end;
      else,
        t='';
      end;
      if ~isnan(x(1)),
        N_leap=floor(x(1)/4); % Number of leap years since (and including!) year 0.
        N_leap=N_leap-floor(N_leap/25)+floor(N_leap/100); % Correction for 100 and 400 year periods.
        if x(2)<3, % Don't count the current year as a leap year if it's not past February
          if x(1)==floor(x(1)/4)*4,
            if x(1)==floor(x(1)/100)*100,
              if x(1)==floor(x(1)/400)*400,
                N_leap=N_leap-1;
              end;
            else,
              N_leap=N_leap-1;
            end;
          end;
        end;
        N_month=[0 3 3 6 1 4 6 2 5 0 3 5]; % day shift in a normal year relative to januari
        N_day=5+x(1)+N_leap+N_month(x(2))+x(3);
        N_day=(N_day-floor(N_day/7)*7)+1;
        month=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
        day=['Mon';'Tue';'Wed';'Thu';'Fri';'Sat';'Sun'];
        if ~isempty(t),
          t=[t ' on '];
        end;
        t=[t day(N_day,:) ' '];
        if x(3)>3,
          t=[t num2str(x(3)) 'th'];
        elseif x(3)==1,
          t=[t num2str(x(3)) 'st'];
        elseif x(3)==2,
          t=[t num2str(x(3)) 'nd'];
        elseif x(3)==3,
          t=[t num2str(x(3)) 'rd'];
        end;
          t=[t  ' ' month(x(2),:) ' ' sprintf('%i',x(1))];
      end;
      return;
    elseif all(size(x)==[1 3]),
      t=[num2str(x(1)) ':'];
      if x(2)<10,
        t=[t '0' num2str(x(2)) ':'];
      else
        t=[t num2str(x(2)) ':'];
      end;
      if x(3)<10,
        t=[t '0' num2str(floor(x(3)))];
      else
        t=[t num2str(floor(x(3)))];
      end;
      return;
    else,
      fprintf(1,'* Ignoring format option.\n  ''clock'' can only be used for vector variables of 3 or 6 elements.\n');
    end;
  elseif strcmp(f,'vec'),
    if min(size(x))==1,
      for i=1:length(x),
        % x element might be imaginary
        if imag(x(i))==0,
          st = [sprintf('%.4g',real(x(i)))];
        elseif real(x(i))==0,
          st = [sprintf('%.4gi',imag(x(i)))];
        elseif imag(x(i))>0,
          st = [sprintf('%.4g+%.4gi',real(x(i)),imag(x(i)))];
        else, % imag(x) < 0
          st = [sprintf('%.4g%.4gi',real(x(i)),imag(x(i)))];
        end;
        if i==1,
          t=st;
        else,
          t=str2mat(t,st);
        end;
      end;
      return;
    else,
      fprintf(1,'* Ignoring format option.\n  ''vec'' can only be used for vector variables.\n');
    end;
  elseif strcmp(f,'mat'),
    t=[];
    tl=[];
    if isreal(x),
      for i=1:size(x,1),
        for j=1:size(x,2),
          ts = sprintf(' %12.4g',real(x(i,j)));
          tl=[tl,32*ones(1,12-length(ts)),ts];
        end;
        t=str2mat(t,tl);
        tl=[];
      end;
    else,
      for i=1:size(x,1),
        for j=1:size(x,2),
          % x element might be imaginary
          if imag(x(i,j))==0,
            ts = sprintf('%.4g',real(x(i,j)));
          elseif real(x(i,j))==0,
            ts = sprintf('%.4gi',imag(x(i,j)));
          elseif imag(x(i,j))>0,
            ts = sprintf('%.4g+%.4gi',real(x(i,j)),imag(x(i,j)));
          else, % imag(x(i,j)) < 0
            ts = sprintf('%.4g%.4gi',real(x(i,j)),imag(x(i,j)));
          end;
          tl=[tl,32*ones(1,24-length(ts)),ts];
        end;
        t=str2mat(t,tl);
        tl=[];
      end;
    end;
    return;
  else,
    fprintf(1,'* Ignoring unknown format option.\n');
  end;

else
  if isempty(x),
    t='[]';
    return;
  end;
  sx=size(x);
  % vectors and matrices in brackets, scalars not in brackets
  if max(sx)>1,
    t = '[';
  else,
    t = '';
  end;
  % for all elements of x
  for i=1:sx(1),
    for j=1:sx(2),
      % separator depends on element of x : , ; or ]
      if max(sx)>1,
        if j<sx(2),
          sep=',';
        elseif i<sx(1),
          sep=';';
        else, % last element of matrix or vector
          sep=']';
        end;
      else,
        sep='';
      end;
      % x element might be imaginary
      if imag(x(i,j))==0,
        t = [t,sprintf('%.4g',real(x(i,j))),sep];
      elseif real(x(i,j))==0,
        t = [t,sprintf('%.4gi',imag(x(i,j))),sep];
      elseif imag(x(i,j))>0,
        t = [t,sprintf('%.4g+%.4gi',real(x(i,j)),imag(x(i,j))),sep];
      else, % imag(x) < 0
        t = [t,sprintf('%.4g%.4gi',real(x(i,j)),imag(x(i,j))),sep];
      end;
    end;
  end;
end;