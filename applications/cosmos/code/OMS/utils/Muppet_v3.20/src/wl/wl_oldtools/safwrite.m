function safwrite(file,Data,Type);
% SAFREAD writes data to a data file related to the SAF model
%
%     safwrite(FileName,Data,Type)
%

if nargin<2,
  error('Not enough input arguments.');
end;
fid=fopen(file,'wt');
if fid<=0,
  error('Couldn''t create file.');
end;
if nargin<3,
  Type='ELEVATION';
end;
fprintf(fid,'%s\n',Type);
fprintf(fid,'%i %i\n',size(Data));
fprintf(fid,'%f\n',transpose(Data)); % data saved in row order
fclose(fid);

