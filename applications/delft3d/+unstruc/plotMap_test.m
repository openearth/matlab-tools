function nan = plotMap_test(varargin)
%plotMap_test   test unstruc.readMap/unstruc.plotMap
%
%See also: unstruc

   OPT.axis = [];
  %OPT.axis = [100000      250000      500000      680000];
  %OPT.axis.x = [208   141    98   126   229   222].*1e3;
  %OPT.axis.y = [625   615   573   534   588   628].*1e3;

   ncfile   = 'run01_map.nc';
   tic
  % ----------------------------
  %h = unstruc.plotMap(ncfile,'axis',OPT.axis,...
  %                       'patch',{'EdgeColor','k'});
  % ----------------------------
  %h = unstruc.plotMap(ncfile,25,'axis',OPT.axis,...
  %                      'patch',{'EdgeColor','k'});
  % ----------------------------
   tic
   G = unstruc.readNet(ncfile,'peri2cell',1);
   toc % Elapsed time is 2.502784 seconds.
   tic
   D = unstruc.readMap(ncfile,25);
   toc % Elapsed time is 0.813906 seconds.
   tic
   h = unstruc.plotMap(G,D,'axis',OPT.axis,...
                          'patch',{'EdgeColor','none'},...
                      'parameter','zwl');
                      
   toc % Elapsed time is 6.687427 seconds.
  % ----------------------------
  %G = unstruc.readNet(ncfile,'peri2cell',0);
  %h = unstruc.plotMap(G,25,'axis',OPT.axis,...
  %                       'patch',{'EdgeColor','k'}); % should crash
  % ----------------------------
