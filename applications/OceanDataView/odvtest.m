%ODVTEST   script to test ODVRREAD and ODVDISP
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: ODVDISP

D = odvread('result_CTDCAST_75___41-260409.txt');

    odvdisp(D)

subplot(1,3,1)
   index.x = 12;
   index.y = 10;
   plot  (str2num(char(D.rawdata{index.x,:})),...
          str2num(char(D.rawdata{index.y,:})))
   set   (gca,'ydir','reverse')
   xlabel(D.variables{index.x})
   ylabel(D.variables{index.y})
   grid on
   title (['Cruise: ',D.data.cruise{1}])

subplot(1,3,2)
   index.x = 14;
   index.y = 10;
   plot  (str2num(char(D.rawdata{index.x,:})),...
          str2num(char(D.rawdata{index.y,:})))
   set   (gca,'ydir','reverse')
   xlabel(D.variables{index.x})
   set   (gca,'yticklabel',{})
   grid on
   title (['Station: ',mktex(D.data.station{1})])
   
subplot(1,3,3)
   index.x = 16;
   index.y = 10;
   plot  (str2num(char(D.rawdata{index.x,:})),...
          str2num(char(D.rawdata{index.y,:})))
   set   (gca,'ydir','reverse')
   xlabel(D.variables{index.x})
   set   (gca,'yticklabel',{})
   grid on
   title (['(',num2str(D.data.lat(1)),'\circE, ',num2str(D.data.lon(1)),'\circN)'])   