clc; close all;

addpath([pwd,filesep,'Scrpts_Reduction',filesep]);
addpath([pwd,filesep,'Scrpts_D3D-Deal',filesep]);
addpath([pwd,filesep,'Scrpts_Assimilation',filesep]);
addpath([pwd,filesep,'Scrpts_Observations',filesep]);

%% Attempts to estimate system error by comparing a 3D simulation with a 2D
%% simulation.
%
% Differences between a full 3D model simulation and a 2D model simulation
% where estimated in an effort to get a clue about the system error. 
% 
%
%
    close all 
    clear
    file1  = 'p:\x0385-gs-mor\ivan\paper_2_steps\test_6\iteration005\background\';
    runid1 = 'efrance';
    
    file2  = 'p:\x0385-gs-mor\ivan\paper_2_steps\test_6\iteration005\background3D\';
    runid2 = 'efrance';
    
    [the_diff,run2D,run3D] = compare_maps(file1,runid1,file2,runid2);
    
    dps_changes2d = run2D.vectors.dps(:,2:end) - run2D.vectors.dps(:,1:end-1);
    dps_changes3d = run3D.vectors.dps(:,2:end) - run3D.vectors.dps(:,1:end-1);
    dps_changes_error = dps_changes3d'-dps_changes2d';
    
    [S,V,D] = svds(cov(dps_changes_error),40);
    V_diag = diag(V);

    
    h = semilogy([1:length(V_diag)],V_diag./V_diag(1),'-b.','markersize',15)
    set(h,'linewidth',1.5)
    posSw = [559   346   807   270];
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'Position',posSw);
    ylabel('Singular Value');
    xlabel('Component');
    
    print('-depsc','spectral_energy_svd_3d-2d')
    print('-dpng','spectral_energy_svd_3d-2d')

%% Effects of restarting a delft3D model simulation 

if false
    clear, clc;
    
    options.getrunsinfo.depthreshold = 0.01;                               % Depth threshold for reading from mapfile, nothing to-do with Delft3D
    options.getrunsinfo.time = 'flow';                                      % could also be 'flow'... but if morphological scaling, then should be mor
    options.getrunsinfo.bordermarginN = 1;
    options.getrunsinfo.bordermarginS = 1;
    options.getrunsinfo.bordermarginE = 1;
    options.getrunsinfo.bordermarginW = 1;
    options.getrunsinfo.velocitydata = 1;
    options.getrunsinfo.waterleveldata = 1;
        
    restarted = getrunsinfo('p:\x0385-gs-mor\ivan\paper_2\test_4_eval_restart\conRoller_restart\','efrance',options.getrunsinfo);
    onerun = getrunsinfo('p:\x0385-gs-mor\ivan\paper_2\test_4_eval_restart\conRoller_restart\','efrance0',options.getrunsinfo);
    run3d = getrunsinfo('p:\x0385-gs-mor\ivan\paper_2_steps\test_6\iteration005\background3D\','efrance0',options.getrunsinfo);
    
    [loc_onerun,loc_restart] = ismember(cellstr(datestr([onerun.times{:}])),cellstr(datestr([restarted.times{:}])));
    
    loc_onerun = find(loc_onerun);
    loc_restart = loc_restart(loc_restart~=0)
    
    the_diffs = onerun.vectors.wlevel(:,loc_onerun) - restarted.vectors.wlevel(:,loc_restart);
    
    
    uvel_diff = onerun.vectors.uvel(:,2:end) - onerun.vectors.uvel(:,1:end-1);
    vvel_diff = onerun.vectors.vvel(:,2:end) - onerun.vectors.vvel(:,1:end-1);
    for itime = 1:1:length(onerun.times)-1
        disp(['time: ',num2str(onerun.times{itime}),' --- uvel: ',num2str(norm(uvel_diff(:,itime))),' --- vvel: ',num2str(norm(vvel_diff(:,itime)))])
    end
    
    for itime = 1:1:length(loc_onerun)
        figure;
        pcolor(reshape(the_diffs(:,itime),onerun.n,onerun.m)); shading flat;
        colorbar
        disp('The norm is: ',norm(the_diffs(:,itime)))
    end
end

%% COMPARISON OF MODEL AND OBSERVATIONS BATHYMETRIC CHANGES

if true

    hr  =[0  1  4  9  15 18 21 26 31 37 40 45 51 59 66 72 78 84 92 100 108 112 118 126 126]; % Hours
    mn  =[0  40 00 40 40 00 00 00 20 20 00 40 40 40 00 00 20 20 00 40  20  40  20  00  00];  % Minutes

  % -> Upload the model
%      model = getrunsinfo('p:\x0385-gs-mor\ivan\paper_2\test_4_morphSpinUp\Normal_Calibrated\','efrance');
    
  % -> Upload the observations    
    sourceFolder = 'p:\x0385-gs-mor\ivan\paper_2\Data from Rosh\bathymetries\';
    thegrdfile = dir([sourceFolder,'topo_1m_*.grd']);
    thedepfile = dir([sourceFolder,'topo_1m_*.dep']);

    for ifile = 1:length(thegrdfile)
        
        disp([sourceFolder,thegrdfile(ifile).name]);
        thegrid = wlgrid('read',[sourceFolder,thegrdfile(ifile).name]);
        
        disp([sourceFolder,thedepfile(ifile).name]);
           data.dps = wldep('read',[sourceFolder,thedepfile(ifile).name],thegrid);
     
        data.time(ifile) = datenum([num2str(hr(ifile),'%02.0f'),num2str(mn(ifile),'%02.0f')],'HHMM');
        error
        data.dps(:,ifile) = thefile.data(:,3);
    end

    
    [~,IA,~] = INTERSECT(roundto(model.times/24,4),roundto(data.time-min(data.time),4))
    
  % -> Inputs
    theFontSize = 12;
    [eroD,accD] = calculate_accretion_erosion(data.dps);
    [eroM,accM] = calculate_accretion_erosion(model.vectors.dps(:,IA));
    
    subplot(1,2,1)
    plot(data.time(1:end),[0,ero],'b--',data.time(1:end),[0,acc],'b--');
    subplot(1,2,2)
    plot(model.times(1:end),[0,eroM],'r--',model.times(1:end),[0,accM],'r--');
    
    xlim([min(data.time),max(data.time)]);
    tick('x',data.time,'%f')
    datetick('x','HH:MM','keeplimits','keepticks')
    legend('Erosion','Accretion');
    ylabel('Cumulative change [m]','fontsize',theFontSize)
    xlabel('Time','fontsize',theFontSize)
    set(gca,'FontSize',theFontSize);
    print('-depsc2','Total_changes_in_depth');

end

%% ANALYSIS OF SEDIMENT TRANSPORT AT BEGINNING OF THE SIMULATION PROCESS
if false
    options.getrunsinfo.depthreshold = 0;                               % Depth threshold for reading from mapfile, nothing to-do with Delft3D
    options.getrunsinfo.time = 'mor';                                      % could also be 'flow'... but if morphological scaling, then should be mor
    options.getrunsinfo.bordermarginN = 0;
    options.getrunsinfo.bordermarginS = 0;
    options.getrunsinfo.bordermarginE = 0;
    options.getrunsinfo.bordermarginW = 0;


    normal        = getrunsinfo('p:\x0385-gs-mor\ivan\paper_2\test_4_morphSpinUp\Normal_10\','efrance',options.getrunsinfo);
    normal.vectors.increments = normal.vectors.dps(:,2:end) - normal.vectors.dps(:,1:end-1);
    for itime = 1:1:(length(normal.times)-1)
        normal.vectors.erosion(itime)   = sum(normal.vectors.increments(normal.vectors.increments(:,itime)<0,itime));
        normal.vectors.accretion(itime) = sum(normal.vectors.increments(normal.vectors.increments(:,itime)>0,itime));
    end

    noSpin        = getrunsinfo('p:\x0385-gs-mor\ivan\paper_2\test_4_morphSpinUp\No_spinUp_10\','efrance',options.getrunsinfo);
    noSpin.vectors.increments = noSpin.vectors.dps(:,2:end) - noSpin.vectors.dps(:,1:end-1);
    for itime = 1:1:(length(noSpin.times)-1)
        noSpin.vectors.erosion(itime)   = sum(noSpin.vectors.increments(noSpin.vectors.increments(:,itime)<0,itime));
        noSpin.vectors.accretion(itime) = sum(noSpin.vectors.increments(noSpin.vectors.increments(:,itime)>0,itime));
    end

    smoothingTime = getrunsinfo('p:\x0385-gs-mor\ivan\paper_2\test_4_morphSpinUp\smoothingTime_480_10\','efrance',options.getrunsinfo)
    smoothingTime.vectors.increments = smoothingTime.vectors.dps(:,2:end) - smoothingTime.vectors.dps(:,1:end-1);
    for itime = 1:1:(length(smoothingTime.times)-1)
        smoothingTime.vectors.erosion(itime)   = sum(smoothingTime.vectors.increments(smoothingTime.vectors.increments(:,itime)<0,itime));
        smoothingTime.vectors.accretion(itime) = sum(smoothingTime.vectors.increments(smoothingTime.vectors.increments(:,itime)>0,itime));
    end

    figure
    plot(   normal.times(2:end),abs(normal.vectors.erosion),              '.-r',normal.times(2:end),normal.vectors.accretion,'--r', ...
            noSpin.times(2:end),abs(noSpin.vectors.erosion),              '.-b',noSpin.times(2:end),noSpin.vectors.accretion,'--b', ...
            smoothingTime.times(2:end),abs(smoothingTime.vectors.erosion),'.-g',smoothingTime.times(2:end),smoothingTime.vectors.accretion,'--g');    
    xlabel('time [hr]');
    ylabel('cumulative erosion (negative)/accretion (positive) [m]');


    figure
    lahora = 24*5;
    subplot(2,3,1); pcolor(reshape(normal.vectors.dps(:,round(normal.times*10000)/10000 == lahora) - noSpin.vectors.dps(:,round(noSpin.times*10000)/10000 == lahora),normal.n,normal.m)); shading flat; colorbar('Location','north'); set(gca,'fontsize',6); ylim([2,45]);
    subplot(2,3,2); pcolor(reshape(noSpin.vectors.dps(:,round(noSpin.times*10000)/10000 == lahora) - smoothingTime.vectors.dps(:,round(smoothingTime.times*10000)/10000 == lahora), normal.n,normal.m)); shading flat; colorbar('Location','north'); set(gca,'fontsize',6); title('DIFFERENCES IN BATHYMETRY AFTER 6 HOURS','fontweight','bold'); ylim([2,45]);
    subplot(2,3,3); pcolor(reshape(normal.vectors.dps(:,round(normal.times*10000)/10000 == lahora) - smoothingTime.vectors.dps(:,round(smoothingTime.times*10000)/10000 == lahora), normal.n,normal.m)); shading flat; colorbar('Location','north'); set(gca,'fontsize',6); ylim([2,45]); elaxis = caxis;
    subplot(2,3,2); caxis(elaxis);
    subplot(2,3,1); caxis(elaxis);

    lahora = 24*9;
    subplot(2,3,4); pcolor(reshape(normal.vectors.dps(:,round(normal.times*10000)/10000 == lahora) - noSpin.vectors.dps(:,round(noSpin.times*10000)/10000 == lahora), normal.n,normal.m)); colorbar('Location','north'); set(gca,'fontsize',6); shading flat; elaxis = caxis; ylim([2,45]);
    subplot(2,3,5); pcolor(reshape(noSpin.vectors.dps(:,round(noSpin.times*10000)/10000 == lahora) - smoothingTime.vectors.dps(:,round(smoothingTime.times*10000)/10000 == lahora), normal.n,normal.m)); shading flat; colorbar('Location','north'); set(gca,'fontsize',6); caxis(elaxis); title('DIFFERENCES IN BATHYMETRY AFTER 12 HOURS','fontweight','bold'); ylim([2,45]);
    subplot(2,3,6); pcolor(reshape(normal.vectors.dps(:,round(normal.times*10000)/10000 == lahora) - smoothingTime.vectors.dps(:,round(smoothingTime.times*10000)/10000 == lahora), normal.n,normal.m)); shading flat; colorbar('Location','north'); set(gca,'fontsize',6); caxis(elaxis); ylim([2,45]);
    print('-depsc2','p:\x0385-gs-mor\ivan\paper_2\test_4_morphSpinUp\bathymetric_evolution')
    
    f = figure
    lahora = 6;
    subplot(2,6,[1:3]);
    hold on;
    contour(reshape(normal.vectors.x,normal.n,normal.m),reshape(normal.vectors.y,normal.n,normal.m),reshape(normal.vectors.dps(:,round(normal.times*10000)/10000 == lahora),normal.n,normal.m),[0:0.05:0.3],'color','b')
    contour(reshape(noSpin.vectors.x,noSpin.n,noSpin.m),reshape(noSpin.vectors.y,noSpin.n,noSpin.m),reshape(noSpin.vectors.dps(:,round(noSpin.times*10000)/10000 == lahora),noSpin.n,noSpin.m),[0:0.05:0.3],'color','r')
    contour(reshape(smoothingTime.vectors.x,smoothingTime.n,smoothingTime.m),reshape(smoothingTime.vectors.y,smoothingTime.n,smoothingTime.m),reshape(smoothingTime.vectors.dps(:,round(smoothingTime.times*10000)/10000 == lahora),smoothingTime.n,smoothingTime.m),[0:0.05:0.3],'color','g')
    xlim([105,125])
    ylim([100,110])
    legend('Spinup 480','No Spinup','Smoothing Time 480');
    set(gca,'fontsize',6)
    
    lahora = 12;
    subplot(2,6,[4:6]);
    hold on;
    contour(reshape(normal.vectors.x,normal.n,normal.m),reshape(normal.vectors.y,normal.n,normal.m),reshape(normal.vectors.dps(:,round(normal.times*10000)/10000 == lahora),normal.n,normal.m),[0:0.05:0.3],'color','b')
    contour(reshape(noSpin.vectors.x,noSpin.n,noSpin.m),reshape(noSpin.vectors.y,noSpin.n,noSpin.m),reshape(noSpin.vectors.dps(:,round(noSpin.times*10000)/10000 == lahora),noSpin.n,noSpin.m),[0:0.05:0.3],'color','r')
    contour(reshape(smoothingTime.vectors.x,smoothingTime.n,smoothingTime.m),reshape(smoothingTime.vectors.y,smoothingTime.n,smoothingTime.m),reshape(smoothingTime.vectors.dps(:,round(smoothingTime.times*10000)/10000 == lahora),smoothingTime.n,smoothingTime.m),[0:0.05:0.3],'color','g')
    xlim([105,125])
    ylim([100,110])
    legend('Spinup 480','No Spinup','Smoothing Time 480');
    set(gca,'fontsize',6)
    
    subplot(2,6,[7:8])
    contour(reshape(normal.vectors.x,normal.n,normal.m),reshape(normal.vectors.y,normal.n,normal.m),reshape(normal.vectors.dps(:,round(normal.times*10000)/10000 == lahora),normal.n,normal.m),[0:0.05:0.3],'color','b'); xlim([105,125]); ylim([100,110])
    set(gca,'fontsize',6)
    legend('Spinup 480');
    subplot(2,6,[9:10])
    contour(reshape(noSpin.vectors.x,noSpin.n,noSpin.m),reshape(noSpin.vectors.y,noSpin.n,noSpin.m),reshape(noSpin.vectors.dps(:,round(noSpin.times*10000)/10000 == lahora),noSpin.n,noSpin.m),[0:0.05:0.3],'color','r'); xlim([105,125]); ylim([100,110])
    set(gca,'fontsize',6)
    legend('No Spinup');
    title ('CONTOUR LINES AFTER 12 HOURS OF MORPHODYNAMIC UPDATES','fontweight','bold','fontsize',8)
    subplot(2,6,[11;12])
    contour(reshape(smoothingTime.vectors.x,smoothingTime.n,smoothingTime.m),reshape(smoothingTime.vectors.y,smoothingTime.n,smoothingTime.m),reshape(smoothingTime.vectors.dps(:,round(smoothingTime.times*10000)/10000 == lahora),smoothingTime.n,smoothingTime.m),[0:0.05:0.3],'color','g'); xlim([105,125]); ylim([100,110])
    set(gca,'fontsize',6)
    legend('Smoothing Time 480');

    print('-depsc2','p:\x0385-gs-mor\ivan\paper_2\test_4_morphSpinUp\contours_evolution')
end