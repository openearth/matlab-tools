function trajectory_overview_plot(S,M,E,L,titletxt)

            scatter(S.lon,S.lat,40,S.data,'.')
            hold on
            plot(L.lon,L.lat,'-' ,'color',[0 0 0])
            plot(E.lon,E.lat,'--','color',[0 0 0])
            colorbarwithvtext([M.data.long_name,'[',M.data.units,']'])
            grid on
            axis([-2 9 50 57])    
            axislat
            title(titletxt)