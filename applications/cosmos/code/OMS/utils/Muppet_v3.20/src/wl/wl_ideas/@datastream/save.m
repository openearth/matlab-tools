function save(DataStream,fid),
% SAVE save a datastream to file

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
    fprintf(fid,'LowerLeft = %i %i\n',Process(i).PlotLocation);
    fprintf(fid,'%i inputs\n',length(Process(i).InputFromProcess));
    for j=1:length(Process(i).InputFromProcess),
      fprintf(fid,'%i:%i\n', ...
         Process(i).InputFromProcess(j), ...
         Process(i).InputFromConnector(j));
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
case {'scalar','scalarMultiply'},
  fprintf(fid,'%i\n',DataStream.Specs.Scalar);
case {'fieldrenumber'},
  fprintf(fid,' %i',gui_str(DataStream.Specs.Renumber));
  fprintf(fid,'\n');
case {'loadfield'},
  lf_save(DataStream.Specs.LoadField,fid);
end;
