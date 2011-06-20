function [X,Y,TX,TY]=xytransp(C,i);
% XYTRANSP returns X,Y,TX,TY from a tram- or com-file.
%         [X,Y,TX,TY]=XYTRANSP(NFStruct,Index);
%         By default Index is the last element of TRANSTIM
%         or map-series group.


switch nargin,
case 0,
  C=vs_use('lastread');
  switch vs_type(C),
  case 'Delft3D-com',
    Info=vs_disp(C,'TRANSTIM',[]);
    i=Info.SizeDim;
  case 'Delft3D-tram',
    Info=vs_disp(C,'MAPATRAN',[]);
    i=Info.SizeDim;
  end;
case 1,
  if isstruct(C),
    switch vs_type(C),
    case 'Delft3D-com',
      Info=vs_disp(C,'TRANSTIM',[]);
      i=Info.SizeDim;
    case 'Delft3D-tram',
      Info=vs_disp(C,'MAPATRAN',[]);
      i=Info.SizeDim;
    end;
  else,
    i=C;
    C=vs_use('lastread');
  end;
end;
switch vs_type(C),
case 'Delft3D-com',
  Txi=vs_get(C,'TRANSTIM',{i},'TTXA','quiet');
  Teta=vs_get(C,'TRANSTIM',{i},'TTYA','quiet');
  alfa=vs_get(C,'GRID','ALFAS','quiet');
  alfa0=vs_get(C,'GRID','ALFORI','quiet');
  alfa=alfa+alfa0;
case 'Delft3D-tram',
  Txi=vs_get(C,'MAPATRAN',{i},'TTXA','quiet');
  Teta=vs_get(C,'MAPATRAN',{i},'TTYA','quiet');
  alfa=vs_get(C,'GRID','ALFAS','quiet');
  alfa0=vs_get(C,'GRID','ALFORI','quiet');
  alfa=alfa+alfa0;
otherwise,
  error('Invalid NEFIS file for this action.');
end;
alfa=alfa*pi/180;
TX=Txi.*cos(alfa)-Teta.*sin(alfa);
TY=Txi.*sin(alfa)+Teta.*cos(alfa);
switch vs_type(C),
case 'Delft3D-com',
  kcs=vs_get(C,'KENMCNST','KCS','quiet');
  X=vs_get(C,'TEMPOUT','XWAT','quiet');
  Y=vs_get(C,'TEMPOUT','YWAT','quiet');
  X0=vs_get(C,'GRID','XORI','quiet');
  Y0=vs_get(C,'GRID','YORI','quiet');
  X=X+X0;
  Y=Y+Y0;
case 'Delft3D-tram',
  kcs=vs_get(C,'TEMPOUT','CODW','quiet');
  X=vs_get(C,'TEMPOUT','XWAT','quiet');
  Y=vs_get(C,'TEMPOUT','YWAT','quiet');
  X0=vs_get(C,'GRID','XORI','quiet');
  Y0=vs_get(C,'GRID','YORI','quiet');
  X=X+X0;
  Y=Y+Y0;
end;
% X(~kcs)=NaN; % includes open boundaries
X(kcs~=1)=NaN;
Y(kcs~=1)=NaN;
