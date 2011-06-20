function col=gelm_col(colInd);

switch lower(colInd),
case 'text',
  col=[195 195 195]/255;
case 'background',
  col=[195 195 195]/255;
case 'edit',
%  col=[195 195 195]/255;
  col=[1 1 1];
otherwise,
  col=[];
end;