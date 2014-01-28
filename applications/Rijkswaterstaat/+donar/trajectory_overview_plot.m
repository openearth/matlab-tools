function trajectory_overview_plot(S,M,E,L,titletxt,clims)
%trajectory_overview_plot
%
%  trajectory_overview_plot(S,M,E,L,titletxt,clims)
%
%See also: trajectory_struct, trajectory2nc
clf;
AX = subplot_meshgrid(2,2,[.07 .01 .06],[.025 .04 .045],[nan .1],[nan .14]);
%%
axes(AX(1,1))

    plot(S.lon,S.lat,'k-','color',[.5 .5 .5])
    hold on
   %scatter(S.lon,S.lat,40,S.data,'.')
    plot(L.lon,L.lat,'-' ,'color',[0 0 0])
    plot(E.lon,E.lat,'--','color',[0 0 0])
    grid on
    if nargin==6
        if isnan(clims(1))
            clims(1) = nanmin(S.data(:))-100*eps;
        end
        if isnan(clims(2))
            clims(2) = nanmax(S.data(:))+100*eps;
        end
        clim([clims])
    end
    axis([-1.7 9.7 50.7 56])    
   [cb, h]=colorbarwithvtext(mktex({M.data.long_name,['[',M.data.units,']',]}),...
       'position',get(AX(2,1),'position'));
    delete(AX(2,1))
    ctick      = get(cb,'ytick');
    cticklabel = get(cb,'yticklabel');
    axislat
    set(AX(1,1),'ytick',[51:56])
    tickmap('ll')
    ylabel([titletxt,' z=',num2str(min(S.z(:))),'..',num2str(max(S.z(:))),'[',M.z.units,']']); % [datestr(min(S.datenum),'yyyy-mmm-dd'),' - ',datestr(max(S.datenum),'yyyy-mmm-dd')]
    box on
    
axes(AX(1,2))

    plot(S.datenum,S.data,'k-','color',[.5 .5 .5])
    hold on
   %scatter(S.datenum,S.data,40,S.data,'.')
    axis tight
    datetick('x')
    %text(S.datenum(  1),clims(1),['\leftarrow',datestr(min(S.datenum),'yyyy-mmm-dd')],'vert','bot','hor','left')
    %text(S.datenum(end),clims(1),[datestr(max(S.datenum),'yyyy-mmm-dd'),'\rightarrow'],'vert','bot','hor','right')
    text(S.datenum(  1),clims(1),[datestr(min(S.datenum),'yyyy-mmm-dd')],'vert','bot','hor','left','rot',90)
    text(S.datenum(end),clims(1),[datestr(max(S.datenum),'yyyy-mmm-dd')],'vert','top','hor','left','rot',90)
    ylim(clims)
    %set(AX(2),'ytick'     ,ctick )
    %set(AX(2),'yticklabel',cticklabel)
    grid on
    box on
    
    position = get(AX(1,2),'position');
    position(3) = .87;
    set(AX(1,2),'position',position)
    delete(AX(2,2))
