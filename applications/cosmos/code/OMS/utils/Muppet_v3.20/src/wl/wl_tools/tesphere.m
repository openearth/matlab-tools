function [X,Y,Z,tri]=tesphere(N)
% TESPHERE Generate tesselated sphere.
%    [X,Y,Z,TRI] = TESPHERE(N) generates three coordinates
%    and triangulation of a unit sphere and using 2N-1 rows
%    of points. Number of marker points. N= 5 ->    66 points
%                                          50 ->  9606 points
%                                          60 -> 13926 points
%                                          70 -> 19046 points
%    [X,Y,Z,TRI] = TESPHERE uses N = 5.
%    The sphere can be plotted using TRISURF(TRI,X,Y,Z).
%
%    See also: SPHERE, TRISURF

% Tesselation by Aaron Stallard, triangulation by Bert Jagers
% Created 17/3/2001
    
if nargin==0,
  %Number of marker points. N= 5 ->    66 points
  %                           50 ->  9606 points
  %                           60 -> 13926 points
  %                           70 -> 19046 points
  N=5;
end


%
%This section defines the position of the initial marker points
%--------------------------------------------------
if N<2, error('Can''t perform tesselation!'); end
%
% preallocate arrays to optimize speed
%
Npnt=4*(N-1)^2+2;
Ntri=8*(N-1)*(N-2)+8*(N-2)+8;
th = zeros(Npnt,1);
ph = zeros(Npnt,1);
tri=zeros(Ntri,3);
%
% create northern hemisphere
%
i1=0;
i2=1;
theta = linspace(0,pi/2,N);
for t = 2:N
  nSlice = 4*(t-1);
  %
  % compute th,ph coordinates of new row of points
  %
  thSlice = theta(ones(1,nSlice),t);
  phSlice = linspace(0,2*pi,nSlice+1);
  %
  % keep track of points in th and ph arrays:
  % i0: offset for previous row of points
  % i1: offset for current row of points
  % i2: offset for next row of points (= end of current row of points)
  %
  i0=i1;
  i1=i2;
  i2=i2+nSlice;
  %
  % store th,ph coordinates
  %
  th(i1+1:i2) = thSlice;
  ph(i1+1:i2) = phSlice(1:end-1);
  %
  % store triangles neeeded for connecting these points to previous row
  %
  if t==2,
    tri(1:4,:) = [1 2 3; 1 3 4; 1 4 5; 1 5 2];
    t1=4;
  else
    for k=0:3
      l=(1:t-2)';
      tri(t1+(1:2*(t-2)+1),:) = [i0+(t-2)*k+l   i1+(t-1)*k+l   i1+(t-1)*k+l+1
                                 i0+(t-2)*k+l   i1+(t-1)*k+l+1 i0+(t-2)*k+l+1
                                 i0+(t-2)*k+t-1 i1+(t-1)*k+t-1 i1+(t-1)*k+t  ];
      t1=t1+2*(t-2)+1;
    end
    tri(t1-1,3)=i0+1;
    tri(t1,:)=[i0+1 i1+1 i1+(t-1)*4];
  end
end
%
% create southern hemisphere
%
theta = linspace(pi/2,pi,N);
for t = N-1:-1:2
  nSlice = 4*(t-1);
  %
  % compute th,ph coordinates of new row of points
  %
  thSlice = theta(ones(1,nSlice),N-t+1);
  phSlice = linspace(0,2*pi,nSlice+1);
  %
  % keep track of points in th and ph arrays:
  % i0: offset for previous row of points
  % i1: offset for current row of points
  % i2: offset for next row of points (= end of current row of points)
  %
  i0=i1;
  i1=i2;
  i2=i2+nSlice;
  %
  % store th,ph coordinates
  %
  th(i1+1:i2) = thSlice;
  ph(i1+1:i2) = phSlice(1:end-1);
  %
  % store triangles neeeded for connecting these points to previous row
  %
  for k=0:3
    l=(1:t-1)';
    tri(t1+(1:2*(t-1)+1),:) = [i0+t*k+l   i1+(t-1)*k+l i0+t*k+l+1
                               i0+t*k+l+1 i1+(t-1)*k+l i1+(t-1)*k+l+1
                               i0+t*k+t   i1+(t-1)*k+t i0+t*k+t+1    ];
    t1=t1+2*(t-1)+1;
  end
  tri(t1-1,3)=i1+1;
  tri(t1,:)=[i0+t*4 i1+1 i0+1];
end

%
% store th,ph coordinates of last point
%
th(end) = pi;
ph(end) = 0;
%
% store triangles neeeded for connecting this point to last row
%
i0=i1;
i2=i2+1;
tri(t1+(1:4),:)=[i0+1 i0+4 i2;i0+2 i0+1 i2; i0+3 i0+2 i2;i0+4 i0+3 i2];

X = sin(th).*cos(ph);
Y = sin(th).*sin(ph);
Z = cos(th);
