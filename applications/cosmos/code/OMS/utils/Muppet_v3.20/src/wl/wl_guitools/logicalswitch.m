function Choice=logicalswitch(Logic,Opt1,Opt2),
% LOGICALSWITCH switches between two values depending on logical input
%    LOGICALSWITCH(boolean,opt1,opt2) returns opt1 if boolean is true (~=0)
%    and returns opt2 if boolean is false (==0)

if Logic,
  Choice=Opt1;
else,
  Choice=Opt2;
end;