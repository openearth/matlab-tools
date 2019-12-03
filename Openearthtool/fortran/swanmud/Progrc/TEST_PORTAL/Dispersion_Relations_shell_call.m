clear all
close all

%% Define 1D combi vectors
%-------------------------------------

%  D.hw   = [4.5  4.5  4.5  4.5  8.0  8.0  8.0  8.0  7.0  7.0  7.0  7.0 ];
%  D.hm   = [0.2  0.3  0.2  0.3  0.3  0.45 0.3  0.45 1.0  1.0  0.5  0.5 ];
%  D.rhom = [1270 1270 1270 1270 1200 1200 1200 1200 1200 1200 1280 1280];
%  D.num  = [  10   10    5    5   10   10    5    5    5   10    5   10]./1000; 

   D.hw   = [ 4.5  4.5  4.5  4.5     7.0  7.0  7.0  7.0     8.0  8.0  8.0  8.0 ];
   D.hm   = [ 0.2  0.3  0.2  0.3     0.5  0.5  1.0  1.0     0.3  0.3  0.45 0.45];
   D.num  = [   5    5   10   10       5    5   10   10       5    5   10   10 ]; 
   D.rhom = [1270 1270 1270 1270    1200 1200 1200 1200    1200 1200 1200 1200 ];
   D.rhow = repmat(1000,size(D.hw));
   D.nuw  = repmat(1e-6,size(D.hw));

   T      = 1:.1:60;

%% Build full matrix with all combi's of parameters x waveperiods
%  
%-------------------------------------

   [D.hw  ,D.T] = meshgrid(D.hw  ,T); 
   [D.hm  ,D.T] = meshgrid(D.hm  ,T); 
   [D.rhom,D.T] = meshgrid(D.rhom,T); 
   [D.num ,D.T] = meshgrid(D.num ,T); 
   [D.rhow,D.T] = meshgrid(D.rhow,T); 
   [D.nuw ,D.T] = meshgrid(D.nuw ,T);
    D.omega      = 2*pi./D.T;

%% Get ks
%-------------------------------------

   state.pwd = pwd;
   cd('D:\HOME\source\SWAN\40.51A.gerben\SWANW\Progsrc\TEST_PORTAL\')
   D = Dispersion_Relations_shell(D,'Dispersion_Relations_shell4susana2')
   cd (state.pwd)
   
%% Save ks
%-------------------------------------

  %hdfvsave([filename(fname),'.hdf'],D); % does not save complex values !!!
   