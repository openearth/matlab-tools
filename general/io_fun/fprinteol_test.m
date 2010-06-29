function OK = fprinteol_test
%fprinteol_test test for fprinteol
%
%See also: fprinteol

fid = fopen([mfilename('fullpath'),'.txt'],'w');
fprinteol(fid,'u')
fprinteol(fid,'l')
fprinteol(fid,'d')
fprinteol(fid,'w')
fprinteol(fid,'p')
fprinteol(fid,'m')
fclose (fid);

fid = fopen([mfilename('fullpath'),'.txt'],'r');
rec = fread(fid,10,'uchar');
fclose (fid);

tst = [10 10 13 10 13 10 13 10 13]';
OK = isequal(tst,rec);
