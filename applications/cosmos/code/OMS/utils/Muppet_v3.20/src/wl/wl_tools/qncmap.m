function map = qncamp(m)
%QNCMAP    QuickIn color map.
%   QNCMAP(M) returns an M-by-3 matrix containing the QuickIn colormap.
%   QNCMAP, by itself, is the same length as the current colormap.

if nargin < 1, m = size(get(gcf,'colormap'),1); end
h = (0:m-1)'/max(m-1,1);
if isempty(h)
  map = [];
else
  j=[.75 .75 0   1   1   0  ;
     .5  .5  0   .75 .75 0  ;
     0   .75 0   0   1   0  ;
     0   .5  0   0   .75 0  ;
     0   .75 .75 0   1   1  ;
     0   .5  .5  0   .75 .75;
     0   0   .75 0   0   1  ;
     0   0   .5  0   0   .75;
     .75 0   .75 1   0   1  ;
     .5  0   .5  .75 0   .75;
     .75 .75 .75 1   1   1  ];
  i=min(11,floor(h*11)+1);
  f=h*11-i+1;
  map=j(i,1:3)+repmat(f,1,3).*(j(i,4:6)-j(i,1:3));
  map(1,:)=[.75 0 0];
  map(end,:)=[.75 .75 .75];
end
