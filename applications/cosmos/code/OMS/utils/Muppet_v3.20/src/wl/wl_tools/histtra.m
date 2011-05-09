function hout=histtra(CM,CH),
% HISTTRA plot history transects (cross-sections)
%      HISTTRA(NFSstruct)
%      NFSstruct of trih or trim file.

switch nargin,
case 0,
  C=vs_use('lastread');
case 1,
  C=CM;
end;
switch nargin,
case {0,1},
  switch vs_type(C),
  case 'Delft3D-trih',
    CH=C;
    CM=vs_use(strrep([C.FileName C.DefExt],'trih','trim'),'quiet');
    vs_use(CH);
    if isempty(CM), return; end;
  case 'Delft3D-trim',
    CM=C;
    CH=vs_use(strrep([C.FileName C.DefExt],'trim','trih'),'quiet');
    vs_use(CM);
    if isempty(CH), return; end;
  end;
case 2,
  if strcmp(vs_type(CH),'Delft3D-trim'),
    T=CH; CH=CM; CM=T;
  end;
end;
if ~strcmp(vs_type(CH),'Delft3D-trih'),
  error('Invalid NEFIS file for this action.');
end;
if ~strcmp(vs_type(CM),'Delft3D-trim'),
  error('Invalid NEFIS file for this action.');
end;

MNTRA=vs_get(CH,'his-const','MNTRA','quiet');
XTRA=[];
YTRA=[];
X=vs_get(CM,'map-const','XCOR','quiet');
Y=vs_get(CM,'map-const','YCOR','quiet');
for i=1:size(MNTRA,2),
  if MNTRA(1,i)==MNTRA(3,i), % M1==M2
    M=MNTRA(1,i);
    N=max(1,min(MNTRA([2 4],i))-1): ...
       min(size(X,1),max(MNTRA([2 4],i)));
    XTRA=[XTRA; X(N,M); NaN];
    YTRA=[YTRA; Y(N,M); NaN];
  else, % N1==N2
    M=max(1,min(MNTRA([1 3],i))-1): ...
        min(size(X,2),max(MNTRA([1 3],i)));
    N=MNTRA(2,i);
    XTRA=[XTRA; transpose(X(N,M)); NaN];
    YTRA=[YTRA; transpose(Y(N,M)); NaN];
  end;
end;
h=line(XTRA,YTRA,'linestyle','-', ...
     'linewidth',3,'color','k');
if nargout>0,
  hout=h;
end;
