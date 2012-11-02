%% Sensitivities - Dpsopt #DP#
clear; clc; close all;
addpath('D:\Delft3D\matlab\');
basicPath = 'F:\Re-start Implications\Grid QuickIn\Dpsopt DP\Tlfsmo 0\';

cualPlot = 're-start';
whichtimes = 'mor';
dplim = 0.75;

flagBehavior = false;
flagConvergence = true;

switch lower(cualPlot)
  case 're-start'
    a(1).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Bg - 480 SpUp 120 - 720',filesep];
    a(2).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Bg - Restart 480 - 120 SpUp 120 - 720',filesep];
    a(3).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Ds - 480 SpUp 120 - 720',filesep];
    a(4).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Ds - Restart 480 - 120 SpUp 120 - 720',filesep];
    a(5).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Hs - 480 SpUp 120 - 720',filesep];
    a(6).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Hs - Restart 480 - 120 SpUp 120 - 720',filesep];
    a(7).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Tp - 480 SpUp 120 - 720',filesep];
    a(8).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Tp - Restart 480 - 120 SpUp 120 - 720',filesep];
    a(9).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Wd - 480 SpUp 120 - 720',filesep];
    a(10).name = [basicPath,'Coupling BWC\Sensitivities\No Roller\Wd - Restart 480 - 120 SpUp 120 - 720',filesep];
    
    bg1 = getrunsinfo({a(1).name},'Pbeach',whichtimes,dplim); bg2 = getrunsinfo({a(2).name},'Pbeach',whichtimes,dplim);
    ds1 = getrunsinfo({a(3).name},'Pbeach',whichtimes,dplim); ds2 = getrunsinfo({a(4).name},'Pbeach',whichtimes,dplim);
    hs1 = getrunsinfo({a(5).name},'Pbeach',whichtimes,dplim); hs2 = getrunsinfo({a(6).name},'Pbeach',whichtimes,dplim);
    tp1 = getrunsinfo({a(7).name},'Pbeach',whichtimes,dplim); tp2 = getrunsinfo({a(8).name},'Pbeach',whichtimes,dplim);
    wd1 = getrunsinfo({a(9).name},'Pbeach',whichtimes,dplim); wd2 = getrunsinfo({a(10).name},'Pbeach',whichtimes,dplim);

    % SENSITIVITIES & BEHAVIORS
    cmpBG = snapshots_analyses(bg1,bg1);
    cmpDS = snapshots_analyses(bg1,ds1);
    cmpHS = snapshots_analyses(bg1,hs1);
    cmpTP = snapshots_analyses(bg1,tp1);
    cmpWD = snapshots_analyses(bg1,wd1);
    
    cmpBGr = snapshots_analyses(bg1,bg2);
    cmpDSr = snapshots_analyses(bg1,ds2);
    cmpHSr = snapshots_analyses(bg1,hs2);
    cmpTPr = snapshots_analyses(bg1,tp2);
    cmpWDr = snapshots_analyses(bg1,wd2);
    %clear bg* ds* hs* tp* wd*
    
    figure(1)
    subplot(2,1,1)
    plot([cmpDSr.meanDiff{:,1}]',[cmpDSr.meanDiff{:,4}]', ...
         [cmpHSr.meanDiff{:,1}]',[cmpHSr.meanDiff{:,4}]', ... 
         [cmpTPr.meanDiff{:,1}]',[cmpTPr.meanDiff{:,4}]', ...
         [cmpWDr.meanDiff{:,1}]',[cmpWDr.meanDiff{:,4}]');
    legend('Ds', 'Hs', 'Tp', 'Wd', 'Location','NorthWest');
    ylabel('Mean Difference (m)');
    xlabel('Time (h)');
    title('Difference with respect to Background (One Re-Start)');
    
    subplot(2,1,2)
    plot([cmpDSr.L2norm{:,1}]',[cmpDSr.L2norm{:,4}]', ...
         [cmpHSr.L2norm{:,1}]',[cmpHSr.L2norm{:,4}]', ... 
         [cmpTPr.L2norm{:,1}]',[cmpTPr.L2norm{:,4}]', ...
         [cmpWDr.L2norm{:,1}]',[cmpWDr.L2norm{:,4}]');
    legend('Ds', 'Hs', 'Tp', 'Wd', 'Location','NorthWest');
    ylabel('L2 Norm (m)');
    xlabel('Time (h)');
    title('Difference with respect to Background (One Re-Start)');
    
    figure(2)
    subplot(2,1,1)
    plot([cmpDS.meanDiff{:,1}]',[cmpDS.meanDiff{:,4}]', ...
         [cmpHS.meanDiff{:,1}]',[cmpHS.meanDiff{:,4}]', ... 
         [cmpTP.meanDiff{:,1}]',[cmpTP.meanDiff{:,4}]', ...
         [cmpWD.meanDiff{:,1}]',[cmpWD.meanDiff{:,4}]');
    legend('Ds', 'Hs', 'Tp', 'Wd', 'Location','NorthWest');
    ylabel('Mean Difference (m)');
    xlabel('Time (h)');
    title('Difference with respect to Background (No Re-Start)');
    
    subplot(2,1,2)
    plot([cmpDS.L2norm{:,1}]',[cmpDS.L2norm{:,4}]', ...
         [cmpHS.L2norm{:,1}]',[cmpHS.L2norm{:,4}]', ... 
         [cmpTP.L2norm{:,1}]',[cmpTP.L2norm{:,4}]', ...
         [cmpWD.L2norm{:,1}]',[cmpWD.L2norm{:,4}]');
    legend('Ds', 'Hs', 'Tp', 'Wd', 'Location','NorthWest');
    ylabel('L2 Norm (m)');
    xlabel('Time (h)');
    title('Difference with respect to Background (No Re-Start)');
    
    figure(3)
    subplot(2,1,1)
    plot([cmpBGr.meanDiff{:,1}]',[cmpBGr.meanDiff{:,4}]');
    legend('Background', 'Location','NorthWest');
    ylabel('Mean Difference (m)');
    xlabel('Time (h)');
    
    subplot(2,1,2)
    plot([cmpBGr.L2norm{:,1}]',[cmpBGr.L2norm{:,4}]');
    legend('Background', 'Location','NorthWest');
    ylabel('L2 - Norm (m)');
    xlabel('Time (h)');
    return;
    
  case 'bwc'
    a(1).name = [basicPath,'Coupling BWC\Bathymetry\OS - 480 SpUp 720 - 720\Bg - 480 SpUp 720 - 720',filesep];
    a(2).name = [basicPath,'Coupling BWC\Bathymetry\OS - 480 SpUp 720 - 720\Ds - 480 SpUp 720 - 720',filesep];
    a(3).name = [basicPath,'Coupling BWC\Bathymetry\OS - 480 SpUp 720 - 720\Hs - 480 SpUp 720 - 720',filesep];
    a(4).name = [basicPath,'Coupling BWC\Bathymetry\OS - 480 SpUp 720 - 720\Tp - 480 SpUp 720 - 720',filesep];
    a(5).name = [basicPath,'Coupling BWC\Bathymetry\OS - 480 SpUp 720 - 720\Wd - 480 SpUp 720 - 720',filesep];
  case 'noroller_bwc'
    a(1).name = [basicPath,'Coupling BWC\Bathymetry\No Roller\Bg - 480 SpUp 240 - 720',filesep];
    a(2).name = [basicPath,'Coupling BWC\Bathymetry\No Roller\Ds - 480 SpUp 240 - 720',filesep];
    a(3).name = [basicPath,'Coupling BWC\Bathymetry\No Roller\Hs - 480 SpUp 240 - 720',filesep];
    a(4).name = [basicPath,'Coupling BWC\Bathymetry\No Roller\Tp - 480 SpUp 240 - 720',filesep];
    a(5).name = [basicPath,'Coupling BWC\Bathymetry\No Roller\Wd - 480 SpUp 240 - 720',filesep];
  case 'thetsd_0_bwc'
    a(1).name = [basicPath,'Coupling BWC\ThetSD_0\Bg - 480 SpUp 120 - 720',filesep];
    a(2).name = [basicPath,'Coupling BWC\ThetSD_0\Ds - 480 SpUp 120 - 720',filesep];
    a(3).name = [basicPath,'Coupling BWC\ThetSD_0\Hs - 480 SpUp 120 - 720',filesep];
    a(4).name = [basicPath,'Coupling BWC\ThetSD_0\Tp - 480 SpUp 120 - 720',filesep];
    a(5).name = [basicPath,'Coupling BWC\ThetSD_0\Wd - 480 SpUp 120 - 720',filesep];
  case 'oneshots_b'
    a(1).name = [basicPath,'Coupling B\Oneshots\Bg - 480 SpUp 240 - 240',filesep];
    a(2).name = [basicPath,'Coupling B\Oneshots\Ds - 480 SpUp 240 - 240',filesep];
    a(3).name = [basicPath,'Coupling B\Oneshots\Hs - 480 SpUp 240 - 240',filesep];
    a(4).name = [basicPath,'Coupling B\Oneshots\Tp - 480 SpUp 240 - 240',filesep];
    a(5).name = [basicPath,'Coupling B\Oneshots\Wd - 480 SpUp 240 - 240',filesep];
  case '20x20_b'
    a(1).name = [basicPath,'Coupling B\Re-Start\Bg - Stps 20 - 480 & 360s SpUp - 5e-1 - 240',filesep];
    a(2).name = [basicPath,'Coupling B\Re-Start\Ds - Stps 20 - 480 & 360s SpUp - 5e-1 - 240',filesep];
    a(3).name = [basicPath,'Coupling B\Re-Start\Hs - Stps 20 - 480 & 360s SpUp - 5e-1 - 240',filesep];
    a(4).name = [basicPath,'Coupling B\Re-Start\Tp - Stps 20 - 480 & 360s SpUp - 5e-1 - 240',filesep];
    a(5).name = [basicPath,'Coupling B\Re-Start\Wd - Stps 20 - 480 & 360s SpUp - 5e-1 - 240',filesep];
  case '1x20'
    a(1).name = [basicPath,'Bg - Stps 20 - 480 & 360s SpUp',filesep];
    a(2).name = [basicPath,'Ds - Stps 11',filesep];
    a(3).name = [basicPath,'Hs - Stps 11',filesep];
    a(4).name = [basicPath,'Tp - Stps 11',filesep];
    a(5).name = [basicPath,'Wd - Stps 11',filesep];
  case'11x11'
    a(1).name = [basicPath,'Bg - Stps 11',filesep];
    a(2).name = [basicPath,'Ds - Stps 11',filesep];
    a(3).name = [basicPath,'Hs - Stps 11',filesep];
    a(4).name = [basicPath,'Tp - Stps 11',filesep];
    a(5).name = [basicPath,'Wd - Stps 11',filesep];
  otherwise
    disp('What you doing?')
end

bg = getrunsinfo({a(1).name},'Pbeach',whichtimes,dplim);
ds = getrunsinfo({a(2).name},'Pbeach',whichtimes,dplim);
hs = getrunsinfo({a(3).name},'Pbeach',whichtimes,dplim);
tp = getrunsinfo({a(4).name},'Pbeach',whichtimes,dplim);
wd = getrunsinfo({a(5).name},'Pbeach',whichtimes,dplim);

% SENSITIVITIES & BEHAVIORS
cmpDS = snapshots_analyses(bg,ds);
cmpHS = snapshots_analyses(bg,hs);
cmpTP = snapshots_analyses(bg,tp);
cmpWD = snapshots_analyses(bg,wd);
clear bg ds hs tp wd

figure(1);
%suptitle('Bathymetry Differences w.r.t. Reference')
subplot(1,3,1)
plot([cmpDS.L2norm{:,1}]',[cmpDS.L2norm{:,4}]', ...
     [cmpHS.L2norm{:,1}]',[cmpHS.L2norm{:,4}]', ...
     [cmpTP.L2norm{:,1}]',[cmpTP.L2norm{:,4}]', ...
     [cmpWD.L2norm{:,1}]',[cmpWD.L2norm{:,4}]');
legend('Ds', 'Hs', 'Tp', 'Wd', 'Location','NorthWest');
ylabel('L2 Norm (m)');
xlabel('Time (h)');

subplot(1,3,2)
plot([cmpDS.meanDiff{:,1}]',[cmpDS.meanDiff{:,4}]', ...
     [cmpHS.meanDiff{:,1}]',[cmpHS.meanDiff{:,4}]', ...
     [cmpTP.meanDiff{:,1}]',[cmpTP.meanDiff{:,4}]', ...
     [cmpWD.meanDiff{:,1}]',[cmpWD.meanDiff{:,4}]');
legend('Ds', 'Hs', 'Tp', 'Wd', 'Location','NorthWest');
ylabel('Mean Difference (m)');
xlabel('Time (h)');

subplot(1,3,3)
plot([cmpDS.meanDiff{:,1}]',[cmpDS.maxDiff{:,4}]', ...
     [cmpHS.meanDiff{:,1}]',[cmpHS.maxDiff{:,4}]', ...
     [cmpTP.meanDiff{:,1}]',[cmpTP.maxDiff{:,4}]', ...
     [cmpWD.meanDiff{:,1}]',[cmpWD.maxDiff{:,4}]');
legend('Ds', 'Hs', 'Tp', 'Wd', 'Location','NorthWest');
ylabel('Maximum Difference (m)');
xlabel('Time (h)');


% figure(4)
% plot([cmpDS.L2norm{:,1}]',[cmpDS.L2norm{:,2}]', [cmpDS.L2norm{:,1}]',[cmpDS.L2norm{:,3}]', ...
%      [cmpHS.L2norm{:,1}]',[cmpHS.L2norm{:,2}]', [cmpHS.L2norm{:,1}]',[cmpHS.L2norm{:,3}]', ...
%      [cmpTP.L2norm{:,1}]',[cmpTP.L2norm{:,2}]', [cmpTP.L2norm{:,1}]',[cmpTP.L2norm{:,3}]', ...
%      [cmpWD.L2norm{:,1}]',[cmpWD.L2norm{:,2}]', [cmpWD.L2norm{:,1}]',[cmpWD.L2norm{:,3}]');
%  
% legend('Ds (U vel)', 'Ds (V vel)', ...
%        'Hs (U Vel)', 'Hs (V vel)', ...
%        'Tp (U Vel)', 'Tp (V vel)', ...
%        'Wd (U Vel)', 'Wd (V vel)', ...
%        'Location','NorthOutside');
% ylabel('L2 Norm (m/s)');
% xlabel('Time (h)');
% title('Velocity Change with Respect to Reference')

if flagBehavior
  disp('Analyzing Behaviors')
  tbeh_bg = behavior_analysis(bg);
  tbeh_ds = behavior_analysis(ds);
  tbeh_hs = behavior_analysis(hs);
  tbeh_tp = behavior_analysis(tp);
  tbeh_wd = behavior_analysis(wd);

  figure(5)
  plot(tbeh_bg.dps(:,1),tbeh_bg.dps(:,2), ...
     tbeh_ds.dps(:,1),tbeh_ds.dps(:,2), ...
     tbeh_hs.dps(:,1),tbeh_hs.dps(:,2), ...
     tbeh_tp.dps(:,1),tbeh_tp.dps(:,2), ...
     tbeh_wd.dps(:,1),tbeh_wd.dps(:,2));

  legend('Reference','Directional Spreading','Significant Height','Peak Period','Direction');
  ylabel('L2 Norm (m)');
  xlabel('Map Saving Step');
end

if flagConvergence
  disp('Analyzing Convergence to Initial Conditions')
  convbg = convergence2intialconditions(bg);
  convds = convergence2intialconditions(ds);
  convhs = convergence2intialconditions(hs);
  convtp = convergence2intialconditions(tp);
  convwd = convergence2intialconditions(wd);
  disp('Differences between initial conditions and the bathymatries at each timestep finished');
  
  figure(6);
  subplot(2,3,1); surf(convbg.dps{61,3})
  subplot(2,3,2); surf(convds.dps{61,3})
  subplot(2,3,3); surf(convhs.dps{61,3})
  subplot(2,3,4); surf(convtp.dps{61,3})
  subplot(2,3,5); surf(convwd.dps{61,3})
end

% _________________________________________________________________________
%% Backgrounds
clear; clc; close all;

addpath('C:\Delft3D\w32\matlab\');
basicPath = 'D:\Re-start Implications\Grid QuickIn\Dpsopt DP\Tlfsmo 0\';

cualPlot = 'restart';
whichtimes = 'flow';
dplim = 0.75;

onlyDPS = false;
flagBehavior = false; 
flagDiff = true; %only makes sense for restart with spinup
flagWL = false;

switch cualPlot
  case 'bgs_b'
    a(1).name = [basicPath,'Coupling B\Bg - SpUp 240\',filesep];
    a(2).name = [basicPath,'Coupling B\Bg - Stps 02 - 480 & 360  SpUp 006 - 2e-1\Step001\',filesep];
  case 'bgs_bwc'
    a(1).name = [basicPath,'Bg - SpUp 120',filesep];
    a(2).name = [basicPath,'Bg - Stps 11',filesep];
    a(3).name = [basicPath,'Bg - Stps 02 - 120',filesep];
    a(4).name = [basicPath,'Bg - Stps 02 SpUp',filesep];
    
    bg_0 = getrunsinfo({a(1).name},'Pbeach');
    bg_1 = getrunsinfo({a(2).name},'Pbeach');
    bg_2 = getrunsinfo({a(3).name},'Pbeach');
    bg_3 = getrunsinfo({a(4).name},'Pbeach');
    for itime = 2:1:130, bg_3.info.dps{itime,1} = (bg_3.info.dps{itime,1}-8); end
    
    cmpbg1 = snapshots_analyses(bg_0,bg_1);
    cmpbg2 = snapshots_analyses(bg_0,bg_2);
    cmpbg3 = snapshots_analyses(bg_0,bg_3);
    
    plot([cmpbg1.L2norm{:,1}]',[cmpbg1.L2norm{:,4}]',[cmpbg2.L2norm{:,1}]',[cmpbg2.L2norm{:,4}]',[cmpbg3.L2norm{:,1}]',[cmpbg3.L2norm{:,4}]');
    legend('11 Re-Starts','1 Re-Start','1 Re-Start with Spinup');
    ylabel('L2 Norm');
    xlabel('Time (h)');
    return
  
  case 'DPxMAX'
    a(1).name = ['D:\Re-start Implications\Grid QuickIn\Dpsopt DP\Tlfsmo 60\Bg - SpUp 120',filesep];
    a(2).name = ['D:\Re-start Implications\Grid QuickIn\Dpsopt MAX\Tlfsmo 60\Bg - SpUp 120',filesep];
  case 'bg1x30NR'
    a(1).name = [basicPath,'Bg - SpUp 240',filesep];
    a(2).name = [basicPath,'Bg - Stps 30 - Replace DEP',filesep];
  
  case 'restart'
    bwc(1).name = [basicPath,'Coupling BWC\Re-Start\Bg - 960 SpUp - 000 - 2e-1',filesep];
    bwc(2).name = [basicPath,'Coupling BWC\Re-Start\Bg - Restart 480 - 720 SpUp - 000 - 2e-1 Wave in second tstep',filesep];
    b(1).name = [basicPath,'Coupling B\Re-Start\Bg - 960 SpUp - 000 - 2e-1',filesep];
    b(2).name = [basicPath,'Coupling B\Re-Start\Bg - Restart 480 - 480 SpUp - 000 - 2e-1',filesep];
  
  case 'noroller'
    b(1).name = [basicPath,'Coupling B\No Roller\Bg - 960 SpUp - 000 - 2e-1',filesep];
    b(2).name = [basicPath,'Coupling B\No Roller\Bg - ReStart 480 - 480 SpUp - 000 - 2e-1',filesep];
    bwc(1).name = [basicPath,'Coupling BWC\No Roller\Bg - 960 SpUp - 000 - 2e-1',filesep];
    bwc(2).name = [basicPath,'Coupling BWC\No Roller\Bg - ReStart 480 - 480 SpUp - 000 - 2e-1',filesep];
  
  case 'noaddon'
    bwc(1).name = [basicPath,'Coupling BWC\No AddOn\Bg - 960 SpUp - 000 - 2e-1',filesep];
    bwc(2).name = [basicPath,'Coupling BWC\No AddOn\Bg - ReStart 480 - 480 SpUp - 000 - 2e-1',filesep];
    b(1).name = [basicPath,'Coupling B\No AddOn\Bg - 960 SpUp - 000 - 2e-1',filesep];
    b(2).name = [basicPath,'Coupling B\No AddOn\Bg - ReStart 480 - 480 SpUp - 000 - 2e-1',filesep];
    
  case 'smoothingtime'
    basicPath = 'D:\Re-start Implications\Analysis Smoothing time - QI DP\';
    a(1).name = [basicPath,'Ds - SpUp 240',filesep];
    a(2).name = [basicPath,'Ds - SpUp 240 - Tlfsmo 60',filesep];
  otherwise
    error('Whatya doing?','Whatya doing?')
end

bg_bwc1  = getrunsinfo({bwc(1).name},'Pbeach',whichtimes,dplim);
bg_bwc2 = getrunsinfo({bwc(2).name},'Pbeach',whichtimes,dplim);
%bg_b1  = getrunsinfo({b(1).name},'Pbeach',whichtimes,dplim);
%bg_b2 = getrunsinfo({b(2).name},'Pbeach',whichtimes,dplim);

cmpbg_bwc = snapshots_analyses(bg_bwc1,bg_bwc2);
%cmpbg_b = snapshots_analyses(bg_b1,bg_b2);

clear bg*

figure(1); 
%subplot(1,2,1); 
plot([cmpbg_bwc.L2norm{:,1}]',[cmpbg_bwc.L2norm{:,2}]',[cmpbg_bwc.L2norm{:,1}]',[cmpbg_bwc.L2norm{:,3}]');
legend('U Velocity component','V Velocity component');
ylabel('L2 Norm (m/s)');
ylim([0,1])
xlabel('Time (h)');
title('(a) Strong Coupling');

% subplot(1,2,2);  
% plot([cmpbg_b.L2norm{:,1}]',[cmpbg_b.L2norm{:,2}]',[cmpbg_b.L2norm{:,1}]',[cmpbg_b.L2norm{:,3}]');
% legend('U Velocity component','V Velocity component');
% ylabel('L2 Norm (m/s)');
% ylim([0,1])
% xlabel('Time (h)');
% title('(b) Weak Coupling')


% ________________________________________________________________________
if flagBehavior
  disp('Analyzing Behaviors')
  tbeh_bg1 = behavior_analysis(bg_bwc_1);
  tbeh_bg2 = behavior_analysis(bg_bwc_2);
  
  figure(3)
  plot(tbeh_bg1.dps(:,1),tbeh_bg1.dps(:,2),tbeh_bg2.dps(:,1),tbeh_bg2.dps(:,2));
  legend('Background 1','Background 2');
  ylabel('L2 Norm (m)');
  xlabel('Map Saving Step');
end

% ________________________________________________________________________
if flagDiff
    figure(4)
    iplot = 1; subplot(2,5,iplot);
    surf(cmpbg_bwc.diff{iplot,2},'EdgeColor','none');
    xlim([15 60]); ylim([2 17]); caxis([-0.1 0.1]);
    title(['BWC at ',num2str(round(cmpbg_bwc.diff{iplot,1}*3600)-86400), ' s'])
    colorbar('southoutside');
    view(2);
    cont = 2;
    for iplot=2:2:18
      subplot(2,5,cont);
      surf(cmpbg_bwc.diff{iplot,2},'EdgeColor','none');
      xlim([15 60]); ylim([2 17]); caxis([-0.1 0.1]);
      title(['BWC at ',num2str(round(cmpbg_bwc.diff{iplot,1}*3600)-86400), ' s'])
      colorbar('southoutside');
      view(2);
      cont = cont+1;
    end

    figure(5)
    iplot = 1; subplot(2,5,iplot);
    surf(cmpbg_b.diff{iplot,2},'EdgeColor','none');
    xlim([15 60]); ylim([2 17]); caxis([-0.1 0.1]);
    title(['B at ',num2str(round(cmpbg_b.diff{iplot,1}*3600)-86400), ' s'])
    colorbar('southoutside');
    view(2);
    cont = 2;
    for iplot=2:2:18
      subplot(2,5,cont);
      surf(cmpbg_b.diff{iplot,2},'EdgeColor','none');
      xlim([15 60]); ylim([2 17]); caxis([-0.1 0.1]);
      title(['B at ',num2str(round(cmpbg_b.diff{iplot,1}*3600)-86400), ' s'])
      colorbar('southoutside');
      view(2);
      cont = cont+1;
    end  
end


% ________________________________________________________________________
if flagWL
  figure(6)
  iplot = 1;
  subplot(2,4,iplot);
  surf(bg_2.info.Wlvl{iplot,2});
  xlim([15 60]); ylim([0 18]);
  caxis([-0.06 0.15]);
  title(['Timestep ',num2str(iplot-1)])
  colorbar('southoutside');
  view(2);

  for iplot=2:1:8, 
    subplot(2,4,iplot);
    surf(bg_2.info.Wlvl{(iplot-1)*2,2});
    xlim([15 60]); ylim([0 18]);
    caxis([-0.06 0.15]);
    title(['Timestep ',num2str((iplot-1)*2-1)])
    colorbar('southoutside');
    view(2);
  end
end