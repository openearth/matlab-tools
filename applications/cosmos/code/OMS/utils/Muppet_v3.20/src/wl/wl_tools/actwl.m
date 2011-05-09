function S1=actwl(C,i);
% ACTWL returns active S1 from a trim- or com-file.
%         S1=ACTWL(NFStruct,Index);
%         By default Index is the last element of CURTIM
%         or map-series group.


switch nargin,
case 0,
  C=vs_use('lastread');
  switch vs_type(C),
  case 'Delft3D-com',
    Info=vs_disp(C,'CURTIM',[]);
    i=Info.SizeDim;
  case 'Delft3D-trim',
    Info=vs_disp(C,'map-series',[]);
    i=Info.SizeDim;
  end;
case 1,
  if isstruct(C),
    switch vs_type(C),
    case 'Delft3D-com',
      Info=vs_disp(C,'CURTIM',[]);
      i=Info.SizeDim;
    case 'Delft3D-trim',
      Info=vs_disp(C,'map-series',[]);
      i=Info.SizeDim;
    end;
  else,
    i=C;
    C=vs_use('lastread');
  end;
end;
switch vs_type(C),
case 'Delft3D-com',
  S1=vs_get(C,'CURTIM',{i},'S1','quiet');
  kfu=vs_get(C,'KENMTIM',{i},'KFU','quiet');
  kfv=vs_get(C,'KENMTIM',{i},'KFV','quiet');
case 'Delft3D-trim',
  S1=vs_get(C,'map-series',{i},'S1','quiet');
  kfu=vs_get(C,'map-series',{i},'KFU','quiet');
  kfv=vs_get(C,'map-series',{i},'KFV','quiet');
otherwise,
  error('Invalid NEFIS file for this action.');
end;
kfu=conv2([kfu(:,1)>0 kfu>0],[1 1],'valid');
kfv=conv2([kfv(1,:)>0;kfv>0],[1;1],'valid');
S1(kfu==0 & kfv==0)=NaN;
