function disp(obj)
%DISP

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

line2=['DATASTREAM ' lower(obj.Type) 'object'];

if (isLoose)
  fprintf('\n');
end
fprintf('     %s\n', line2);
if (isLoose)
  fprintf('\n');
end
