function [result,machines,times] = bench(count)
%BENCH  MATLAB Benchmark
%   BENCH times five different MATLAB tasks and compares the execution
%   speed with the speed of several other computers.  The five tasks are:
%   
%    ODE       Ordinary diff. eqn.      Data structures and general math.
%    LU        MATLAB's "LINPACK".      Primarily floating point.
%    Sparse    Solve sparse system.     Mixed integer and floating point.
%    3-D       Surf plot of "peaks".    3-D polygonal fill graphics.
%    2-D       plot(fft(eye)).          2-D line drawing graphics.
%
%   A final bar chart shows speed, which is inversely proportional to 
%   time.  Here, longer bars are faster machines, shorter bars are slower.
%
%   BENCH runs each of the five tasks 10 times.
%   BENCH(N) runs each of the five tasks N times.
%   BENCH(0) just plots the comparison times for the other computers.
%   T = BENCH(N) returns a vector with the five execution times.
%   [T,M,R] = BENCH(N) also returns the other machines and their results.
%
%   The problem sizes were originally chosen in 1992 so that each task
%   would require about one second with MATLAB 4.0 on a Sun SPARC-2.
%   In 1992, BENCH(N) nominally produced [N N N N N], so the default
%   BENCH(10) produced [10 10 10 10 10] and required a total of 50 seconds.
%   By 1999, many machines have CPUs that are ten times faster, so a default
%   BENCH might produce a vector with the first three elements less than one.
%   Graphics systems that are ten times faster then they were in 1992 are
%   less common, so the last two elements are usually greater than one.
%   A typical total time for the default BENCH is now five or six seconds.
%
%   The comparison times were measured with MATLAB 5.3 in January, 1999.
%   The ODE task has replaced the Loops task of earlier versions.  It still
%   measures loops and storage allocation, but also uses V5 data structures
%   and predicts Simulink performance.  The 3-D surf plot uses Z-buffer,
%   so the MATLAB 4.0 and MATLAB 5.0 times are not directly comparable.
%   The other three tasks use the same algorithms as MATLAB 4.0.  Estimated
%   SPARC-2 times are retained for historical calibration.
%
%   CAVEAT: Fluctuations of five or 10 percent in the measured times
%   of repeated runs on a single machine are not uncommon.
%   Your own mileage may vary.

%   C. Moler, 1-5-92, ..., 8-11-94, 11-14-96, 12-18-97, 1-12-99.
%   Copyright (c) 1984-1999 The MathWorks, Inc. All Rights Reserved.
%   $Revision$  $Date$

compare = { ...
   'DEC Alpha, 600'              [0.705  0.305  0.431  0.942  0.732]'
   'HP 780, 180'                 [1.687  0.459  1.133  2.828  2.236]'
   'IBM RS6000, 167'             [1.415  0.499  0.768  3.392  2.976]'
   'SGI O2, 180'                 [2.523  1.725  1.604  3.992  2.616]'
   'SGI Octane, 195'             [1.100  0.428  0.602  1.627  1.187]'
   'Pentium II, NT, 400'         [0.758  0.463  0.439  1.614  1.192]'
   'Pentium II, Linux, 400'      [0.647  0.425  0.519  1.724  1.191]'
   'Pentium II, Win98, 350'      [0.837  0.510  0.500  1.337  1.847]'
   'Pentium II Laptop, NT, 266'  [1.023  0.665  0.644  1.777  2.503]'
   'Pentium Pro, Linux, 200'     [1.207  0.828  1.054  2.454  1.569]'
   'Sparc Ultra 2, 300'          [0.823  0.596  0.664  1.733  1.307]'
   'Sparc 10, Dual 160'          [2.116  1.071  1.294  4.502  3.079]'
   'Sparc 2 (circa 1992)'        [10.00  10.00  10.00  10.00  10.00]' };

machines = char([compare(:,1)]);
times    = [compare{:,2}]';

if nargin < 1, count = 10; end;
%close all force;
t = repmat(NaN,1,5);
if any(count > 0),
  if isequal(size(count),[1 1]),
    count=count*ones(1,5);
  end;
   % help bench
%   fig1 = figure;
%   set(fig1,'pos','default')
%   axes('pos',[0 0 1 1])
%   axis off
%   text(.5,.5,'MATLAB Benchmark','horizontal','center','fontsize',16)
%   drawnow
%   pause(1);
   
% The problem size for each task has been estimated
% so that the task would take about one second on a SPARC-2.
   
% ODE
   
%   text(.5,.5,'MATLAB Benchmark','horizontal','center','fontsize',16)
%   text(.50,.42,'ODE','horizontal','center','fontsize',16)
%   drawnow
   
   F = 'vdpode';  % van der Pol equation
   tspan = [0 1];
   y0 = [2; 0];
   opts = odeset('reltol',1.e-3,'abstol',1.e-6,'initialstep',0.025);
   % Run once before timing.
   [tee,y] = ode45(F,tspan,y0,opts);
   % Now time it.
   tic
   for k = 1:count(1),
      [tee,y] = ode45(F,tspan,y0,opts);
   end
   t(1) = toc;
   
% LU
   
%   cla
%   text(.5,.5,'MATLAB Benchmark','horizontal','center','fontsize',16)
%   text(.50,.42,'LU','horizontal','center','fontsize',16)
%   drawnow
   
   n = 167;
   A = randn(n,n);
   tic
   for k = 1:count(2),
      lu(A);
   end
   t(2) = toc;
   
% Sparse
   
%   cla
%   text(.5,.5,'MATLAB Benchmark','horizontal','center','fontsize',16)
%   text(.50,.42,'Sparse','horizontal','center','fontsize',16)
%   drawnow
   
   n = 36;
   A = delsq(numgrid('L',n));
   b = sum(A)';
   spparms('autommd',0);
   tic
   for k = 1:count(3),
      x = A\b;
   end
   t(3) = toc;
   
% 3-D
   
   clf reset
   set(gcf,'renderer','zbuffer')
   n = 24;
   [x,y,z] = peaks(n);
   ax = [-3 3 -3 3 -8 8];
   tic
   for k = 1:count(4),
      surf(x,y,z);
      axis(ax);
      view(-44+2*k,30)
      drawnow;
   end
   t(4) = toc;
   
% 2-D
   
   clf
   set(gcf,'renderer','painters')
   n = 52;
   tic
   for k = 1:count(5),
      plot(fft(eye(n)));
      axis('square')
      drawnow;
   end
   t(5) = toc;

   machines = str2mat(machines,'This computer');
   times = [times; 10*t./(count+(count==0))];

end
   
% Compare with other machines.

totals = sum(times(:,count>0)')';
speeds = 50./totals;
[speeds,k] = sort(speeds);
machines = machines(k,:);
times = times(k,:);
m = size(machines,1);

% Horizontal bar chart
% Highlight this machine with another color.
clf
if any(count > 0),
   this = find(k==length(k));
else
   this = 0;
end

axes('position',[.3 .1 .6 .8])
sp = speeds;
if any(count > 0), sp(this) = 0; end
barh(sp,'y')
if any(count > 0),
   hold on
   barh(this,speeds(this),'m')
   hold off
end
set(gca,'xlim',[0 max(speeds)+.1],'xtick',0:max(speeds))
title('Relative Speed')
axis([0 max(speeds)+.1 0 m+1])

% Add machine names
set(gca,'ytick',1:length(speeds),'yticklabel',machines)

% Display report in new figure

fig2 = figure('pos',get(gcf,'pos')+[50 -150 0 0]);
axes('pos',[0 0 1 1])
axis off
x0 = .08;
y0 = .95;
dx = .10;
dy = (y0-.25)/(m-1.25);
text(x0,y0,'Computer, Megahertz')
text(x0+4.25*dx,y0,'Execution time')
s = sprintf('  ODE   LU  Sparse  3-D   2-D');
text(x0+4*dx,y0-5/4*dy,s,'horizontal','left','fontname','courier');
drawnow
for j = m:-1:1
   y = y0-(m-j+9/4)*dy;
   x = x0;
   h = text(x,y,machines(j,:),'horizontal','left');
   if j == this, set(h,'color','b'), end
   x = x + 4*dx;
   s = sprintf('%6.2f',times(j,:));
   h = text(x,y,s,'horizontal','left','fontname','courier');
   if j == this, set(h,'color','b'), end
end
drawnow

% Output if requested.
if nargout >= 1
   result = t;
   machines = flipud(machines);
   times = flipud(times);
end
