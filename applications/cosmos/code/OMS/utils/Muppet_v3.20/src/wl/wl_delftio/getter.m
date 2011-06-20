NUM_DATA=20;
NUM_TIME=10;

resFile=fopen('getC-result.txt','w');
dsh = dionew('myFile');

for t=0:NUM_TIME-1
  if ~diostartread(dsh), break; end
  data = double(dioread(dsh,[1 NUM_DATA],'single'));
  dioendread(dsh);

  fprintf('Get has got data\n');
  if resFile>0, fprintf(resFile, 'Get has got data for t=%d\n', t); end
  fprintf('getdata: %d is %f\n', [0:NUM_DATA-1;data]);
  if resFile>0, fprintf(resFile, 'getdata: %d is %f\n', [0:NUM_DATA-1;data]); end
end
  
for t=0:NUM_TIME-1
  if ~diostartread(dsh), break; end
  data = double(dioread(dsh,[1 NUM_DATA],'int32'));
  dioendread(dsh);

  fprintf('Get has got data\n');
  if resFile>0, fprintf(resFile, 'Get has got data for t=%d\n', t); end
  fprintf('getdata: %d is %f\n', [0:NUM_DATA-1;data]);
  if resFile>0, fprintf(resFile, 'getdata: %d is %f\n', [0:NUM_DATA-1;data]); end
end
  
for t=0:NUM_TIME-1
  if ~diostartread(dsh), break; end
  data = double(dioread(dsh,[1 NUM_DATA],'uint8'));
  dioendread(dsh);

  fprintf('Get has got data\n');
  if resFile>0, fprintf(resFile, 'Get has got data for t=%d\n', t); end
  fprintf('getdata: %d is %f\n', [0:NUM_DATA-1;data]);
  if resFile>0, fprintf(resFile, 'getdata: %d is %f\n', [0:NUM_DATA-1;data]); end
end

fprintf('Get is Cleaning up\n');

diodel(dsh);

fprintf('Get: Cleaned up\n');
if resFile>0, fclose(resFile); end

