function cosmos_makeForecastPlot(hm,m)

% Makes map plots and KMZs

t=0;

name='';

try
    
    model=hm.models(m);
    dr=model.dir;
    if model.forecastplot.plot
        
        settings.thin = model.forecastplot.thinning;
        settings.scal = model.forecastplot.scalefactor;
        settings.xlim = model.forecastplot.xlims;
        settings.ylim = model.forecastplot.ylims;
        settings.clim = model.forecastplot.clims;
        
        name=model.forecastplot.name;
        
        fname=[model.archiveDir hm.cycStr filesep 'maps' filesep 'vel.mat'];
        s(1).data=load(fname);
        fname=[model.archiveDir hm.cycStr filesep 'maps' filesep 'bedlevel.mat'];
        s(2).data=load(fname);
        fname=[model.archiveDir hm.cycStr filesep 'timeseries' filesep 'wl.zandmotorNoord.mat'];
        s(3).data=load(fname);
        
        if exist([dr 'data' filesep model.forecastplot.ldb '.ldb'],'file')
            ldb=landboundary('read',[dr 'data' filesep model.forecastplot.ldb '.ldb']);
        end
        
        AvailableTimes=s(1).data.Time;
        dt=86400*(AvailableTimes(2)-AvailableTimes(1));
        n3=round(model.forecastplot.timeStep/dt);
        n3=max(n3,1);
        nt=length(s(1).data.Time);
        
        for it=1:n3:nt
            
            input.scrsz= get(0, 'ScreenSize');               % Set plot figure on full screen
            figure('Visible','On','Position', [input.scrsz]);
            hold on; set(gcf,'defaultaxesfontsize',8)
            
            thin = settings.thin;
            scal = settings.scal;
            mag  = squeeze((s(1).data.U(it,:,:).^2 + s(1).data.V(it,:,:).^2).^0.5);
            
            timnow = s(1).data.Time(it);
            
            % model plot
            
            ax1 = gca; hold on;
            pcolor(s(1).data.X,s(1).data.Y,mag);shading interp;axis equal
            
            quiver(s(1).data.X(1:thin:end,1:thin:end),s(1).data.Y(1:thin:end,1:thin:end),...
                scal*squeeze(s(1).data.U(it,1:thin:end,1:thin:end)),...
                scal*squeeze(s(1).data.V(it,1:thin:end,1:thin:end)),0,'color',[0 0 0])
            
            % filledLDB(ldb2,[1 1 1],[1 1 1],8,0)
            filledLDB(ldb,[0 0 0],[0.7 0.9 0.8],10,0)
            %             filledLDB(ldb3,[0 0 0],[1 1 1],8,0)
            
            [cb,h] = contour(s(2).data.X,s(2).data.Y,squeeze(s(2).data.Val),[-16:2:2])
            set(h,'linecolor',[0.8 0.8 0.8])
            clim(settings.clim)
            cb = colorbar;
            
            set(gca,'xlim',settings.xlim)
            set(gca,'ylim',settings.ylim)
            kmaxis(gca,[0.2 0.2])
            boxrepair(gca)
            
            % axes 2
            ax2 = axes('position',[0.68 0.30 0.12 0.1])
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.1,0.8,'Wind','fontsize',10,'fontweight','bold')
            text(0.1,0.6,'Richting: ZW, 221^oN','fontsize',8)
            text(0.1,0.4,'Snelheid: 10 m/s,','fontsize',8)
            text(0.1,0.2,'4 bft','fontsize',8)
            
            % axes 2a
            ax2a = axes('position',[0.753 0.309 0.0314 0.0439])
            axis equal;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            arrow([0 0],[0.93 1],'Width',1,'LineWidth',1.5,'length',15,'faceColor','b','edgecolor','b')
            box off;
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            
            % axes 3
            ax3 = axes('position',[0.80 0.30 0.12 0.1])
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.1,0.6,strrep(strrep(datestr(timnow,1),'-',' '),'May','Mei'),'fontsize',12)
            text(0.2,0.4,datestr(timnow,16),'fontsize',12)
            
            % axes 4
            ax4 = axes('position',[0.68 0.20 0.12 0.1]); hold on;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.1,0.8,'Weer','fontsize',8,'fontweight','bold')
            text(0.1,0.6,'Luchttemp.: 19^o','fontsize',8)
            text(0.1,0.4,'Watertemp.: 12^o','fontsize',8)
            text(0.1,0.2,'Bewolking: geen','fontsize',8)
            
            % axes 4a
            ax2a = axes('position',[0.763 0.209 0.0314 0.0439])
            axis equal;
            %             image(im1)
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box off;
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            
            % axes 5
            ax5 = axes('position',[0.80 0.20 0.12 0.1])
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.1,0.8,'Golven','fontsize',8,'fontweight','bold')
            text(0.1,0.6,'Hoogte: 1.2m','fontsize',8)
            text(0.1,0.4,'Periode: 5s','fontsize',8)
            text(0.1,0.2,'Richting: ZW, 225^oN','fontsize',8)
            
            % axes 5a
            ax2a = axes('position',[0.883 0.209 0.0314 0.0439])
            axis equal;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            arrow([0 0],[1 1],'Width',1,'LineWidth',1.5,'length',15,'faceColor','g','edgecolor','g')
            box off;
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            
            % axes 6
            ax6 = axes('position',[0.68 0.10 0.24 0.1])
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            
            % axes 7
            ax7 = axes('position',[0.695 0.12 0.21 0.07]);hold on;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            plot(s(3).data.Time,s(3).data.Val,'linewidth',1);
            set(gca,'xlim',[floor(timnow)-1 floor(timnow)+2])
            set(gca,'xtick',[floor(timnow)-1:0.5:floor(timnow)+2])
            datetick('x','keeplimits','keepticks')
            tcks = get(gca,'xticklabel');
            tcks(2:2:end,:) = ' ';
            set(gca,'xticklabel',tcks);
            ylim([-1.2 1.4]);
            plot([timnow timnow],get(gca,'ylim'),'r','linewidth',2)
            
            set(cb,'position',[0.9087    0.5015    0.0159    0.2847])
            set(get(cb,'title'),'string','Snelheid (m/s)','fontsize',8)
            
            set(gcf,'paperOrientation','landscape')
            set(gcf,'paperPosition',[0.6345    2.2587   28.4084   16.4666])
            set(ax1,'position',[0.0104    0.0382    0.9882    0.9558])
            set(gcf,'renderer','zbuf')
            
            figname=[dr 'lastrun' filesep 'figures' filesep name '.' datestr(timnow,'yyyymmdd.HHMMSS') '.png'];
            print(gcf,'-dpng','-r300',figname);
            
            close(gcf)
            
        end
    end
    
catch
    
    WriteErrorLogFile(hm,['Something went wrong with generating map figures of ' name ' - ' model.name]);
    
end

