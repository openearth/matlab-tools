function ctd_overview_plot(S,M,E,L)

            subplot(3,2,1)
            plot(S.datenum,S.profile_id)
            hold on
            plot(S.datenum,S.block,'r--')
            datetick('x')
            ylabel({'profile\_id ','== dia block id (red)??'})
            grid on
            subplot(3,2,3)        
            plot(S.datenum,[0;diff(S.datenum)])
            datetick('x')
            ylabel('interval [days]')
            grid on
            subplot(3,2,5)        
            plot(S.datenum,S.station_id)
            datetick('x')
            ylabel('station\_id')
            grid on    
            
            subplot(3,2,[2 4 6])
            scatter(S.station_lon,S.station_lat,50,log10(S.station_n),'filled')
            hold on
            text(S.station_lon,S.station_lat,num2str([1:length(S.station_lat)]',' %d'))
            plot(L.lon,L.lat,'-' ,'color',[0 0 0])
            plot(E.lon,E.lat,'--','color',[0 0 0])        
            grid on
            axis([-2 9 50 57])    
            axislat
            tickmap('ll')
            clim(log10([1 1e5]))
            colormap(clrmap(jet,5*2))
            [h,~]=colorbarwithhtext('number of profiles',log10([1 10 100 1000 1e4 1e5]),'horiz')
            set(h,'xticklabel',{'1','10','100','1000','1e4','1e5'});
