function nan = plotNet_test(varargin)
%plotNet_test   test unstruc.readNet/unstruc.plotNet
%
%See also: unstruc

   OPT.axis = [];
  %OPT.axis = [100000      250000      500000      680000];
  %OPT.axis.x = [208   141    98   126   229   222].*1e3;
  %OPT.axis.y = [625   615   573   534   588   628].*1e3;
   ncfile   = 'waddenz_net.nc';
   ncfile   = 'run01_map.nc';
   tic
   G = unstruc.readNet(ncfile,'peri2cell',1);
   toc % Elapsed time is 2.321945 seconds.

   tic
   h = unstruc.plotNet(G,'axis',OPT.axis,...
                        'peri',{'k-','linewidth' ,0.5},...
                         'cen',{'b.','markersize',2.0},...
                         'cor',{'y.','markersize',20.}); % 2.371573 seconds.
   toc % Elapsed time is 0.476637 seconds.
