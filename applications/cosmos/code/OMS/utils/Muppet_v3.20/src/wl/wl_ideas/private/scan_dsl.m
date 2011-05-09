function Info=scan_dsl(FileName),

Info.Label={};
Info.Cmds={};
fid=fopen(FileName,'r');
while ~feof(fid),
  L=fgetl(fid);  
  if ~isempty(L),
    if length(L)<=3,
      Info.Cmds{end}{end+1}=L;
    elseif strcmp(L(1:3),'%%%'),
      Info.Label{end+1}=L(4:end);
      Info.Cmds{end+1}={};
    else,
      Info.Cmds{end}{end+1}=L;
    end;
  end;
end;
fclose(fid);