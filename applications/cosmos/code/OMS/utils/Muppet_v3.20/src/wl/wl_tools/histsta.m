function hout=histsta(C),
% HISTSTA plot history stations
%     HISTSTA(NFSstruct)
%     NFSstruct of trih file.

if nargin==0,
  C=vs_use('lastread');
end;

switch vs_type(C),
case 'Delft3D-trih',
  XYSTAT=vs_get(C,'his-const','XYSTAT','quiet');
  h=line(XYSTAT(1,:),XYSTAT(2,:),'linestyle','none','marker','o', ...
     'markeredgecolor','k','markerfacecolor','w');
otherwise,
  error('Invalid NEFIS file for this action.');
end;

if nargout>0,
  hout=h;
end;
