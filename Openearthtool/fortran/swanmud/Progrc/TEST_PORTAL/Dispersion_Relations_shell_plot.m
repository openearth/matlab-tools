OPT.fname = 'Dispersion_Relations_shell4susana.out';
OPT.fname = 'Dispersion_Relations_shell4susana2.out';

D = Dispersion_Relations_shell_read(OPT.fname);

OPT.export = 1;
OPT.pause  = 0;

OPT.fldnames  = {'kguo','kgade','ksv','kdewit','kdelft','kdalr','kng'};
OPT.txtnames  = {'Guo (2002)',...
                 'Gade (1958)',...
                 'Start Value of iterations',...
                 'de Wit (1995).',...
                 'Delft (2008)',...%'Kranenburg, Winterwerp, de Boer, Cornelisse (2008)',...
                 'Dalrymple & Liu (1978)',...
                 'Ng (2000)'};
OPT.color     = colormapgray(0.9,0,length(OPT.fldnames));
OPT.linewidth = linspace(4,0.5,length(OPT.fldnames));
OPT.linestyle = {'-','--',':','--','-','--','-'};;

for ic=1:size(D.T,2)

   disp(num2str(ic,'%0.3d'))

   T    = D.T(:,1);
   
   x    = 1./T;
   xtxt = 'f [Hz]';
   xlab = 'wave_numbers_f_';

   x    = sqrt(pi./D.num(ic)./T).*D.hm(ic);
   xtxt = '\surd(\pi/(\nu T))\times h_m [-]';
   xlab = 'wave_numbers_b_';

   x    = T;
   xtxt = 'T [s]';
   xlab = 'wave_numbers_T_';

   clf;AX = subplot_meshgrid(2,2,[.06],[.06],[.66 nan],[nan]);

   for ifld=1:length(OPT.fldnames)
      fldname = OPT.fldnames{ifld};
      txtname = OPT.txtnames{ifld};

      axes(AX(1))
      plot(x,real(D.(fldname)(:,ic))./D.kguo(:,ic),...
                                     'color',OPT.color    (ifld,:),...
                                 'linewidth',OPT.linewidth(ifld),...
                                 'linestyle',OPT.linestyle{ifld},...
                               'DisplayName',[txtname]);
      if ifld==2;ylim(ylim);end                                     
      hold on
      
      axes(AX(3))
      plot(x,imag(D.(fldname)(:,ic))./D.kguo(:,ic),...
                                     'color',OPT.color    (ifld,:),...
                                 'linewidth',OPT.linewidth(ifld),...
                                 'linestyle',OPT.linestyle{ifld},...
                               'DisplayName',[txtname])
      if ifld==2;ylim(ylim);end                                     
      hold on
   end
   
   axes(AX(1))
   grid on
  %xlabel(xtxt)
   ylabel('Re(k)/k_{no mud}')
   legend('Location',get(AX(2),'position'));
   noaxis(AX(2))
   
   title([    ' h_w = ',num2str(unique(D.hw  (:,ic))),' [m]  ',...
             '  h_m = ',num2str(unique(D.hm  (:,ic))),' [m]  ',...
          '  \rho_m = ',num2str(unique(D.rhom(:,ic))),' [kgm^{-3}]  ',...
           '  \nu_m = ',num2str(unique(D.num (:,ic))),' [m^{2}s^{-1}]  ']);
   
   axes(AX(3))
   grid on  
   xlabel(xtxt)
   ylabel('Im(k)/k_{no mud}')
   text(1,0,'© TUDelft, GJdB, 2008','rotation',90,'fontsize',7,'units','normalized','verticalalignment','top')
   legend('Location',get(AX(4),'position'));
   noaxis(AX(4))
   
   if OPT.export
      print2a4([filename(OPT.fname),'_',xlab,num2str(ic,'%0.3d')],'v','t');
   end

   if OPT.pause
      pausedisp
   end
   
end % ic1
