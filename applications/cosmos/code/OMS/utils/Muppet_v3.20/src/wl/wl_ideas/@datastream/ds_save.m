function ds_save(DataStream,fid),
% SAVE save a datastream to file

GridCell=20;

if fid<0,
  return;
end;
switch lower(DataStream.Type),
case 'group',
  Process=DataStream.Specs.Process;
  fprintf(fid,'output = %i:%i\n\n', ...
    DataStream.Specs.OutputProcess,DataStream.Specs.OutputConnector);
  for i=1:length(Process),
    fprintf(fid,'%i:%s:%s\n',i,Process(i).Stream.Type,Process(i).Name);
    fprintf(fid,'LowerLeft = %i %i\n',Process(i).PlotLocation/GridCell);
    fprintf(fid,'%i inputs\n',length(Process(i).InputFromProcess));
    for j=1:length(Process(i).InputFromProcess),
      fprintf(fid,'%i',j);
      for k=1:length(Process(i).InputFromProcess{j})
        fprintf(fid,' %i:%i', ...
          Process(i).InputFromProcess{j}(k), ...
          Process(i).InputFromConnector{j}(k));
      end;
      fprintf(fid,'\n');
    end;
    fprintf(fid,'{\n');
    save(Process(i).Stream,fid);
    fprintf(fid,'}\n');
    if i<length(Process),
      fprintf(fid,'\n');
    end;
  end;
case {'sum','multiply','inverse','transpose'},
  % none
case {'scalarmultiply','power'},
  fprintf(fid,'%i\n',DataStream.Specs.Scalar);
case {'constantmatrix'},
  fprintf(fid,'%i\n',DataStream.Specs.Scalar);
  fprintf(fid,'%s\n',gui_str(DataStream.Specs.Size));
case {'fieldrenumber'},
  fprintf(fid,' %i',gui_str(DataStream.Specs.Renumber));
  fprintf(fid,'\n');
case {'loadfield'},
  lf_save(DataStream.Specs.LoadField,fid);
end;
