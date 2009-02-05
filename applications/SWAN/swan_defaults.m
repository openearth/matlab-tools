function DAT = swan_defaults
%SWAN_DEFAULTS   returns SWAN default SET settings
%
%  DAT.set.level    = 0;
%  DAT.set.nor      = 90;
%  DAT.set.depmin   = 0.05;
%  DAT.set.maxmes   = 200;
%  DAT.set.maxerr   = 1;
%  DAT.set.naut     = false; % means default cartesian
%  DAT.set.grav     = 9.81;
%  DAT.set.rho      = 1025;
%  DAT.set.inrhog   = 0;
%  DAT.set.hserr    = 0.10;
%
%  DAT.set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
%  DAT.set.froudmax = 0.80;
%  DAT.set.printf   = 4;
%  DAT.set.prtest   = 4;
%
%See also: SWAN_IO_INPUT, SWAN_IO_SPECTRUM, SWAN_QUANTITY, SWAN_IO_TABLE

   DAT.set.level    = 0;
   DAT.set.nor      = 90;
   DAT.set.depmin   = 0.05;
   DAT.set.maxmes   = 200;
   DAT.set.maxerr   = 1;
   DAT.set.naut     = false; % means default cartesian
   DAT.set.grav     = 9.81;
   DAT.set.rho      = 1025;
   DAT.set.inrhog   = 0;
   DAT.set.hserr    = 0.10;
  %NAUTical/CARTesian
   DAT.set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
   DAT.set.froudmax = 0.80;
   DAT.set.printf   = 4;
   DAT.set.prtest   = 5;
   
%% EOF   