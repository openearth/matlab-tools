function Sout=sortfieldnames(Sin),
%SORTFIELDNAMES sort fieldnames in alphabetical order
%     STRUCT2=SORTFIELDNAMES(STRUCT1)
%     STRUCT2 is equal to STRUCT1 expect for the fields
%     which are now put in alphabetical order.


FN=fieldnames(Sin);
[FN,I]=sort(FN);
if isequal(I,1:length(I)); % no reorder necessary
  Sout=Sin;
end;
szSin=size(Sin);
Sin=struct2cell(Sin);
if isempty(Sin),
  Sout=cell2struct(cell([length(FN) szSin]),FN,1);
else,
  Sout=cell2struct(Sin(I,:),FN,1);
end;