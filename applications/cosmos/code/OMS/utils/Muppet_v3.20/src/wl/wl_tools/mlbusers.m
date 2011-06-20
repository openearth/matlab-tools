function [u,m,s]=mlbusers,
%MLBUSERS Lists the currently active MATLAB users.
%     [UserName,Machine,StartTime]=MLBUSERS
%     returns the username, machine name, and start time of
%     the persons that are currently using MATLAB.

% Bert Jagers, 4/10/2000

if ~isunix,
  [s,w]=dos('\\eland\app\matlab6p1\bin\win32\lmutil lmstat -c \\eland\app\matlab6p1\bin\win32\license.dat -f MATLAB');
else,
  [s,w]=unix('lmstat -c /opt/WLlicenses/matlab_r12/license.dat -f MATLAB | grep start');
end;
LF=find(w==10);
Start=[1 LF+1];
End=LF-1;
u={};
m={};
s=[];
nw=datevec(now);
k=0;
for i=1:length(End),
  str=w(Start(i):End(i));
  if ~isempty(findstr('start',str))
    k=k+1;
    [u{k,1},str]=strtok(str);
    [m{k,1},str]=strtok(str);
    j=findstr(str,'start')+6;
    T=sscanf(str(j:end),'%*s %d/%d %d:%d',4);
    s(k,1)=datenum(nw(1),T(1),T(2),T(3),T(4),0);
  end;
end;
