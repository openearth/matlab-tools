NUM_DATA=20;
NUM_TIME=10;
sof=4;

dsh=dionew('myFile',NUM_DATA*sof);
data=((1:NUM_DATA)-1)*2;
fprintf('setdata: %d to %f\n', [1:NUM_DATA;data]);

for t=0:NUM_TIME-1
  data=data+1;
  if ~diostartwrite(dsh), break; end
  diowrite(dsh,single(data));
  dioendwrite(dsh);
  fprintf('Put has written data for time step %d\n', t);
end

for t=0:NUM_TIME-1
  data=data+1;
  if ~diostartwrite(dsh), break; end
  diowrite(dsh,int32(data));
  dioendwrite(dsh);
  fprintf('Put has written data for time step %d\n', t);
end

for t=0:NUM_TIME-1
  data=data+1;
  if ~diostartwrite(dsh), break; end
  diowrite(dsh,uint8(data));
  dioendwrite(dsh);
  fprintf('Put has written data for time step %d\n', t);
end

fprintf('Put is Cleaning up\n');
diodel(dsh);
fprintf('Put: Cleaned up\n');
