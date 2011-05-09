function Str=strstack,

[Stack,j]=dbstack;
Str={};
Stack=Stack(2:end);
for i=1:length(Stack),
  Str{i}=sprintf('%c In %s at line %i', ...
    logicalswitch(i==j,'>',' '),Stack(i).name,Stack(i).line);
end;
Str=str2mat(Str);
