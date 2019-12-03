function swanmud_shoaling
%swanmud_shoaling   unit test for swanmud
%
% This function requires the OpenEarthTools Matlab toolx
% Availble @ www.OpenEarth.eu
%
%See also: swan

   RUNID = 'swanmud_shoaling';

%% load and calculate

   INP      = swan_io_input   (which([RUNID,'.swn']));
   TAB      = swan_io_table   (INP.table);
   M        = swan_io_spectrum([RUNID,'.mudf']);
   
   T     = INP.boundspec.per;
   omega = 2*pi/T;
   rhow  = INP.set.rho;
   rhom  = INP.mud.rhom;
   nuw   = 1e-6;
   num   = INP.mud.nu;
   g     = INP.set.grav;
   
%% analytical solution   
   
   for i=1:length(TAB.HS)
      omega3    = omega.*[0.95 1 1.05];
      kgade3    = gade1958(omega3,g,TAB.DEP(i),TAB.MUDL(i),rhow,rhom,nuw,num);
      cg3       = cgroup  (omega3,real(kgade3));
      TAB.cg(i) = cg3(2);
   end
   TAB.kgade = gade1958(omega,g,TAB.DEP,TAB.MUDL,rhow,rhom,nuw,num)
   TAB.Ksgade = sqrt(TAB.cg(1)./TAB.cg);

%% plot

   AX = subplot_meshgrid(1,4,[.1],[.08 0.04 0.04 0.04 .13]);
   
   subplot(4,1,1)
   fill   ([TAB.XP' flipud(TAB.XP)'],[ -TAB.DEP'.*0           -TAB.DEP'            ],[0  0  1]);
   hold    on
   fill   ([TAB.XP' flipud(TAB.XP)'],[ -TAB.DEP'             (-TAB.DEP - TAB.MUDL)'],[1 .6 .4]);
   fill   ([TAB.XP' flipud(TAB.XP)'],[(-TAB.DEP - TAB.MUDL)'  -TAB.DEP'.*2'        ],[1  1  0]);
   text( 10,-0.5,['water:'    ,' \rho_{w} = '  ,num2str(rhow),' kg/m3 \nu_{w} = '  ,num2str(nuw),' m2/s ']);
   text(200,-1.3,['fluid mud:',' \rho_{mud} = ',num2str(rhom),' kg/m3 \nu_{mud} = ',num2str(num),' m2/s ']);
   text( 10,-1.8,'solid bed')
   set    (gca,'xticklabel',{})
   ylim   ([-2 0])
   ylabel ('z [m]')
   xlabel ([' T = ',num2str(T),' s ,     kH_{w0} = ',num2str(real(TAB.kgade(1)).*TAB.DEP(1))]);
   title  ('swanmud shoaling')
   
   subplot(4,1,2)
   plot   (TAB.XP,TAB.KI,'linewidth',3)
   hold    on
   [tmin,ind] = min(abs(M.frequency - 1./T));
   plot   (TAB.XP,M.KIMAG(:,ind),'-')
   plot   (TAB.XP,imag(TAB.kgade),'g.')
   ylim   ([0 0.015])
   ylabel ('Im(k) [rad/m]')
   set    (gca,'xticklabel',{})
   
   subplot(4,1,3)
   plot   (TAB.XP,2.*pi./TAB.WLENMR,'linewidth',3)
   hold    on
   plot   (TAB.XP,real(TAB.kgade),'g.')
   ylim   ([0.13 0.18])
   ylabel ('Re(k) [rad/m]')
   set    (gca,'xticklabel',{})
   
   subplot(4,1,4)
   plot   (TAB.XP,TAB.HS,'linewidth',3,'displayname','SWANmud')
   hold    on
   plot   (TAB.XP,TAB.HS(1).*TAB.Ksgade,'g.','displayname','analytical')
   ylim   ([.08 .11])
   ylabel ('H_s [m]')
   tickmap('x','scale',1,'units',' m')
   legend ('Location','southeast')
   
   print2screensize(RUNID)