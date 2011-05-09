function Data=safread(file);
% SAFREAD read data from a data file related to the SAF model

fid=fopen(file,'rt');
if fid<=0,
  Data=[];
  return;
end;
Txt=fgetl(fid);
Sz=fscanf(fid,'%i %i',[1 2]);
Data=transpose(fscanf(fid,'%f',fliplr(Sz))); % data saved in row order
fclose(fid);

