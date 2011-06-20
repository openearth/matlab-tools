function disp(obj)
%DISP

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

switch length(obj.Block),
case 0,
  line2='empty DATAFIELD object';
case 1,
  line2=[lower(obj.Block.Type) ' DATAFIELD object'];
otherwise,
  line2='multiblock DATAFIELD object';
end;

if (isLoose)
  fprintf('\n');
end
fprintf('     %s\n', line2);
if (isLoose)
  fprintf('\n');
end
