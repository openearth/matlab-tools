function trajectory_overview_plot(S,M,E,L,titletxt,clims)
%trajectory_overview_plot
%
%  trajectory_overview_plot(S,M,E,L,titletxt,clims)
%
%See also: trajectory_struct, trajectory2nc

    scatter(S.lon,S.lat,40,S.data,'.')
    hold on
    plot(L.lon,L.lat,'-' ,'color',[0 0 0])
    plot(E.lon,E.lat,'--','color',[0 0 0])
    grid on
    if nargin==6
    clim([clims])
    end
    axis([-2 9 50 57])    
    colorbarwithvtext([M.data.long_name,' [',M.data.units,'] z=',num2str(min(S.z(:))),'..',num2str(max(S.z(:))),' ',M.z.units])
    axislat
    tickmap('ll')
    title({titletxt,[datestr(min(S.datenum),'yyyy-mm'),' - ',datestr(max(S.datenum),'yyyy-mm')]})