function ctd_timeSeriesProfile_plot(P,E,L,titletxt)
%CTD_TIMESERIESPROFILE_PLOT plot timeseries of profiles at 1 location
%
%  P = ctd_timeSeriesProfile_plot(P,titletext)
%
% where P = ctd_timeSeriesProfile(..)
%
%See also: ctd_struct, ctd_timeSeriesProfile

    setfig2screensize
    
    nt = length(P.profile_id);
    nz = max(P.profile_n);

    [tt,zz] = meshgrid(1:nt,1:nz);

    subplot(2,2,1)
    plot(P.profile_lon,P.profile_lat,'ko-','markerfacecolor','r')
    hold on
    plot(L.lon,L.lat,'-' ,'color',[0 0 0])
    plot(E.lon,E.lat,'--','color',[0 0 0])        
    grid on
    axis([-2 9 50 57])    
    axislat
    tickmap('ll')
    title(titletxt)

    subplot(2,2,2)
    if nt > 1
    pcolorcorcen(tt,zz,P.z);
    hold on
    else
    scatter     (tt(:),zz(:),10,P.z(:),'filled');
    hold on
    end
    set(gca,'Color',[.8 .8 .8])
    plot(tt,zz,'k.','markersize',4); 
    set(gca,'YDir','reverse')
    xlabel('netCDF index of profile [#]')
    ylabel('netCDF ragged array index [#]')
    [ax,~]=colorbarwithvtext('z [cm]');
    title('<netCDF matrix space>')
    set(ax,'YDir','reverse')
    grid on
    ttick = get(gca,'xtick')

    subplot(2,2,3)
    colors = clrmap(jet,nt);
    for it=1:nt
    plot(zz(:,it),P.z(:,it),'.-','markersize',5,'color',colors(it,:));   
    hold on
    end
    set(gca,'YDir','reverse')
    ylabel('value of z [cm]')
    xlabel('netCDF ragged array index [#]')
    grid on
    clim([1 max(2,nt)])
    [ax,~]=colorbarwithvtext('netCDF index of profile [#]',ttick);    

    subplot(2,2,4)
    if nt > 1
    pcolorcorcen(P.datenum,P.z,P.z);
    hold on
    else
    scatter     (P.datenum(:),P.z(:),10,P.z(:),'filled');
    hold on
    end
    plot(P.datenum,P.z,'k.','markersize',4); 
    set(gca,'YDir','reverse')
    datetick('x')
    xlabel('time');
    ylabel('z [cm]')
    [ax,~]=colorbarwithvtext('z [cm]');
    title('<world space>')
    
    set(ax,'YDir','reverse')
    grid on