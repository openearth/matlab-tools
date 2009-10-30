function UCIT_plotSandBalance(OPT, results, Volumes)


if strcmp(OPT.datatype,'jarkus'),datatype = 'Jarkus';,end
if strcmp(OPT.datatype,'vaklodingen'),datatype = 'Vaklodingen';,end

%% Polygon overview plot

nameInfo=['UCIT - Sandbalance polygon plot'];

% if isempty(findobj('tag','sbPlot'))
    fh = figure('tag','sbPlot'); clf; ah=axes;
    set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
    [fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);
    hold on;
    UCIT_plotLandboundary(datatype)
% else
%     fh=findobj('tag','sbPlot');
%     figure(fh);try delete(findobj('tag','polygon')),end;
%     hold on
% end

% plot used polygon
ph = plot(OPT.polygon(:,1), OPT.polygon(:,2),'color','g','tag','polygon','linewidth',1);
fill(OPT.polygon(:,1),OPT.polygon(:,2),'g','tag','polygon','facealpha',0.2,'linestyle','none');

% text
title(['Volume development for ' strrep(results.polyname,'_',' ') ' (' OPT.datatype ')']); 

% set axis
set(gca, 'Xlim',[min(OPT.polygon(:,1))- 10000 max(OPT.polygon(:,1)) + 10000]);
set(gca, 'Ylim',[min(OPT.polygon(:,2))- 10000 max(OPT.polygon(:,2)) + 10000]);
set(gca,'fontsize',8);box

%% Volume development plot
nameInfo=['UCIT - Volume development plot'];

% if isempty(findobj('tag','VolPlot'))
    fh = figure('tag','VolPlot'); clf; ah=axes;
    set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
    [fh,ah] = UCIT_prepareFigureN(0, fh, 'UR', ah);
    hold on
% else
%     fh=findobj('tag','VolPlot');
%     figure(fh);clf;
%     hold on
% end

% plot results method 1 (as line)
ph = plot(datenum(Volumes{1}(:,1),1,1), Volumes{1}(:,2) - Volumes{1}(1,2),'color','b','linewidth',2,'marker','o','MarkerFaceColor','b');

% plot results method 2 (as  stippelline)
ph = plot(datenum(Volumes{2}(:,1),1,1), Volumes{2}(:,2) - Volumes{2}(1,2),'color','b','linewidth',2,'marker','o','MarkerFaceColor','w','linestyle','--');

datetick;grid;

% set text
title(['Volume development for ' strrep(results.polyname,'_',' ') ' (' OPT.datatype ')'],'fontsize',8); 
legend(['Method 1: based on data points covered by target year and reference year (' num2str(OPT.reference_year) ')'],['Method 2: based on data points covered in all years'],'location','SouthOutside');

% set axis
xlabel('Time [years]','fontsize',8);ylabel('Volume [m^3]','fontsize',8);
set(gca,'fontsize',8);
