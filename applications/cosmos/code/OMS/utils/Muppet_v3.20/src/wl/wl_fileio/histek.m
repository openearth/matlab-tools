function histek(varargin);
% converts history BIN file into history HIS file
%
% Usage: histek or histek('BIN filename')

F=fls('readbin',varargin{:});
if (~isfield(F,'Check')) | (~isequal(F.Check,'OK')),
  fprintf(1,'Error reading BIN file.\n');
  return;
end;
HisFile=[F.FileName(1:(end-4)) '.his'];
fid=fopen(HisFile,'w');
if fid<0,
  fprintf(1,'Error opening HIS file.\n');
  return;
end;

t=fls('bin',F,'T');
for i=1:F.NumSta,
  S=fls('bin',F,'S',i);
  H=fls('bin',F,'H',i);
  U=fls('bin',F,'U',i);
  V=fls('bin',F,'V',i);
  C=sqrt(U.^2+V.^2);
  fprintf(fid,'* STATION NR, M, N     : %4i %3i %3i\n',i,F.M(i),F.N(i));
  fprintf(fid,'* STATION BOTTOM HEIGHT: %8.2f\n',F.DP(i));
  fprintf(fid,'*   MAX, MIN, AVE, VAR : WATERDEPTH    (H): %7.2f %7.2f %7.2f %7.2f\n',max(H),min(H),mean(H),std(H));
  fprintf(fid,'*   MAX, MIN, AVE, VAR : FLOW VELOCITY (C): %7.2f %7.2f %7.2f %7.2f\n',max(C),min(C),mean(C),std(C));
  fprintf(fid,'*   MAX, MIN, AVE, VAR : WATERLEVEL    (Z): %7.2f %7.2f %7.2f %7.2f\n',max(S),min(S),mean(S),std(S));
  fprintf(fid,'*   MAX, MIN, AVE, VAR : U-VELOCITY    (U): %7.2f %7.2f %7.2f %7.2f\n',max(U),min(U),mean(U),std(U));
  fprintf(fid,'*   MAX, MIN, AVE, VAR : V-VELOCITY    (V): %7.2f %7.2f %7.2f %7.2f\n',max(V),min(V),mean(V),std(V));
  fprintf(fid,'*   TIME       H       C       Z       U       V\n');
  fprintf(fid,'S%3i\n',i);
  fprintf(fid,' %12i  6\n',F.NumTimes);
  fprintf(fid,'%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f\n',transpose([t,H,C,S,U,V]));
%  for k=1:F.NumTimes,
%    fprintf(fid,'%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f\n',t(k),H(k),C(k),S(k),U(k),V(k));
%  end;
end;
fclose(fid);
fprintf(1,[HisFile,' succesfully created.\n']);
