function vPos=gelm_vpos(vInd,nLns);

if nargin==1,
  nLns=1;
end;
vPos=[0 10+(15-vInd)*21 0 21*(nLns-1)+21];
