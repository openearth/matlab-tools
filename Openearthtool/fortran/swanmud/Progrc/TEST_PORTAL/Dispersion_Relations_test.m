OPT.load   = 1;
OPT.export = 1;

%% Define 1D combi vectors
%  test just guo now
%-------------------------------------

    D.hw   = [1:1:30];
    T      = [1:1:30];
    
%% Build full matrix with all combi's
%-------------------------------------
   [D.hw,D.T] = ndgrid(D.hw,T);
    
   D.hm    = repmat(0.01,size(D.hw));
   D.num   = repmat(   0,size(D.hw));

   D.rhom  = repmat(1000,size(D.hw));
   D.rhow  = repmat(1000,size(D.hw));
   D.nuw   = repmat(1e-6,size(D.hw));

   nc      = length(D.hm);
   nt      = length(T   );
   ki      = repmat(nan,[nt nc]);

   D.omega = 2*pi./D.T;

%% Get k
%-------------------------------------

   if OPT.load
     state.pwd = pwd;
     cd('F:\checkouts\swanmud\source\40.51A.gerben\SWANW\Progsrc\TEST_PORTAL\')
     D = Dispersion_Relations_shell(D,'basename','Dispersion_Relations_test')
     cd (state.pwd)
   end

%% Plot
%-------------------------------------

AX = subplot_meshgrid(1,3,[.06],[.06],[nan],[nan]);

axes(AX(1))
pcolorcorcen(2*pi./D.Omega,D.hw,D.kguo)
colorbarwithtitle('kguo.f')
tickmap('x','scale',1,'units',' s')
tickmap('y','scale',1,'units',' m')
xlabel('T')
ylabel('h_w')

axes(AX(2))
L = wavedispersion(D.T,D.hw);
pcolorcorcen(2*pi./D.Omega,D.hw,2*pi./L./D.kguo)
colorbarwithtitle('wavedispersion.m/kguo.f')
tickmap('x','scale',1,'units',' s')
tickmap('y','scale',1,'units',' m')
xlabel('T')
ylabel('h_w')

axes(AX(3))
L = wavelength(2*pi./D.Omega,D.hw);
pcolorcorcen(2*pi./D.Omega,D.hw,2*pi./L./D.kguo)
colorbarwithtitle('wavelength.m/kguo.f')
tickmap('x','scale',1,'units',' s')
tickmap('y','scale',1,'units',' m')
xlabel('T')
ylabel('h_w')


if OPT.export
print2screensize('Dispersion_Relations_test')
end