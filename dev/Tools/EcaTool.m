%Class with a template to make new Classes
%
% @author ABR
% @author SEO
% @version
%

classdef EcaTool < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependand properties
    properties (Dependent = true, SetAccess = private)
        
    end
    
    %Private properties
    properties(SetAccess = private)
        
    end
    
    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end
    
    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end
    
    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end
    
    %Public methods
    methods
        
    end
    
    %Private methods
    methods (Access = 'private')
        
    end
    
    %Stactic methods
    methods (Static)
        
        function processEca(OPT)
            % main scrip to postprocess ECA plots
            % INPUTS:
            %   - OPT.readdata
            %   - OPT.plottimeseries
            %   - OPT.statistics
            %   - OPT.outDir   : location to save output
            %   - OPT.refmodel : location of reference data
            %   - OPT.
            % OUTPUTS:
            %   - figures and tables
            disp('----------------------------------------------');
            disp(['EcaTool for : ',OPT.name]);
            disp('----------------------------------------------');
            
            % switch off everything by default
            OPT = Util.setDefault(OPT,'visibility','on');
            OPT = Util.setDefault(OPT,'readdata',false);
            OPT = Util.setDefault(OPT,'saveresults',false);
            OPT = Util.setDefault(OPT,'bathymesh',false);
            OPT = Util.setDefault(OPT,'longitudinal',false);
            OPT = Util.setDefault(OPT,'discharge',false);
            OPT = Util.setDefault(OPT,'flowfields',false);
            OPT = Util.setDefault(OPT,'plottimeseries',false);
            OPT = Util.setDefault(OPT,'statistics',false);
            OPT = Util.setDefault(OPT,'plotstatistics',false);
            OPT = Util.setDefault(OPT,'exportVel',false);
            OPT = Util.setDefault(OPT,'flowfields',false);
            OPT = Util.setDefault(OPT,'deltafields',false);
            OPT = Util.setDefault(OPT,'salinity',false);
            OPT = Util.setDefault(OPT,'frictionfields',false);
            OPT = Util.setDefault(OPT,'talweg',false);
            OPT = Util.setDefault(OPT,'dischargeAll',false);
            
            
            if OPT.bathymesh
                display(' --- plotting bathy and mesh');
                EcaTool.plotBathyMesh(OPT)
            end
            
            if OPT.readdata || OPT.plottimeseries || OPT.statistics || ...
                    OPT.longitudinal || OPT.flowfields || OPT.plotstatistics || ...
                    OPT.salinity || OPT.exportVel || OPT.frictionfields || OPT.talweg
            
                if OPT.readdata
                    display(' --- reading timeseries data');
                    [dataset2D,varNames2D,dataset3D,varNames3D] = Telemac.readNetcdfData(OPT.obsPoints);
                    % convert all times to UTC
                    dataset2D.Time.data = dataset2D.Time.data+OPT.dT2UTC;
                    if OPT.saveresults
                        display(' --- saving timeseries data');
                        if ~isdir(fullfile(OPT.outDir,'0_Data'))
                            mkdir(fullfile(OPT.outDir,'0_Data'))
                        end
                        save(fullfile(OPT.outDir,'0_Data','timeseriesresults2D.mat'),'-struct','dataset2D');
                        save(fullfile(OPT.outDir,'0_Data','timeseriesresults3D.mat'),'-struct','dataset3D');
                    end
                    %                 sct = EcaTool.readModelData(OPT);
                else
                    display(' --- loading timeseries data');
                    dataset2D = load(fullfile(OPT.outDir,'0_Data','timeseriesresults2D.mat'));
                end
                
                if ~isempty(OPT.refmodel)
                    display(' --- loading reference timeseries data');
                    dataset2Dref = load(fullfile(OPT.refmodel,'0_Data','timeseriesresults2D.mat'));
                else
                    dataset2Dref = '';
                end
            
            end
            
            %% Post-Processing
            
            % TIMESERIES
            OPT.timeseriesVariables = {'WatLev';'VelMag';'VelDir';'Sal'};
            OPT.unitVariables = {'Waterstand [mTAW]'};
            if OPT.plottimeseries || OPT.statistics
                disp(' --- plotting timeseries data');
                EcaTool.processTimeseries(dataset2Dref,dataset2D,OPT.timeseriesVariables,OPT)
            end
            
            if OPT.statistics || OPT.plotstatistics
                EcaTool.plotStatistics(OPT);
            end
            
            if OPT.longitudinal
                disp(' --- making longitudinal plots');
                EcaTool.processLongitudinal(dataset2Dref,dataset2D,OPT);
            end
            
            % Discharge
            if OPT.discharge
                disp(' --- processing discharges');
                EcaTool.processDischarge(OPT);
            end
            
            if OPT.dischargeAll
                disp(' --- processing discharge transects');
                EcaTool.processDischargeTransect(OPT);
            end
            
            if OPT.flowfields
                disp(' --- processing flow fields');
                EcaTool.processFlowFields(dataset2D,OPT,dataset2Dref);
            end
            
            if OPT.deltafields
                disp(' --- creating delta maps');
                EcaTool.processDeltaFields(OPT,'flow');
            end
                
            
            if OPT.exportVel
                disp(' --- exporting velocities');
                EcaTool.procExportVel(OPT,dataset2D);
            end
            
            if OPT.salinity
                disp(' --- creating salinity maps');
                EcaTool.processSalinity(dataset2D,OPT)
            end
            
            if OPT.frictionfields
                disp(' --- creating bed shear stress maps');
                EcaTool.processFriction(dataset2D,OPT)
            end
            
            if OPT.talweg
                disp(' --- processing discharges');
                EcaTool.processTalweg(dataset2D,OPT);
            end
            
        end
        
        function plotBathyMesh(OPT)
            
            outD = fullfile(OPT.outDir,'3_BathyMesh');
            name = OPT.name;
            
            if ~isdir(outD)
                mkdir(outD);
            end
            
            OPT.Geometryfile = '';
            thefiles = dir(fullfile(char(OPT.strmodel),'*.slf'));
            for i=1:length(thefiles);
                k=strfind(thefiles(i).name,'Geometry');
                if ~isempty(k);
                    OPT.Geometryfile=fullfile(OPT.strmodel,thefiles(i).name);
                end
            end
            if isempty(OPT.Geometryfile);
                display('Rename Geometry file')
            end
            % Read the file
            slfTel = telheadr(OPT.Geometryfile);
            % Convert to lon/lat
            [lonTel,latTel] = convertCoordinates(slfTel.XYZ(:,1),slfTel.XYZ(:,2),'CS1.code',28992,'CS2.code',4326);
            slfTel.lonlat=[lonTel latTel];
            % Read the zooming for plotting
            [OPT.zooms,OPT.zoomnames]=xlsread(OPT.zoomadress);
            OPT.zoomnames(1,:)=[];
            % Convert lon,lat the zoomnames
            [OPT.zoomslonlat(:,1),OPT.zoomslonlat(:,3)] = convertCoordinates(OPT.zooms(:,1),OPT.zooms(:,3),'CS1.code',28992,'CS2.code',4326);
            [OPT.zoomslonlat(:,2),OPT.zoomslonlat(:,4)] = convertCoordinates(OPT.zooms(:,2),OPT.zooms(:,4),'CS1.code',28992,'CS2.code',4326);
            
            % Read the landboundary
            land = {};
            tel = 1;
            for iL = 1:numel(OPT.plotFlow.Landboundary)
                xyL=Telemac.readKenue(OPT.plotFlow.Landboundary{iL});
                for iC = 1:numel(xyL)
                     [land{tel}(:,1) land{tel}(:,2)] = convertCoordinates(xyL{iC}(:,1),xyL{iC}(:,2),'CS1.code',28992,'CS2.code',4326);
                     tel = tel+1;
                end
            end
            
            % Check in what position is the variable Bottom
            k = find(cell2mat(cellfun(@(x) ~isempty(x),strfind(slfTel.RECV,'BOTTOM  '),'UniformOutput',false)),1,'first');
            OPT.Bottompos = nan;
            if ~isempty(k)
                OPT.Bottompos = k;
            end
            
            % PLOT BATHYMETRY AND MESH
            for i=1:size(OPT.zooms,1) % Changed from length to number of rows
                f=figure('pos',[100 100 1200 800]);
                set(gcf,'Visible', OPT.visibility); 
                % Mesh
%                 triplot(double(slfTel.IKLE),double(lonTel),double(latTel),'w');
                triplot(double(slfTel.IKLE),double(lonTel),double(latTel),'color',[0.5 0.5 0.5]);
%                 xlim([OPT.zoomslonlat(i,1) OPT.zoomslonlat(i,2)]);
%                 ylim([OPT.zoomslonlat(i,3) OPT.zoomslonlat(i,4)]);
                axis([OPT.zoomslonlat(i,1) OPT.zoomslonlat(i,2) OPT.zoomslonlat(i,3) OPT.zoomslonlat(i,4)]);
                axis off
                % Googlemaps
%                 plot_google_map('maptype','satellite','scale',2);
                
                hold on
                if ~isnan(OPT.Bottompos)
%                     ax3=patch('faces',slfTel.IKLE,'vertices',slfTel.lonlat,'FaceVertexCData',slfTel.RESULT(:,OPT.Bottompos), ...
%                         'FaceColor','interp','EdgeColor','none','linewidth',0.01,'FaceAlpha',0.5);
                    ax3=patch('faces',slfTel.IKLE,'vertices',slfTel.lonlat,'FaceVertexCData',slfTel.RESULT(:,OPT.Bottompos), ...
                        'FaceColor','interp','EdgeColor','none','linewidth',0.01,'FaceAlpha',OPT.FaceAlpha);
                    c=colorbar; clim([-20 10]); c.Location='SouthOutside'; c.Ticks=[-20:2:10]; title(c,'Bodem [m TAW]');
                    c.Color=[0 0 0];
                    f.Color=[1 1 1];
                end
                hold on
                
%                 triplot(double(slfTel.IKLE),double(lonTel),double(latTel),'w');
                
                for iL = 1:numel(land)
                    plot(land{iL}(:,1),land{iL}(:,2),'-k','linewidth',1.5)
                end
                
                title([OPT.name,' - zoom in ',char(OPT.zoomnames(i))],'Color',[0 0 0]);
                set(gcf, 'PaperPositionMode', 'auto');
                
                % Save results
                %savefig([OPT.outDir,'\',char(name),'\',char(OPT.zoomnames(i)),'.fig']);
                print(gcf,[outD,'\',char(name),' - ',char(OPT.zoomnames(i))],'-dtiff','-r100');
                close all;
                
            end
 
        end
        
        function processTimeseries(refData,dataSet,varNames,OPT)
            % function to process the ECA timeseries: making plots for
            % entire timeseries, average, spring and neap and make
            % statistics for entire timeseries
            % INPUTS:
            %   - refData: reference dataset (in Telemac structure)
            %   - cellData: cell with different dataset to plot (Telemac
            %   structure)
            %   - varNames: variables to plot
            %   - OPT: options (timLim, statistics, outputdir)
            % OUTPUTS:
            %   - figures
            %   - table with statistics
            warning('off','all')
            
            outF = fullfile(OPT.outDir,'1_Timeseries');
            if ~isdir(outF)
                mkdir(outF);
            end
            
            table{1,1} = 'Station';
            table(1,2:4) = {'BIAS WL','RMSE WL','RMSE0 WL'};
            table(1,5:7) = {'BIAS VEL','RMSE VEL','RMSE0 VEL'};
            table(1,8:10) = {'BIAS DIR','RMSE DIR','RMSE0 DIR'};
            table(1,11:13) = {'BIAS SAL','RMSE SAL','RMSE0 SAL'};
            
            T_MOD = transpose(datenum(OPT.PeriodStart):10/60/24:datenum(OPT.PeriodEnd));
            
            for iS = 1:numel(dataSet.Stations.data)
                % loop over stations and loop over all timings
                figure('pos',[50 50 900 900])
                set(gcf,'Visible', OPT.visibility);
                % default values for reference plot
                vTref = nan;
                wlref = nan;
                magref = nan;
                dirref = nan;
                salref = nan;
                uref = nan;
                vref = nan;
                cLeg = {OPT.name};
                if ~isempty(refData)
                    ind = find(strcmp(dataSet.Stations.data{iS},refData.Stations.data),1,'first');
                    if ~isempty(ind)
                        vTref   = refData.Time.data;
                        wlref   = refData.WatLev.data{ind};
                        salref  = refData.Sal.data{ind};
                        uref    = refData.VelX.data{ind};
                        vref    = refData.VelY.data{ind};
                        magref  = sqrt(uref.^2+vref.^2);
                        dirref  = mod(90-atan2(vref,uref)/pi*180,360);
                        cLeg    = {OPT.name,OPT.refname,'verschil'};
                    end
                end
                h = [];
                
                
                timedata = dataSet.Time.data;
                wldata   = dataSet.WatLev.data{iS};
                saldata  = dataSet.Sal.data{iS};
                udata    = dataSet.VelX.data{iS};
                vdata    = dataSet.VelY.data{iS};
                magdata  = sqrt(udata.^2+vdata.^2);
                dirdata  = mod(90-atan2(vdata,udata)/pi*180,360);
                
%                 %%% temp
                vTref = timedata;
                wlref = nan.*wldata;
                salref = nan.*saldata;
                uref = nan.*udata;
                vref = nan.*vdata;
                magref = nan.*magdata;
                dirref = nan.*dirdata;
                cLeg = {OPT.name,'dummy ref','verschil'};
%                 %%% temp
                
                
                if ~isnan(vTref(1)) % there is data in the reference run
                    wlref_stat      = interp1(vTref,wlref,T_MOD);
                    wldata_stat     = interp1(dataSet.Time.data,wldata,T_MOD);
                    uref_stat       = interp1(vTref,uref,T_MOD);
                    vref_stat       = interp1(vTref,vref,T_MOD);
                    magref_stat     = sqrt(uref_stat.^2+vref_stat.^2);
                    dirref_stat     = mod(90-atan2(vref_stat,uref_stat)/pi*180,360);
                    udata_stat      = interp1(dataSet.Time.data,udata,T_MOD);
                    vdata_stat      = interp1(dataSet.Time.data,vdata,T_MOD);
                    magdata_stat    = sqrt(udata_stat.^2+vdata_stat.^2);
                    dirdata_stat    = mod(90-atan2(vdata_stat,udata_stat)/pi*180,360);
                    salref_stat     = interp1(vTref,salref,T_MOD);
                    saldata_stat    = interp1(dataSet.Time.data,saldata,T_MOD);
                    
                    wldiff          = wldata_stat - wlref_stat;
                    magdiff         = magdata_stat - magref_stat;
                    dirdiff         = mod(dirdata_stat - dirref_stat,360);
                    dirdiff(dirdiff>180) = 360 - dirdiff(dirdiff>180);
                    saldiff         = saldata_stat - salref_stat;
                else
                    wldiff          = nan(size(T_MOD));
                    magdiff         = nan(size(T_MOD));
                    dirdiff         = nan(size(T_MOD));
                    saldiff         = nan(size(T_MOD));
                end
                
                if OPT.statistics %&& ~isempty(refData)
                    table{iS+1,1} = dataSet.Stations.data{iS};
                    %
                    [table{iS+1,3},table{iS+1,4},table{iS+1,2},~,~] = Statistics.quickStatistics(wldata_stat,wlref_stat);
                    [table{iS+1,6},table{iS+1,7},table{iS+1,5},~,~] = Statistics.quickStatistics(magdata_stat,magref_stat);
                    [table{iS+1,12},table{iS+1,13},table{iS+1,11},~,~] = Statistics.quickStatistics(saldata_stat,salref_stat);

                    % direction
                    alpha = (dirdata_stat-dirref_stat)/180*pi;
                    table{iS+1,8} = circ_mean(alpha);
                    table{iS+1,9} = circ_std(alpha);
                    table{iS+1,10} = sqrt(table{iS+1,9}.^2-table{iS+1,8}.^2);
                end
                
                % START PLOTTING
                ax1 = subplot(4,1,1); hold on;
                %                     h(2) = plot(vTref,wlref,'-','color',[0.93 0.69 0.13],'linewidth',1);
                %                     h(1) = plot(timedata,wldata,'-','color',[0 0.45 0.74],'linewidth',1);
                %                     h(3) = plot(T_MOD,wldiff,'-k','linewidth',1);
                %                     grid on; box on;
                %                     ylim(OPT.wlLim)
                %                     ylabel('waterstand [m TAW]')
                [ax11,hL2,hL3] = plotyy(vTref,wlref,T_MOD,wldiff);
                hold on;
                hL1 = plot(ax11(1),timedata,wldata);
                set(ax11(1),'YColor','k'); set(ax11(2),'YColor','k');
                set(hL1,'color',[0 0.45 0.74],'linewidth',1);
                set(hL2,'color',[0.93 0.69 0.13],'linewidth',1);
                set(hL3,'color',[0.15 0.15 0.15],'linewidth',1,'linestyle','--');
                grid on; box on;
                ylabel(ax11(1),'waterstand [mTAW]')
                ylabel(ax11(2),'verschil [m]')
                nTmin = abs(OPT.wldiff(2)-OPT.wldiff(1));                
                nrTicks = length(OPT.wldiff);
                set(ax11(2),'ylim',[min(OPT.wldiff) max(OPT.wldiff)],'ytick',OPT.wldiff);
                vY1 = [floor(min([wlref';wldata'])/nTmin)*nTmin ceil(max([wlref';wldata'])/nTmin)*nTmin];
                nT = (vY1(2)-vY1(1))/(nrTicks-1);
                vYt = vY1(1):nT:vY1(2);
                cYt = cellfun(@(x) num2str(x,'%.2f'), num2cell(vYt), 'UniformOutput', false);
                set(ax11(1),'ylim',[vYt(1) vYt(end)],'ytick',vYt,'yticklabel',cYt);
                %                     set(ax11(1),'xlim',[],'xtick',[],'xticklabel','');
                %                     set(ax11(2),'xlim',[],'xtick',[],'xticklabel','');
                
                
                ax2 = subplot(4,1,2); hold on;
                %                     h(2) = plot(vTref,magref,'-','color',[0.93 0.69 0.13],'linewidth',1);
                %                     h(1) = plot(timedata,magdata,'-','color',[0 0.45 0.74],'linewidth',1);
                %                     grid on; box on;
                %                     ylim(OPT.velLim)
                %                     ylabel('Stroomsnelheid [m/s]')
                [ax21,hL2,hL3] = plotyy(vTref,magref,T_MOD,magdiff);
                hold on;
                hL1 = plot(ax21(1),timedata,magdata);
                set(ax21(1),'YColor','k'); set(ax21(2),'YColor','k');
                set(hL1,'color',[0.00 0.45 0.74],'linewidth',1);
                set(hL2,'color',[0.93 0.69 0.13],'linewidth',1);
                set(hL3,'color',[0.15 0.15 0.15],'linewidth',1,'linestyle','--');
                grid on; box on;
                ylabel(ax21(1),'Stroomsnelheid [m/s]')
                ylabel(ax21(2),'verschil [m/s]')
                nTmin = abs(OPT.veldiff(2)-OPT.veldiff(1));
%                 OPT.veldiff = -0.3:nTmin:0.3;
                nrTicks = length(OPT.veldiff);
                set(ax21(2),'ylim',[min(OPT.veldiff) max(OPT.veldiff)],'ytick',OPT.veldiff);
%                 vY1 = get(ax21(1),'ylim');
                vY1 = [0 max([magdata';magref'])];
                nTmin = 0.05;
                nT = ceil(((vY1(2)-vY1(1))/(nrTicks-1))/nTmin)*nTmin;
                vYt = vY1(1):nT:nT*(nrTicks-1);
                cYt = cellfun(@(x) num2str(x,'%.2f'), num2cell(vYt), 'UniformOutput', false);
                set(ax21(1),'ylim',[vYt(1) vYt(end)],'ytick',vYt,'yticklabel',cYt);
                
                ax3 = subplot(4,1,3); hold on;
                %                     h(2) = plot(vTref,dirref,'o','color',[0.93 0.69 0.13],'linewidth',1);
                %                     h(1) = plot(timedata,dirdata,'o','color',[0 0.45 0.74],'linewidth',1);
                %                     grid on; box on;
                %                     set(gca,'ylim',[OPT.dirLim(1) OPT.dirLim(end)],'ytick',OPT.dirLim)
                %                     ylabel('Stroomsnelheid [°N]')
                [ax31,hL2,hL3] = plotyy(vTref,dirref,T_MOD,dirdiff);
                hold on;
                hL1 = plot(ax31(1),timedata,dirdata);
                set(ax31(1),'YColor','k'); set(ax31(2),'YColor','k');
                set(hL1,'color',[0.00 0.45 0.74],'linewidth',1,'Linestyle','none','Marker','o');
                set(hL2,'color',[0.93 0.69 0.13],'linewidth',1,'Linestyle','none','Marker','o');
                set(hL3,'color',[0.15 0.15 0.15],'linewidth',1,'linestyle','--');
                grid on; box on;
                ylabel(ax31(1),'Stroomrichting [°N]')
                ylabel(ax31(2),'verschil [°]')
                nTmin = abs(OPT.dirdiff(2)-OPT.dirdiff(1));
%                 OPT.dirdiff = 0:nTmin:180;
                nrTicks = length(OPT.dirdiff);
                set(ax31(2),'ylim',[min(OPT.dirdiff) max(OPT.dirdiff)],'ytick',OPT.dirdiff);
                vY1 = [0 360];
                %                     nT = ceil(((vY1(2)-vY1(1))/(nrTicks-1))/0.1)*0.1;
                %                     vYt = vY1(1):nT:nT*(nrTicks-1);
                vYt = 0:90:360;
                cYt = cellfun(@(x) num2str(x,'%.0f'), num2cell(vYt), 'UniformOutput', false);
                set(ax31(1),'ylim',[vYt(1) vYt(end)],'ytick',vYt,'yticklabel',cYt);
                
                
                
                ax4 = subplot(4,1,4); hold on;
                %                     h(2) = plot(vTref,salref,'color',[0.93 0.69 0.13],'linewidth',1);
                %                     h(1) = plot(timedata,saldata,'-','color',[0 0.45 0.74],'linewidth',1);
                %                     grid on; box on;
                %                     set(gca,'ylim',[OPT.salLim(1) OPT.salLim(end)],'ytick',OPT.salLim)
                %                     ylabel('saliniteit [ppt]')
                [ax41,hL2,hL3] = plotyy(vTref,salref,T_MOD,saldiff);
                hold on;
                hL1 = plot(ax41(1),timedata,saldata);
                set(ax41(1),'YColor','k'); set(ax41(2),'YColor','k');
                set(hL1,'color',[0.00 0.45 0.74],'linewidth',1);
                set(hL2,'color',[0.93 0.69 0.13],'linewidth',1);
                set(hL3,'color',[0.15 0.15 0.15],'linewidth',1,'linestyle','--');
                grid on; box on;
                ylabel(ax41(1),'Saliniteit [ppt]')
                ylabel(ax41(2),'verschil [ppt]')
                nTmin = abs(OPT.saldiff(2)-OPT.saldiff(1));
%                 nTmin = 1;
%                 OPT.saldiff = -3:nTmin:3;
%                 OPT.saldiff = -3:nTmin:3;
                nrTicks = length(OPT.saldiff);
                set(ax41(2),'ylim',[min(OPT.saldiff) max(OPT.saldiff)],'ytick',OPT.saldiff);
                vY1 = [floor(min([salref';saldata'])/nTmin)*nTmin ceil(max([salref';saldata'])/nTmin)*nTmin];
                nT = (vY1(2)-vY1(1))/(nrTicks-1);
                vYt = vY1(1):nT:vY1(2);
                
%                 nT = ceil(((vY1(2)-vY1(1))/(nrTicks-1))/0.5)*0.5;
%                 vYt = vY1(1):nT:nT*(nrTicks-1);
                cYt = cellfun(@(x) num2str(x,'%.2f'), num2cell(vYt), 'UniformOutput', false);
                set(ax41(1),'ylim',[vYt(1) vYt(end)],'ytick',vYt,'yticklabel',cYt);
                
                h = [hL1,hL2,hL3];
                legend(h,cLeg,'orientation','horizontal','location',[0.5-0.4 0.05 0.8 0.025]);
                
                for iT = 1:size(OPT.timLim,1)
                    if OPT.plottimeseries
                        title(ax1,{['Simulatie: ',OPT.name,' - station: ',dataSet.Stations.data{iS}];...
                            [datestr(OPT.timLim{iT}(1),'dd-mm-yyyy HH:MM'),' - ',datestr(OPT.timLim{iT}(end),'dd-mm-yyyy HH:MM')]},...
                            'Interpreter','none');
                        
                        if OPT.timLim{iT}(end)-OPT.timLim{iT}(1)>2
                            sStringTicks = 'dd/mm';
                        else
                            sStringTicks = 'HH:MM';
                        end
                        
                        set(ax11(1),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],...
                            'xtick',OPT.timLim{iT},'xtickLabel',datestr(OPT.timLim{iT},sStringTicks));
                        set(ax11(2),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],'xtick',[]);
                        set(ax21(1),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],...
                            'xtick',OPT.timLim{iT},'xtickLabel',datestr(OPT.timLim{iT},sStringTicks));
                        set(ax21(2),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],'xtick',[]);
                        set(ax31(1),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],...
                            'xtick',OPT.timLim{iT},'xtickLabel',datestr(OPT.timLim{iT},sStringTicks));
                        set(ax31(2),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],'xtick',[]);
                        set(ax41(1),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],...
                            'xtick',OPT.timLim{iT},'xtickLabel',datestr(OPT.timLim{iT},sStringTicks));
                        set(ax41(2),'xlim',[OPT.timLim{iT}(1) OPT.timLim{iT}(end)],'xtick',[]);
                        
                        set(gcf, 'PaperPositionMode', 'auto');
                        sFile = fullfile(OPT.outDir,'1_Timeseries',[OPT.cPrefixes{iT},'_',dataSet.Stations.data{iS}]);
                        %                         saveas(gcf,[sFile,'.fig'],'fig');
                        print(gcf,[sFile,'.png'],'-dpng');
                    end
                    
                end
                close;

            end
            
            if OPT.statistics %&& ~isempty(refData)
                xlswrite(fullfile(OPT.outDir,'1_Timeseries','statistics.xlsx'),table);
            end
            
            warning('on','all')
            
        end
                   
        function plotStatistics(OPT)
            
                errorXls = fullfile(OPT.outDir,'1_Timeseries','statistics.xlsx');
                
                if exist(errorXls,'file')>0
                    
                    OPT.namePlot = ['Vergelijking ',OPT.name,' versus ',OPT.refname];
%                     OPT.namePlot = OPT.name;
                    
                    [num,txt,raw] = xlsread(errorXls);
                    
                    iC = 1;
                    cStations = {};
                    biasWL = [];
                    rmseWL = [];
                    rmse0WL = [];
                    biasVEL = [];
                    rmseVEL = [];
                    rmse0VEL = [];
                    biasSAL = [];
                    rmseSAL = [];
                    rmse0SAL = [];
                    for i=1:length(OPT.longPoints)
                        ind = find(strcmp(OPT.longPoints{i},txt(:,1)),1,'first');
                        if ~isempty(ind)
                            cStations{iC}   = OPT.longPoints{i};
                            biasWL(iC)      = raw{ind,2};
                            rmseWL(iC)      = raw{ind,3};
                            rmse0WL(iC)     = raw{ind,4};
                            biasVEL(iC)     = raw{ind,5};
                            rmseVEL(iC)     = raw{ind,6};
                            rmse0VEL(iC)    = raw{ind,7};
                            biasSAL(iC)     = raw{ind,11};
                            rmseSAL(iC)     = raw{ind,12};
                            rmse0SAL(iC)    = raw{ind,13};
                            iC              = iC+1;
                        end
                    end
                    vX = 1:length(cStations);
                    vX = OPT.longPointsDistance;
                    vXdist = max(vX)-min(vX);
                    vXlim = [min(vX)-1/20*vXdist max(vX)+1/20*vXdist];
                    
                    vStations = dsearchn(OPT.longPointsDistance,OPT.longPointsPlotted);
                    cStatsPlot = cell(length(vX),1);
                    cStatsPlot(vStations) = strrep(OPT.longPoints(vStations),'_',' ');
                    
                    pn=[];
                    figure;
                    set(gcf,'Visible', OPT.visibility);
                    set(gcf,'position',[50 50 800 1000]);
                    ax1 = subplot(3,1,1); hold on;
%                     plot(vX,biasWL,'-o','color',[0.93 0.69 0.13],'linewidth',1);
                    pn(1) = plot(vX,biasWL,'-o','color',[0 0.45 0.74],'linewidth',1);                    
                    pn(2) = plot(vX,rmseWL,'-x','color',[0.85 0.33 0.10],'linewidth',1);
%                     plot(vX,rmse0WL,'-s','color',[0.85 0.33 0.10],'linewidth',1);
%                     set(ax1,'xlim',[vX(1)-1 vX(end)+1],'xtick',vX,'xticklabel',strrep(cStations,'_',' '))
                    set(ax1,'xlim',vXlim,'xtick',vX,'xticklabel',cStatsPlot)
                    vYlim = get(ax1,'ylim');
% %                     set(ax1,'ylim',[min(-0.1,vYlim(1)) max(0.1,vYlim(2))]);
                    set(ax1,'ylim',[-0.1 0.1],'ytick',-0.1:0.02:0.1);
                    set(ax1,'ylim',[-0.6 0.6],'ytick',-0.6:0.1:0.6);
                    grid on; box on;
                    plot(vXlim,[0 0],'-k');
                    legend(pn,'BIAS WL','RMSE WL','location','southwest');
                    title(OPT.namePlot)
                    ylabel('Waterstand [m]')
                    pAx1 = get(gca,'position');
                    set(gca,'position',[pAx1(1) pAx1(2)+0.03 pAx1(3) pAx1(4)-0.03]);
                    rotateticklabel(ax1,45);
                    
                    pn=[];
                    ax2 = subplot(3,1,2); hold on;
                    pn(1) = plot(vX,biasVEL,'-o','color',[0 0.45 0.74],'linewidth',1);
%                     plot(vX,rmseVEL,'-x','color',[0 0.45 0.74],'linewidth',1);
%                     plot(vX,rmse0VEL,'-s','color',[0.85 0.33 0.10],'linewidth',1);
%                     set(ax2,'xlim',[vX(1)-1 vX(end)+1],'xtick',vX,'xticklabel',strrep(cStations,'_',' '))
                    set(ax2,'xlim',vXlim,'xtick',vX,'xticklabel',cStatsPlot)
                    vYlim = get(ax2,'ylim');
                    set(ax2,'ylim',[-0.5 0.5],'ytick',-0.5:0.1:0.5);
                    grid on; box on;
                    plot(vXlim,[0 0],'-k');
                    legend(pn,'BIAS VEL','location','northwest');
                    ylabel('Magnitude stroomsnelheid [m/s]')
                    pAx2 = get(gca,'position');
                    set(gca,'position',[pAx2(1) pAx2(2)+0.03 pAx2(3) pAx2(4)-0.03]);
                    rotateticklabel(ax2,45);

                    pn = [];
                    ax3 = subplot(3,1,3); hold on;
                    pn(1) = plot(vX,biasSAL,'-o','color',[0 0.45 0.74],'linewidth',1);
%                     plot(vX,rmseSAL,'-x','color',[0 0.45 0.74],'linewidth',1);
%                     plot(vX,rmse0SAL,'-s','color',[0.85 0.33 0.10],'linewidth',1);
%                     set(ax2,'xlim',[vX(1)-1 vX(end)+1],'xtick',vX,'xticklabel',strrep(cStations,'_',' '))
                    set(ax3,'xlim',vXlim,'xtick',vX,'xticklabel',cStatsPlot)
                    vYlim = get(ax3,'ylim');
                    set(ax3,'ylim',[-3 3],'ytick',-3:0.5:3);
%                     ylim([0 33])
                    grid on; box on;
                    plot(vXlim,[0 0],'-k');
                    legend(pn,'BIAS SAL','location','northwest');
                    ylabel('Saliniteit [ppt]');
%                     ylabel({'Gemiddelde Saliniteit';'[ppt]'})
                    pAx3 = get(gca,'position');
                    set(gca,'position',[pAx3(1) pAx3(2)+0.03 pAx3(3) pAx3(4)-0.03]);  
                    rotateticklabel(ax3,45);

                    set(gcf, 'PaperPositionMode', 'auto');
                    sFile = strrep(errorXls,'.xlsx','_WL_VL_SL_longplot.png');
                    print(gcf,sFile,'-dpng');
%                     saveas(gcf,strrep(sFile,'png','fig'),'fig');
                    close;
                    
                end
                
        end
   
        function processLongitudinal(dataset2Dref,dataset2D,OPT)
            % function to make longitudinal plots
            % requires some calculations and then a longitudinal plot
            refModel = true;
            if isempty(dataset2Dref)
%                 error('function not implemented to plot without a reference')
                refModel = false;
            end
            
            if ~isdir(fullfile(OPT.outDir,'2_Longitudinal'))
                mkdir(fullfile(OPT.outDir,'2_Longitudinal'))
            end

            %OPT.directionsObs = 'k:\PROJECTS\11\11498_P009392 - Vaarwegbeheer 2016-2021\11498-005 - sMER ECA\07-Uitv\ModelPostProcessing\Stations\Observatiepunten_v2.mat';
            dataDir = load(OPT.directionsObs);
            
            % link the stations
            iCount      = 1;
            cStations   = {};
            indDataSet  = [];
            indRefSet   = [];
            vEbDir      = [];
            for iP=1:length(OPT.longPoints)
                tempData = find(strcmp(OPT.longPoints{iP},dataset2D.Stations.data),1,'first');
                if refModel
                    tempRef = find(strcmp(OPT.longPoints{iP},dataset2Dref.Stations.data),1,'first');
                else
                    tempRef = [];
                end
                if ~isempty(tempData)% && ~isempty(tempRef)
                    
                    indDataSet(iCount)  = tempData;
                    %indRefSet(iCount)   = tempRef;
                    cStations{iCount}   = OPT.longPoints{iP};
                    % search point closest to the ones for which directions
                    % are available                    
                    dist = sqrt((dataset2D.X.data(tempData)-dataDir.obsTable(:,1)).^2+...
                        (dataset2D.Y.data(tempData)-dataDir.obsTable(:,2)).^2);
                    [minDist,indexMin] = min(dist);
                    if minDist>10
                        warning([OPT.longPoints{iP} ': closest point for eb directions is more than 10m away']);
                    end
                    vEbDir(iCount)    = dataDir.obsTable(indexMin,3);
                    % direction in radians
                    
                else
                    indDataSet(iCount)  = nan;
                    %indRefSet(iCount)   = nan;
                    cStations{iCount}   = '';
                    vEbDir(iCount)    = nan;
                    
                end
                if ~isempty(tempRef)
                    indRefSet(iCount)   = tempRef;
                else
                    indRefSet(iCount)   = nan;
                end
                iCount              = iCount + 1;
            end
%             vX = 1:numel(cStations);
            vX = OPT.longPointsDistance;
            vXdist = max(vX)-min(vX);
            vXlim = [min(vX)-1/20*vXdist max(vX)+1/20*vXdist];
            vStations = dsearchn(OPT.longPointsDistance,OPT.longPointsPlotted);
            cStatsPlot = cell(length(vX),1);
            cStatsPlot(vStations) = strrep(OPT.longPoints(vStations),'_',' ');
            
            % calculate required plot variables for the requested
            % longitudinal observation points.
            
            % preallocate
            dataSetMinSal   = nan(numel(cStations),3); % 3 columns for three tides
            dataSetMaxSal   = nan(numel(cStations),3);
            dataSetMeanSal  = nan(numel(cStations),3);
            refSetMinSal    = nan(numel(cStations),3); % 3 columns for three tides
            refSetMaxSal    = nan(numel(cStations),3);
            refSetMeanSal   = nan(numel(cStations),3);
            dataSetHW       = nan(numel(cStations),3); % 3 columns for three tides
            dataSetLW       = nan(numel(cStations),3);
            statHW          = nan(numel(cStations),3); % stat gives 3 columns (BIAS, RMSE, RMSE0 for entire period)
            statLW          = nan(numel(cStations),3); % stat gives 3 columns (BIAS, RMSE, RMSE0 for entire period)
            timeSetHW       = nan(numel(cStations),3);
            refSetHW        = nan(numel(cStations),3);
            refSetLW        = nan(numel(cStations),3);
            timeRefHW       = nan(numel(cStations),3);
            dataSetA        = nan(numel(cStations),3);
            refSetA         = nan(numel(cStations),3);
            dataSetAmp      = nan(numel(cStations),3);
            refSetAmp       = nan(numel(cStations),3);
            dataSetVlT      = nan(numel(cStations),3);
            refSetVlT       = nan(numel(cStations),3);
            dataSetEbT      = nan(numel(cStations),3);
            refSetEbT       = nan(numel(cStations),3);
            dataSetMaxVl    = nan(numel(cStations),3);
            refSetMaxVl     = nan(numel(cStations),3);            
            dataSetMaxEb    = nan(numel(cStations),3);
            refSetMaxEb     = nan(numel(cStations),3);                        
            
            % take 9 hour periods
            dt = (dataset2D.Time.data(2)-dataset2D.Time.data(1));
            periodData = 9/( dt * 24);
            if refModel
                dtref = (dataset2Dref.Time.data(2)-dataset2Dref.Time.data(1));
                periodRef = 9/( dtref * 24);
            end

            sctOption.method = 'peakdet';
            sctOption.threshold = 0.6;
            % search for the high and low waters in each station
            for iC = 1:numel(cStations)
                
                ind = indDataSet(iC);
                if ~isnan(ind)
                    [indexHighData,indexLowData]            = TidalAnalysis.calcHwLw(dataset2D.WatLev.data{ind},periodData,sctOption);
                    vTHWdata = dataset2D.Time.data(indexHighData);
                    HWdata = dataset2D.WatLev.data{ind}(indexHighData);
                    vTLWdata = dataset2D.Time.data(indexLowData);
                    LWdata = dataset2D.WatLev.data{ind}(indexLowData);
                    [dataSetHW(iC,1),dataSetLW(iC,1),iHW,iLW] = EcaTool.lookupHwLwTide(datenum(OPT.HWmean),dataset2D.Time.data,indexHighData,indexLowData,dataset2D.WatLev.data{ind});
                    timeSetHW(iC,1)                         = indexHighData(iHW);
                    % salinity
                    [indTide,~,~] = EcaTool.lookupTideIndices(dataset2D.Time.data,indexLowData,indexHighData(iHW));
                    %                 iLw1        = find(dataset2D.Time.data(indexLowData)<dataset2D.Time.data(indexHighData(iHw)),1,'last');
                    %                 iLw2        = find(dataset2D.Time.data(indexLowData)>dataset2D.Time.data(indexHighData(iHw)),1,'first');
                    %                 indTide     = find(dataset2D.Time.data(indexLowData(iLw1))<=dataset2D.Time.data & dataset2D.Time.data<=dataset2D.Time.data(indexLowData(iLw2)));
                    dataSetMinSal(iC,1) = min(dataset2D.Sal.data{ind}(indTide));
                    dataSetMaxSal(iC,1) = max(dataset2D.Sal.data{ind}(indTide));
                    dataSetMeanSal(iC,1) = mean(dataset2D.Sal.data{ind}(indTide));
                    [dataSetHW(iC,2),dataSetLW(iC,2),iHW,iLW] = EcaTool.lookupHwLwTide(datenum(OPT.HWspring),dataset2D.Time.data,indexHighData,indexLowData,dataset2D.WatLev.data{ind});
                    timeSetHW(iC,2)                         = indexHighData(iHW);
                    [indTide,~,~] = EcaTool.lookupTideIndices(dataset2D.Time.data,indexLowData,indexHighData(iHW));
                    dataSetMinSal(iC,2) = min(dataset2D.Sal.data{ind}(indTide));
                    dataSetMaxSal(iC,2) = max(dataset2D.Sal.data{ind}(indTide));
                    dataSetMeanSal(iC,2) = mean(dataset2D.Sal.data{ind}(indTide));
                    [dataSetHW(iC,3),dataSetLW(iC,3),iHW,iLW] = EcaTool.lookupHwLwTide(datenum(OPT.HWneap),dataset2D.Time.data,indexHighData,indexLowData,dataset2D.WatLev.data{ind});
                    timeSetHW(iC,3)                         = indexHighData(iHW);
                    [indTide,~,~] = EcaTool.lookupTideIndices(dataset2D.Time.data,indexLowData,indexHighData(iHW));
                    dataSetMinSal(iC,3) = min(dataset2D.Sal.data{ind}(indTide));
                    dataSetMaxSal(iC,3) = max(dataset2D.Sal.data{ind}(indTide));
                    dataSetMeanSal(iC,3) = mean(dataset2D.Sal.data{ind}(indTide));
                    
                    % Check if required
                    if refModel
                        ind = indRefSet(iC);
                        [indexHighRef,indexLowRef]              = TidalAnalysis.calcHwLw(dataset2Dref.WatLev.data{ind},periodRef,sctOption);
                        vTHWref = dataset2Dref.Time.data(indexHighRef);
                        HWref = dataset2Dref.WatLev.data{ind}(indexHighRef);
                        vTLWref = dataset2Dref.Time.data(indexLowRef);
                        LWref = dataset2Dref.WatLev.data{ind}(indexLowRef);
                        [refSetHW(iC,1),refSetLW(iC,1),iHW,iLW]   = EcaTool.lookupHwLwTide(datenum(OPT.HWmean),dataset2Dref.Time.data,indexHighRef,indexLowRef,dataset2Dref.WatLev.data{ind});
                        timeRefHW(iC,1)                         = indexHighRef(iHW);
                        [indTide,~,~] = EcaTool.lookupTideIndices(dataset2Dref.Time.data,indexLowRef,indexHighRef(iHW));
                        refSetMinSal(iC,1) = min(dataset2Dref.Sal.data{ind}(indTide));
                        refSetMaxSal(iC,1) = max(dataset2Dref.Sal.data{ind}(indTide));
                        refSetMeanSal(iC,1) = mean(dataset2Dref.Sal.data{ind}(indTide));
                        [refSetHW(iC,2),refSetLW(iC,2),iHW,iLW]   = EcaTool.lookupHwLwTide(datenum(OPT.HWspring),dataset2Dref.Time.data,indexHighRef,indexLowRef,dataset2Dref.WatLev.data{ind});
                        timeRefHW(iC,2)                         = indexHighRef(iHW);
                        [indTide,~,~] = EcaTool.lookupTideIndices(dataset2Dref.Time.data,indexLowRef,indexHighRef(iHW));
                        refSetMinSal(iC,2) = min(dataset2Dref.Sal.data{ind}(indTide));
                        refSetMaxSal(iC,2) = max(dataset2Dref.Sal.data{ind}(indTide));
                        refSetMeanSal(iC,2) = mean(dataset2Dref.Sal.data{ind}(indTide));
                        [refSetHW(iC,3),refSetLW(iC,3),iHW,iLW]   = EcaTool.lookupHwLwTide(datenum(OPT.HWneap),dataset2Dref.Time.data,indexHighRef,indexLowRef,dataset2Dref.WatLev.data{ind});
                        timeRefHW(iC,3)                         = indexHighRef(iHW);
                        [indTide,~,~] = EcaTool.lookupTideIndices(dataset2Dref.Time.data,indexLowRef,indexHighRef(iHW));
                        refSetMinSal(iC,3) = min(dataset2Dref.Sal.data{ind}(indTide));
                        refSetMaxSal(iC,3) = max(dataset2Dref.Sal.data{ind}(indTide));
                        refSetMeanSal(iC,3) = mean(dataset2Dref.Sal.data{ind}(indTide));
                    else
                        vTHWref = vTHWdata;
                        HWref = nan(size(HWdata));
                        vTLWref = vTLWdata;
                        LWref = nan(size(LWdata));
                        refSetHW(iC,:) = nan(1,3);
                        refSetLW(iC,:) = nan(1,3);
                        refSetMinSal(iC,:) = nan(1,3);
                        refSetMaxSal(iC,:) = nan(1,3);
                        refSetMeanSal(iC,:) = nan(1,3);
                    end
                        
                        % make statistics for entire HW, LW serie between simuation
                        % and reference
                        % check if same HW and LW periods
                        % [table{iS+1,3},table{iS+1,4},table{iS+1,2},~,~] = Statistics.quickStatistics(wlref_stat,wldata_stat);
                        
                        
                        
                        ind = dsearchn(vTHWdata,vTHWref); % looking for the indexes in data that match with all reference points
                        dt = abs(vTHWdata(ind) - vTHWref);
                        % remove all points that have a shift of more than 3 hrs
                        % (arbitrary choice)
                        HWdata = HWdata(ind);
                        indRemove = dt>1/24;
                        HWdata(indRemove) = [];
                        HWref(indRemove) = [];
                        
                        ind = dsearchn(vTLWdata,vTLWref); % looking for the indexes in data that match with all reference points
                        dt = abs(vTLWdata(ind) - vTLWref);
                        % remove all points that have a shift of more than 3 hrs
                        % (arbitrary choice)
                        LWdata = LWdata(ind);
                        indRemove = dt>1/24;
                        LWdata(indRemove) = [];
                        LWref(indRemove) = [];
                        
                        % warning for outliers
                        diffs = HWdata-HWref;
                        diffNorm = abs(diffs-mean(diffs))/std(diffs);
                        if any(diffNorm>10)
                            disp(['HW Outlier in ',cStations{iC}]);
                        end
                        diffs = LWdata-LWref;
                        diffNorm = abs(diffs-mean(diffs))/std(diffs);
                        if any(diffNorm>10)
                            disp(['LW Outlier in ',cStations{iC}]);
                        end
                        
                        % refernece should be second argument (first arg - second arg)
                        % Delete the first one, in order to prevent effects of
                        % initial conditions
                        [statHW(iC,2),statHW(iC,3),statHW(iC,1),~,~] = Statistics.quickStatistics(HWdata(2:end),HWref(2:end));
                        [statLW(iC,2),statLW(iC,3),statLW(iC,1),~,~] = Statistics.quickStatistics(LWdata(2:end),LWref(2:end));
                    
                end

            end
            
            % write to excel
            table = {};
            table(3:numel(cStations)+2,:) = transpose(cStations);
            table{1,2} = 'HW';
            table(2,2:4) = {'BIAS','RMSE','RMSE0'};
            table{1,5} = 'LW';
            table(2,5:7) = {'BIAS','RMSE','RMSE0'};
            table{1,8} = 'HW/LW-mean';
            table{1,12} = 'HW/LW-spring';
            table{1,16} = 'HW/LW-neap';
            table(2,8:2:18) = cellstr(repmat(OPT.refname,6,1));
            table(2,9:2:19) = cellstr(repmat(OPT.name,6,1));
            table(3:numel(cStations)+2,2:4) = num2cell(statHW);
            table(3:numel(cStations)+2,5:7) = num2cell(statLW);
            table(3:numel(cStations)+2,[8:4:16]) = num2cell(refSetHW);
            table(3:numel(cStations)+2,[10:4:18]) = num2cell(refSetLW);
            table(3:numel(cStations)+2,[9:4:17]) = num2cell(dataSetHW);
            table(3:numel(cStations)+2,[11:4:19]) = num2cell(dataSetLW);            
            xlswrite(fullfile(OPT.outDir,'2_Longitudinal','statistics.xlsx'),table);

            if refModel
            figure;
            set(gcf,'Visible', OPT.visibility);
            set(gcf,'position',[50 50 800 670]);
            ax1 = subplot(2,1,1); hold on;
            plot(vX,statHW(:,1),'-o','color',[0 0.45 0.74],'linewidth',1);
            %             plot(vX,statHW(:,1),'-o','color',[0.93 0.69 0.13],'linewidth',1);
%             plot(vX,statHW(:,2),'-x','color',[0 0.45 0.74],'linewidth',1);
%             plot(vX,statHW(:,3),'-s','color',[0.85 0.33 0.10],'linewidth',1);
%             set(ax1,'xlim',[vX(1)-1 vX(end)+1],'xtick',vX,'xticklabel',strrep(cStations,'_',' '))
            set(ax1,'xlim',vXlim,'xtick',vX,'xticklabel',cStatsPlot)
            vYlim = get(ax1,'ylim');
%             set(ax1,'ylim',[min(-0.1,vYlim(1)) max(0.1,vYlim(2))]);
            set(ax1,'ylim',[-0.1 0.1],'ytick',-0.1:0.02:0.1);
            rotateticklabel(ax1,45);
            grid on; box on;
%             legend('BIAS HW','location','northeastoutside');
            plot([vX(1)-1 vX(end)+1],[0 0],'-k');
            title({'Vergelijking HW en LW langsheen estuarium';[OPT.name ' versus ' OPT.refname]});
            ylabel('BIAS in HW [m]')
            pAx1 = get(gca,'position');
            set(gca,'position',[pAx1(1) pAx1(2)+0.05 pAx1(3) pAx1(4)-0.05]);
            vYt = get(gca,'ytick');
%             % min tick of 0.1
%             dY = (vYt(2)-vYt(1));
%             if dY>0.1
%                 dY=0.1;
%                 set(gca,'ytick',vYt(1):dY:vYt(end));
%             end
                    
            ax2 = subplot(2,1,2); hold on;
            plot(vX,statLW(:,1),'-o','color',[0 0.45 0.74],'linewidth',1);
            %             plot(vX,statLW(:,1),'-o','color',[0.93 0.69 0.13],'linewidth',1);
%             plot(vX,statLW(:,2),'-x','color',[0 0.45 0.74],'linewidth',1);
%             plot(vX,statLW(:,3),'-s','color',[0.85 0.33 0.10],'linewidth',1);
            set(ax2,'xlim',vXlim,'xtick',vX,'xticklabel',cStatsPlot)
%             set(ax2,'xlim',[vX(1)-1 vX(end)+1],'xtick',vX,'xticklabel',strrep(cStations,'_',' '))
            vYlim = get(ax2,'ylim');
%             set(ax2,'ylim',[min(-0.1,vYlim(1)) max(0.1,vYlim(2))]);
            set(ax2,'ylim',[-0.1 0.1],'ytick',-0.1:0.02:0.1);
            rotateticklabel(ax2,45);
            grid on; box on;
%             legend('BIAS LW','RMSE LW','RMSE0 LW','location','northeastoutside');
            plot([vX(1)-1 vX(end)+1],[0 0],'-k');
           ylabel('BIAS in LW [m]')
            pAx2 = get(gca,'position');
            set(gca,'position',[pAx2(1) pAx2(2)+0.05 pAx2(3) pAx2(4)-0.05]);
            % min tick of 0.1
%             dY = (vYt(2)-vYt(1));
%             if dY>0.1
%                 dY=0.1;
%                 set(gca,'ytick',vYt(1):dY:vYt(end));
%             end
            
            set(gcf, 'PaperPositionMode', 'auto');
            sFile = fullfile(OPT.outDir,'2_Longitudinal','Statistics_HW_LW.png'); 
            print(gcf,sFile,'-dpng');
            close;
            end

            hFig = figure; hold on;
            set(hFig,'Visible', OPT.visibility); 
            OPT.plotLongitudinal.Position = [50 50 900 600];
            OPT.plotLongitudinal = EcaTool.figureLayout(hFig,OPT.plotLongitudinal);
%             OPT.plotLongitudinal.XLim = [vX(1)-1 vX(end)+1];
            OPT.plotLongitudinal.XLim = vXlim;
            OPT.plotLongitudinal.XTick = vX;
            OPT.plotLongitudinal.YLim = [OPT.salLim(1) OPT.salLim(end)];
            OPT.plotLongitudinal.YTick = OPT.salLim;
            OPT.plotLongitudinal.YLabel = 'saliniteit [ppt]';
            
            for iL=1:3
                h = nan(6,1);
                hold on;
                h(2) = plot(vX,refSetMinSal(:,iL),'-o','color',[0.93 0.69 0.13],'linewidth',1);
                h(4) = plot(vX,refSetMeanSal(:,iL),'--o','color',[0.93 0.69 0.13],'linewidth',1);
                h(6) = plot(vX,refSetMaxSal(:,iL),'-.o','color',[0.93 0.69 0.13],'linewidth',1);
                h(1) = plot(vX,dataSetMinSal(:,iL),'-o','color',[0 0.45 0.74],'linewidth',1);
                h(3) = plot(vX,dataSetMeanSal(:,iL),'--o','color',[0 0.45 0.74],'linewidth',1);
                h(5) = plot(vX,dataSetMaxSal(:,iL),'-.o','color',[0 0.45 0.74],'linewidth',1);
                EcaTool.axisLayout(gca,OPT.plotLongitudinal);
%                 EcaTool.rotatedAxisTicks(gca,strrep(cStations,'_',' '),45);
                EcaTool.rotatedAxisTicks(gca,cStatsPlot,45);
                if refModel
                    legend(h,{'Min sal data','Min sal ref','Gem sal data','Gem sal ref','Max sal data','Max sal ref'},'location','northeastoutside');
                    title({'Variatie saliniteit langsheen estuarium';[OPT.name ' versus ' OPT.refname]});
                else
                    legend(h([1,3,5]),{'Min sal','Gem sal','Max sal'},'location','northeastoutside');
                    title({'Variatie saliniteit langsheen estuarium';OPT.name});
                end
                
                sFile = fullfile(OPT.outDir,'2_Longitudinal',['Saliniteit_series_',OPT.cPrefixes{iL+1},'.png']);
                print(gcf,sFile,'-dpng');
                clf;
            end
            close;             
            
            
            % plot HW and LW
            hFig = figure; hold on;
            set(hFig,'Visible', OPT.visibility); 
            OPT.plotLongitudinal.Position = [50 50 900 600];
            OPT.plotLongitudinal = EcaTool.figureLayout(hFig,OPT.plotLongitudinal);
            OPT.plotLongitudinal.XLim = vXlim;
            OPT.plotLongitudinal.XTick = vX;
%             OPT.plotLongitudinal.XTickLabel = strrep(cStations,'_',' ');
            OPT.plotLongitudinal.YLim = [OPT.wlLim(1) OPT.wlLim(end)];
            OPT.plotLongitudinal.YTick = OPT.wlLim;
            OPT.plotLongitudinal.YLabel = 'waterstand [m TAW]';
            
            for iL=1:3
                h = nan(4,1);
                hold on;
                h(2) = plot(vX,refSetHW(:,iL),'-o','color',[0.93 0.69 0.13],'linewidth',1);
                h(4) = plot(vX,refSetLW(:,iL),'--o','color',[0.93 0.69 0.13],'linewidth',1);
                h(1) = plot(vX,dataSetHW(:,iL),'-o','color',[0 0.45 0.74],'linewidth',1);
                h(3) = plot(vX,dataSetLW(:,iL),'--o','color',[0 0.45 0.74],'linewidth',1);
                EcaTool.axisLayout(gca,OPT.plotLongitudinal);
%                 EcaTool.rotatedAxisTicks(gca,strrep(cStations,'_',' '),45);
                EcaTool.rotatedAxisTicks(gca,cStatsPlot,45);
                if refModel
                    legend(h,{'HW data','HW ref','LW data','LW ref'},'location','northeastoutside');
                    title({'Variatie HW en LW langsheen estuarium';[OPT.name ' versus ' OPT.refname]});
                else
                    legend(h([1,3]),{'HW','LW'},'location','northeastoutside');
                    title({'Variatie HW en LW langsheen estuarium';OPT.name});
                end
                sFile = fullfile(OPT.outDir,'2_Longitudinal',['HW_LW_series_',OPT.cPrefixes{iL+1},'.png']);
                print(gcf,sFile,'-dpng');
                clf;
            end
            close;
                        
            dataSetA    = dataSetHW - dataSetLW;
            refSetA     = refSetHW - refSetLW;            
            indData = find(strcmp(OPT.refPointAmplification,cStations),1,'first');
            if ~isempty(indData)
                dataSetAmp(:,1) = dataSetA(:,1)./dataSetA(indData,1);
                dataSetAmp(:,2) = dataSetA(:,2)./dataSetA(indData,2);
                dataSetAmp(:,3) = dataSetA(:,3)./dataSetA(indData,3);
            end
            indRef = find(strcmp(OPT.refPointAmplification,cStations),1,'first');
            if ~isempty(indRef)
                refSetAmp(:,1) = refSetA(:,1)./refSetA(indRef,1);
                refSetAmp(:,2) = refSetA(:,2)./refSetA(indRef,2);
                refSetAmp(:,3) = refSetA(:,3)./refSetA(indRef,3);
            end
            
            % plot amplitude and amplification
            for iL=1:3
                %h = nan(4,1);
                hFig = figure; hold on;
                set(gcf,'Visible', OPT.visibility);
                set(gcf,'position',[50 50 900 600]);  
                
                [hAx,hLine1,hLine2] = plotyy(vX,refSetA(:,iL),vX,refSetAmp(:,iL));
                [gAx,hLine3,hLine4] = plotyy(vX,dataSetA(:,iL),vX,dataSetAmp(:,iL));
                
                if refModel
                    title({['Variatie Ampitude en Amplificatie (referentie: ',OPT.refPointAmplification,') langsheen estuarium'];...
                        [OPT.name ' versus ' OPT.refname]});
                else
                    title({['Variatie Ampitude en Amplificatie (referentie: ',OPT.refPointAmplification,') langsheen estuarium'];...
                        OPT.name});
                end

                set(hLine1,'LineStyle','-','color',[0.93 0.69 0.13],'linewidth',1,'Marker','o');
                set(hLine2,'LineStyle','--','color',[0.93 0.69 0.13],'linewidth',1,'Marker','o');
                set(hLine3,'LineStyle','-','color',[0 0.45 0.74],'linewidth',1,'Marker','o');
                set(hLine4,'LineStyle','--','color',[0 0.45 0.74],'linewidth',1,'Marker','o');
                
                ylabel(hAx(1),'Amplitude [m]','color','k') % left y-axis
                ylabel(hAx(2),'Ampificatie [-]','color','k') % right y-axis
                set(hAx(1),'YColor',[0 0 0],'ylim',[0 7],'ytick',0:7);
                set(hAx(2),'YColor',[0 0 0],'ylim',[0.25 2],'ytick',0.25:0.25:2);
                set(gAx(1),'ylim',[0 7],'ytick',0:7);
                set(gAx(2),'ylim',[0.25 2],'ytick',0.25:0.25:2);                
                
%                 set(hAx(1),'xlim',[vX(1)-1 vX(end)+1],'xtick',[]);
%                 set(hAx(2),'xlim',[vX(1)-1 vX(end)+1],'xtick',[]);
%                 set(gAx(1),'xlim',[vX(1)-1 vX(end)+1],'xtick',vX,'xticklabel',strrep(cStations,'_',' '));
%                 set(gAx(2),'xlim',[vX(1)-1 vX(end)+1],'xtick',[]);
                set(hAx(1),'xlim',vXlim,'xtick',[]);
                set(hAx(2),'xlim',vXlim,'xtick',[]);
                set(gAx(1),'xlim',vXlim,'xtick',vX,'xticklabel',cStatsPlot);
                set(gAx(2),'xlim',vXlim,'xtick',[]);


                if refModel
                    legend(hAx(1),[hLine3,hLine1],{'Amplitude data','Amplitude ref'},'location','northwest');
                    legend(hAx(2),[hLine4,hLine2],{'Amplificatie data','Amplificatie ref'},'location','northeast');
                else
                    legend(hAx(1),hLine3,{'Amplitude'},'location','northwest');
                    legend(hAx(2),hLine4,{'Amplificatie'},'location','northeast');
                end

                grid on;
                box on;
                
                vAxPos = get(hAx(1),'position');
                set(hAx(1),'position',[vAxPos(1) vAxPos(2)*3 vAxPos(3) vAxPos(4)-vAxPos(2)*2]);
                set(hAx(2),'position',[vAxPos(1) vAxPos(2)*3 vAxPos(3) vAxPos(4)-vAxPos(2)*2]);
                set(gAx(1),'position',[vAxPos(1) vAxPos(2)*3 vAxPos(3) vAxPos(4)-vAxPos(2)*2]);
                set(gAx(2),'position',[vAxPos(1) vAxPos(2)*3 vAxPos(3) vAxPos(4)-vAxPos(2)*2]);                
                rotateticklabel(gAx(1),45);
                set(gcf, 'PaperPositionMode', 'auto');
                sFile = fullfile(OPT.outDir,'2_Longitudinal',['Amplitude_series_',OPT.cPrefixes{iL+1},'.png']);
                print(gcf,sFile,'-dpng');
                close;
            end

            % look for maximum eb and flood tide
%             dataset2D = 
% 
%      Stations: [1x1 struct]
%             X: [1x1 struct]
%             Y: [1x1 struct]
%          Time: [1x1 struct]
%          VelX: [1x1 struct]
%          VelY: [1x1 struct]
%         Depth: [1x1 struct]
%        WatLev: [1x1 struct]
%     VelXbot50: [1x1 struct]
%     VelYbot50: [1x1 struct]
%     VelXtop50: [1x1 struct]
%     VelYtop50: [1x1 struct]
%           Sal: [1x1 struct]

            %%
            for iC = 1:numel(cStations)
                %
                indSet = indDataSet(iC);
                if ~isnan(indSet)
                    velSet = sqrt(dataset2D.VelX.data{indSet}.^2 + dataset2D.VelY.data{indSet}.^2);
                    if refModel
                        indRef = indRefSet(iC);
                        velRef = sqrt(dataset2Dref.VelX.data{indRef}.^2 + dataset2Dref.VelY.data{indRef}.^2);
                    else
                        indRef = [];
                        velRef = nan(size(velSet));
                    end
                    nRot = vEbDir(iC);
                    if ~isnan(nRot)
                        [~,vUit] = Calculate.rotateVector(dataset2D.VelX.data{indSet},dataset2D.VelY.data{indSet},-nRot,'radians');
                        %                 [vUit,uUit] = Calculate.projectVector(dataset2D.VelX.data{ind},dataset2D.VelY.data{ind},[0;1],[0;tan(indEbdir(iC))]);
                        if size(vUit,1)==1
                            velTide = sign(vUit).*velSet;
                        else
                            velTide = sign(transpose(vUit)).*velSet;
                        end
                        if refModel
                            [~,vUit] = Calculate.rotateVector(dataset2Dref.VelX.data{indRef},dataset2Dref.VelY.data{indRef},-nRot,'radians');
                            %velTideRef = sign(transpose(vUit)).*velRef;
                            if size(vUit,1)==1
                                velTideRef = sign(vUit).*velRef;
                            else
                                velTideRef = sign(transpose(vUit)).*velRef;
                            end
                        else
                            velTideRef = nan(size(velTide));
                        end
                        for iL=1:3
                            % look for maximum eb and maximum flood
                            [dataSetMaxVl(iC,iL),startVl,stopVl,dataSetMaxEb(iC,iL),startEb,stopEb] = ...
                                EcaTool.analyse_TidalVelocities(dataset2D.Time.data,velTide,timeSetHW(iC,iL));
                            dataSetVlT(iC,iL) = (stopVl-startVl)*24*60;
                            dataSetEbT(iC,iL) = (stopEb-startEb)*24*60;
                            if refModel
                                [refSetMaxVl(iC,iL),startVl,stopVl,refSetMaxEb(iC,iL),startEb,stopEb] = ...
                                    EcaTool.analyse_TidalVelocities(dataset2Dref.Time.data,velTideRef,timeRefHW(iC,iL));
                                refSetVlT(iC,iL) = (stopVl-startVl)*24*60;
                                refSetEbT(iC,iL) = (stopEb-startEb)*24*60;
                            end
                        end
                    end
                end
            end
            %%
            % make plot for max velocities and for tijsduur
            hFig = figure; hold on;
            set(hFig,'Visible', OPT.visibility); 
            OPT.plotLongitudinal.Position = [50 50 900 600];
            OPT.plotLongitudinal = EcaTool.figureLayout(hFig,OPT.plotLongitudinal);
            OPT.plotLongitudinal.XLim = vXlim;
            OPT.plotLongitudinal.XTick = vX;
%             OPT.plotLongitudinal.XTickLabel = strrep(cStations,'_',' ');
            OPT.plotLongitudinal.YLim = [OPT.velLim(1) OPT.velLim(end)];
            OPT.plotLongitudinal.YTick = OPT.velLim;
            OPT.plotLongitudinal.YLabel = 'stroomsnelheid [m/s]';
            
            for iL=1:3
                h = nan(4,1);
                hold on;
                h(2) = plot(vX,abs(refSetMaxVl(:,iL)),'-','color',[0.93 0.69 0.13],'linewidth',1,'Marker','o');
                h(4) = plot(vX,abs(refSetMaxEb(:,iL)),'--','color',[0.93 0.69 0.13],'linewidth',1,'Marker','s');
                h(1) = plot(vX,abs(dataSetMaxVl(:,iL)),'-','color',[0 0.45 0.74],'linewidth',1,'Marker','o');
                h(3) = plot(vX,abs(dataSetMaxEb(:,iL)),'--','color',[0 0.45 0.74],'linewidth',1,'Marker','s');
                EcaTool.axisLayout(gca,OPT.plotLongitudinal);
                EcaTool.rotatedAxisTicks(gca,cStatsPlot,45);
                if refModel
                    legend(h,{'Vloed data','Vloed ref','Eb data','Eb ref'},'location','northeastoutside');
                    title({'Variatie maximale eb- en vloedsnelheid langsheen estuarium';[OPT.name ' versus ' OPT.refname]});
                else
                    legend(h([1,3]),{'Vloed','Eb'},'location','northeastoutside');
                    title({'Variatie maximale eb- en vloedsnelheid langsheen estuarium';OPT.name});
                end
                sFile = fullfile(OPT.outDir,'2_Longitudinal',['Vloed_Eb_MaxVel_series_',OPT.cPrefixes{iL+1},'.png']);
                print(gcf,sFile,'-dpng');
                clf;
            end
            close;
            
                        % make plot for max velocities and for tijsduur
            hFig = figure; hold on;
            set(hFig,'Visible', OPT.visibility); 
            OPT.plotLongitudinal.Position = [50 50 900 600];
            OPT.plotLongitudinal = EcaTool.figureLayout(hFig,OPT.plotLongitudinal);
            OPT.plotLongitudinal.XLim = vXlim;
            OPT.plotLongitudinal.XTick = vX;
%             OPT.plotLongitudinal.XTickLabel = strrep(cStations,'_',' ');
            OPT.plotLongitudinal.YLim = [0 10*60];
            OPT.plotLongitudinal.YTick = linspace(0,10*60,4);
            OPT.plotLongitudinal.YLabel = 'tijdsduur [min]';
            
            for iL=1:3
                h = nan(4,1);
                hold on;
                h(2) = plot(vX,abs(refSetVlT(:,iL)),'-','color',[0.93 0.69 0.13],'linewidth',1,'Marker','o');
                h(4) = plot(vX,abs(refSetEbT(:,iL)),'--','color',[0.93 0.69 0.13],'linewidth',1,'Marker','s');
                h(1) = plot(vX,abs(dataSetVlT(:,iL)),'-','color',[0 0.45 0.74],'linewidth',1,'Marker','o');
                h(3) = plot(vX,abs(dataSetEbT(:,iL)),'--','color',[0 0.45 0.74],'linewidth',1,'Marker','s');                
                EcaTool.axisLayout(gca,OPT.plotLongitudinal);
                EcaTool.rotatedAxisTicks(gca,cStatsPlot,45);
                if refModel
                    legend(h,{'Vloed data','Vloed ref','Eb data','Eb ref'},'location','northeastoutside');
                    title({'Variatie tijdsduur eb en vloed langsheen estuarium';[OPT.name ' versus ' OPT.refname]});
                else
                    legend(h([1,3]),{'Vloed','Eb'},'location','northeastoutside');
                    title({'Variatie tijdsduur eb en vloed langsheen estuarium';OPT.name});
                end
                sFile = fullfile(OPT.outDir,'2_Longitudinal',['Vloed_Eb_Tijdsduur_series_',OPT.cPrefixes{iL+1},'.png']);
                print(gcf,sFile,'-dpng');
                clf;
            end
            close;

            
        end
        
        function [indTide,iLw1,iLw2] = lookupTideIndices(vTime,indexLowData,indexHigh)
            % function to look up the indices between lw and lw in a tide 
            iLw1        = find(vTime(indexLowData)<vTime(indexHigh),1,'last');
            iLw2        = find(vTime(indexLowData)>vTime(indexHigh),1,'first');
            indTide     = find(vTime(indexLowData(iLw1))<=vTime & vTime<=vTime(indexLowData(iLw2)));
        end
        
        function [maxVl,startVl,stopVl,maxEb,startEb,stopEb] = analyse_TidalVelocities(vT,velTide,indHW)
            % Function to look up the maximum vloed en eb stroming rond een
            % specifiek hoogwater. Functie levert ook de start en stop
            % tijden van vloed en eb
            % Assumptie: vloed is negatief, eb is positief

            dt = vT(2)-vT(1);
            range = indHW + round((-8/(dt*24):+3/(dt*24)));
            range = max(1,range);
            range = min(length(velTide),range);
            % flood = minimum negative value between HW-8u -> HW+3u
            % ebb = maximum positive value after flood and up to
            % HW+8u
            [maxVl,ind] = min(velTide(range));
            indVl = range(ind);
            range = indVl + round((0/(dt*24):+12/(dt*24)));
            range = max(1,range);
            range = min(length(velTide),range);     
            [maxEb,ind] = max(velTide(range));
            indEb = range(ind);
            
            indStart = find(velTide(1:indVl)>0,1,'last')+1;
            if isempty(indStart)
                indStart = 1;
            end
            indEnd = find(velTide(indVl:end)>0,1,'first')-1;
            if isempty(indEnd)
                indEnd = 1;
            end
            indEnd = indVl-1 + indEnd;
            startVl = vT(indStart);
            stopVl = vT(indEnd);
            
            indStart = find(velTide(1:indEb)<0,1,'last')+1;
            if isempty(indStart)
                indStart = 1;
            end
            indEnd = find(velTide(indEb:end)<0,1,'first')-1;
            if isempty(indEnd)
                indEnd = 1;
            end
            indEnd = indEb-1 + indEnd;
            startEb = vT(indStart);
            stopEb = vT(indEnd);
            
        end
        
        function [Hw,Lw,iHw,iLw] = lookupHwLwTide(tTide,vT,indHw,indLw,WL)
            % function to determine the nearest HW and LW near a specific
            % time and the index of indHw and indLw
            
            % look up maximum Hw around tTide
            ind = find((tTide-3/24)<=vT(indHw)&vT(indHw)<=(tTide+6/24));
            if length(ind)>1
                Hw = max(WL(indHw(ind)));
                iHw = ind(WL(indHw(ind))==x);
            else
                Hw = WL(indHw(ind));
                iHw = ind;
            end
            % look up lowest Lw befor or after HW
            indT = nan(2,1);
            indT(1) = find(vT(indLw)<vT(indHw(iHw)),1,'last');
            indT(2) = find(vT(indLw)>vT(indHw(iHw)),1,'first');
            lw1 = nan;
            lw2 = nan;
            if ~isempty(indT(1))
                lw1 = WL(indLw(indT(1)));
            end
            if isempty(indT(2))
                lw2 = WL(indLw(indT(2)));
            end
            [Lw,iTT] = min([lw1,lw2]);
            iLw = indT(iTT);
        end
       
        function processFlowFields(dataset2D,OPT,dataset2Dref)
            % function to plot 2D flow fields
            
            OPT.plotFlow = Util.setDefault(OPT.plotFlow,'saveFigures',true);
            OPT.plotFlow = Util.setDefault(OPT.plotFlow,'saveAnimation',false);
            OPT.plotFlow = Util.setDefault(OPT.plotFlow,'doublePlot',false);
            OPT.plotFlow = Util.setDefault(OPT.plotFlow,'vThreshold',0); % if zero no adaption on the vector length below and above this threshold is done
            % OPT.telFile = 'Z:\projects\18069\Scenarios\BasicTestObc04\RES2D.slf';
            if ~isdir(fullfile(OPT.outDir,'4_FlowFields'))
                mkdir(fullfile(OPT.outDir,'4_FlowFields'));
            end
            % determine time steps to be plotted (mean, spring, neap)
            % HW at reference station, 
            indRef = find(strcmp(dataset2D.Stations.data,OPT.refPoint),1,'first');
            if isempty(indRef)
                error(['No station named: ',OPT.refPoint,' available. Processing stopped']);
            end
            vTstat = dataset2D.Time.data;
            WLstat = dataset2D.WatLev.data{indRef};
            vel = sqrt(dataset2D.VelX.data{indRef}.^2 + dataset2D.VelY.data{indRef}.^2);
            OPT.directionsObs = 'k:\PROJECTS\11\11498_P009392 - Vaarwegbeheer 2016-2021\11498-005 - sMER ECA\07-Uitv\ModelPostProcessing\Stations\Observatiepunten_v2.mat';
            dataDir = load(OPT.directionsObs);
            dist = sqrt((dataset2D.X.data(indRef)-dataDir.obsTable(:,1)).^2+...
                        (dataset2D.Y.data(indRef)-dataDir.obsTable(:,2)).^2);
            [minDist,indexMin] = min(dist);
            if minDist<10
                nRot = dataDir.obsTable(indexMin,3);
            else
                warning([OPT.refPoint ': closest point for eb directions is more than 10m away']);
                nRot = 0;
            end
            [~,vUit] = Calculate.rotateVector(dataset2D.VelX.data{indRef},dataset2D.VelY.data{indRef},-nRot,'radians');
            if size(vel,2)== size(vUit,2)
                velTide = sign(vUit).*vel;
            else
                velTide = sign(transpose(vUit)).*vel;
            end

            % if requried load reference water level
            if OPT.plotFlow.doublePlot
                indRefRef = find(strcmp(dataset2Dref.Stations.data,OPT.refPoint),1,'first');
                if isempty(indRefRef)
                    error(['No station named: ',OPT.refPoint,' available. Processing stopped']);
                end
                vTstatRef = dataset2Dref.Time.data;
                WLstatRef = dataset2Dref.WatLev.data{indRefRef};                
            end
            
            % determine HW at reference station near the selected periods
            % and set the start and end time of the plots at HW - 7hr to HW + 7hr
            vTHW = nan(3,2);
            vTVl = nan(3,2);
            vTEb = nan(3,2);
            
            periodData = 9/( (dataset2D.Time.data(2)-dataset2D.Time.data(1)) * 24);
            sctOption.method = 'peakdet';
            sctOption.threshold = 1;
            [indexHighData,indexLowData] = TidalAnalysis.calcHwLw(dataset2D.WatLev.data{indRef},periodData,sctOption);
            
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWmean),vTstat,indexHighData,indexLowData,WLstat);
            vTHW(1,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];
            [~,vTVl(1,1),vTVl(1,2),~,vTEb(1,1),vTEb(1,2)]   = EcaTool.analyse_TidalVelocities(vTstat,velTide,indexHighData(iHw));
            
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWspring),vTstat,indexHighData,indexLowData,WLstat);
            vTHW(2,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];
            [~,vTVl(2,1),vTVl(2,2),~,vTEb(2,1),vTEb(2,2)]   = EcaTool.analyse_TidalVelocities(vTstat,velTide,indexHighData(iHw));
            
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWneap),vTstat,indexHighData,indexLowData,WLstat);
            vTHW(3,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];
            [~,vTVl(3,1),vTVl(3,2),~,vTEb(3,1),vTEb(3,2)]   = EcaTool.analyse_TidalVelocities(vTstat,velTide,indexHighData(iHw));
            
            % read the map output times from the selafin file
            % map outputs is in original timezone
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            for i=1:3
                % map output is in original time zone so convert the
                % requrested times (based on UTC timings) to local time
                cTHW{i} = vTHW(i,:)-OPT.dT2UTC;
            end
            telTimeStep = Telemac.getTimeSteps(sctData,cTHW);
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            
            % loop over selected periods
            nrPeriod = size(vTHW,1);
%             nrPeriod = 1;
            
            datamap = struct;
            datamap.Periods.data = OPT.cPrefixes(2:end);
            datamap.WatLev.Station.data = OPT.refPoint;
            datamap.WatLev.Time.data = vTstat;
            datamap.WatLev.WatLev.data = WLstat;
            % general map data
            datamap.X.data = sctData.XYZ(:,1);
            datamap.Y.data = sctData.XYZ(:,2);
            datamap.IKLE.data = sctData.IKLE;
            
            [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = ...
                EcaTool.checkInterpolations(datamap.IKLE.data,datamap.X.data,datamap.Y.data,OPT,[],[],[]);
            
%             % check required interpolations
%             [numFr,txtFr,~] = xlsread(OPT.plotFlow.excelFrames);
%             % check requested interpolationmatrix
%             % check if already exists
%             indTitle = find(strcmp(txtFr(:,1),'Title'),1,'first');
%             cInterps = txtFr(2:indTitle-1,1);
%             cExtTitles = txtFr(indTitle+1:end,1);
%             cExtInterps = txtFr(indTitle+1:end,6);
%             
% %             cInterpsRequired = txtFr(indInterp+1:end,5);
%             nrMaps = numel(OPT.plotFlow.Frames);
%             sctInterp = cell(nrMaps,1);
%             mX = cell(nrMaps,1);
%             mY = cell(nrMaps,1);
%             vLimXY = ones(nrMaps,4);
%             vThinXY = ones(nrMaps,2);
%             vScale = ones(nrMaps,1);
%             if OPT.plotFlow.doublePlot
%                 sctInterpRef = cell(nrMaps,1);            
%             end
%             
%             % check if all required interps are already there.
%             % If not start creating them
%             if exist(fullfile(OPT.outDir,'0_Data','sctInterp.mat'),'file')>0
%                 Interp = load(fullfile(OPT.outDir,'0_Data','sctInterp.mat'));
%             else
%                 Interp = struct;
%                 Interp.Names = {};
%                 Interp.sctInterp = {};
%                 Interp.X = {};
%                 Interp.Y = {};
%                 Interp.sType = {};
%             end
%  
%             % load interp for reference run in case of double animation
%             if OPT.plotFlow.doublePlot
%                 InterpRef = load(fullfile(OPT.refmodel,'0_Data','sctInterp.mat'));
%             end
%             
%             for iM = 1:nrMaps
%                 indExtent = find(strcmp(OPT.plotFlow.Frames{iM},cExtTitles),1,'first');
%                 indInterp = find(strcmp(cExtInterps{indExtent},cInterps),1,'first');
%                 % read map information
%                 vLimXY(iM,:) = numFr(indExtent+indTitle-1,1:4);
%                 vThinXY(iM,:) = numFr(indExtent+indTitle-1,6:7);
%                 vScale(iM) = numFr(indExtent+indTitle-1,8);
%                 % interpolation matrix
%                 makeInterp = true;
%                 if numel(Interp.Names)>0
%                     indData = find(strcmp(cExtInterps{indExtent},Interp.Names),1,'first');
%                     if ~isempty(indData)
%                         makeInterp = false;
%                         sctInterp{iM} = Interp.sctInterp{indData};
%                         mX{iM} = Interp.X{indData};
%                         mY{iM} = Interp.Y{indData};
%                     end
%                 end
%                 if makeInterp
%                     nrElem = numel(Interp.Names);
%                     Interp.Names{nrElem+1} = cExtInterps{indExtent};
%                     Interp.sType{nrElem+1} = 'Structured';
%                     vX = numFr(indInterp,1):numFr(indInterp,5):numFr(indInterp,2);
%                     vY = numFr(indInterp,3):numFr(indInterp,6):numFr(indInterp,4);
%                     [Interp.X{nrElem+1},Interp.Y{nrElem+1}] = meshgrid(vX,vY);
%                     Interp.sctInterp{nrElem+1} = Triangle.interpTrianglePrepare(datamap.IKLE.data,datamap.X.data,datamap.Y.data,Interp.X{nrElem+1}(:),Interp.Y{nrElem+1}(:));
%                     % save to structure:
%                     sctInterp{iM} = Interp.sctInterp{nrElem+1};
%                     mX{iM} = Interp.X{nrElem+1};
%                     mY{iM} = Interp.Y{nrElem+1};
%                     % save data so it can be read next time
%                     save(fullfile(OPT.outDir,'0_Data','sctInterp.mat'),'-struct','Interp');
%                 end
                
%                 if OPT.plotFlow.doublePlot
%                     if numel(InterpRef.Names)>0
%                         indData = find(strcmp(cExtInterps{indExtent},InterpRef.Names),1,'first');
%                         if ~isempty(indData)
%                             sctInterpRef{iM} = InterpRef.sctInterp{indData};
%                         end
%                     end
%                 end
%                 
%             end
                   
%             vX = OPT.plotFlow.XLim(1):OPT.plotFlow.interptick(1):OPT.plotFlow.XLim(2);
%             vY = OPT.plotFlow.YLim(1):OPT.plotFlow.interptick(2):OPT.plotFlow.YLim(2);
%             [datamap.mX.data,datamap.mY.data] = meshgrid(vX,vY);
%             sctInterp = Triangle.interpTrianglePrepare(datamap.IKLE.data,datamap.X.data,datamap.Y.data,datamap.mX.data(:),datamap.mY.data(:));
%             datamap.sctInterp.data = sctInterp;
%             gridSize = size(datamap.mX.data);

%             if OPT.plotFlow.doublePlot
%                 if isfield(OPT,'slfFile2DRef')
%                     if ~isempty(OPT.slfFile2DRef)
%                         [dataSetRef,sctDataRef,varNamesRef] = Telemac.readTelemacHeader(OPT.slfFile2DRef);
%                     end
%                 end
%             end

            
            
            LDB = {};
            for iL=1:numel(OPT.plotFlow.Landboundary)
                LDB = [LDB, Telemac.readKenue(OPT.plotFlow.Landboundary{iL})];
            end
            
%             if OPT.plotFlow.doublePlot
%                 LDBRef = {};
%                 sldb = {'K:\PROJECTS\11\11498_P009392 - Vaarwegbeheer 2016-2021\11498-005 - sMER ECA\07-Uitv\ModelSetup\1-Mesh\update_4\Scaldis_v1.0(Edges).i2s'};
%                 for iL=1:numel(sldb)
%                     LDBRef = [LDBRef, Telemac.readKenue(sldb{iL})];
%                 end
%             end

            
            for iM = 1:nrMaps
                outFolderMap = fullfile(OPT.outDir,'4_FlowFields',OPT.plotFlow.Frames{iM});
                if ~isdir(outFolderMap)
                    mkdir(outFolderMap);
                end
                hFig = figure;
                set(hFig,'Visible', OPT.visibility);
                OPT.plotFlow = EcaTool.figureLayout(hFig,OPT.plotFlow);
                hold on;
                for iT = 1:nrPeriod
                    % preallocate the max velocity maps to be considered
                    % only do this for the first loop
                    if iM==1
                        datamap.VelMax.data{iT} = zeros(sctData.nrPoints,1);
                        datamap.EbMax.data{iT} = zeros(sctData.nrPoints,1);
                        datamap.FloodMax.data{iT} = zeros(sctData.nrPoints,1);
                        datamap.TauMax.data{iT} = zeros(sctData.nrPoints,1);
                        nrTime = length(telTimeStep{iT});
                        datamap.Time.data{iT} = zeros(nrTime,1);
                    end
                    
                    if OPT.plotFlow.saveAnimation
                        indSlash = strfind(OPT.outDir,'\');
                        prefix = OPT.outDir(indSlash(end-1)+1:indSlash(end)-1);
                        indDash = strfind(prefix,'-');
                        if ~isempty(indDash)
                            prefix = prefix(indDash(1)+1:end);
                        end
                        video = VideoWriter(fullfile(outFolderMap,[prefix,'_dieptegemiddelde_stroming_',OPT.cPrefixes{iT+1},'.avi']));
                        video.Quality = 100;
                        video.FrameRate = 1;
                        open(video);
                    end
                    
                    for iTime = 1:length(telTimeStep{iT})
                        
                        sctOptions.start  = telTimeStep{iT}(iTime);
                        [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                        datamap.Time.data{iT}(iTime) = dataSet.Time.data(1)+OPT.dT2UTC;
                        
                        VelX = dataSet.VelX.data;
                        VelY = dataSet.VelY.data;
                        mag = sqrt(VelX.^2 + VelY.^2);
                        
%                         if OPT.plotFlow.doublePlot
%                             [dataSetRef,sctDataRef] = Telemac.readTelemacData(dataSetRef,sctDataRef,varNamesRef,sctOptions);
%                             VelXRef = dataSetRef.VelX.data;
%                             VelYRef = dataSetRef.VelY.data;
%                             magRef = sqrt(VelXRef.^2 + VelYRef.^2);                            
%                             % interpolation
%                             URef = reshape(Triangle.interpTriangle(sctInterpRef{iM},VelXRef),size(mX{iM}));
%                             VRef = reshape(Triangle.interpTriangle(sctInterpRef{iM},VelYRef),size(mY{iM}));       
%                             refTime = dataSetRef.Time.data(1)+OPT.dT2UTC;
%                         end
                        
                        % only durinig first map check max velocities
                        if iM==1
                           datamap.VelMax.data{iT} = max(datamap.VelMax.data{iT},mag);
                            if datamap.Time.data{iT}(iTime)>=vTVl(iT,1) && datamap.Time.data{iT}(iTime)<=vTVl(iT,2)
                                % flood period
                                datamap.FloodMax.data{iT} = max(datamap.FloodMax.data{iT},mag);
                            elseif datamap.Time.data{iT}(iTime)>=vTEb(iT,1) && datamap.Time.data{iT}(iTime)<=vTEb(iT,2)
                                % ebb period
                                datamap.EbMax.data{iT} = max(datamap.EbMax.data{iT},mag);
                            end
                        end
                        
                        % interpolation
                        U = reshape(Triangle.interpTriangle(sctInterp{iM},VelX),size(mX{iM}));
                        V = reshape(Triangle.interpTriangle(sctInterp{iM},VelY),size(mY{iM}));
                        
                        % set all the plot options
                        OPT.plotFlow.XLim = vLimXY(iM,1:2);
                        OPT.plotFlow.YLim = vLimXY(iM,3:4);
                        OPT.plotFlow.veMN = vThinXY(iM,:);
                        OPT.plotFlow.vScale = vScale(iM);
                        OPT.plotFlow.vCAxis = OPT.plotFlow.vRangeVel;
                        OPT.plotFlow.Title = {'Dieptegemiddelde stroomsnelheden';['Model: ',OPT.name];...
                            ['Tijd: ',datestr(datamap.Time.data{iT}(iTime),'dd/mm/yyyy HH:MM')]};
                        OPT.plotFlow.Tide = OPT.plotFlow.Getij;
                        OPT.plotFlow.Tide.XLim = vTHW(iT,:);
                        OPT.plotFlow.Tide.XTick = ceil(vTHW(iT,1)*24)/24:2/24:floor(vTHW(iT,2)*24)/24;
                        OPT.plotFlow.Tide.YLim = OPT.plotFlow.Getij.YLim;
                        OPT.plotFlow.Tide.nT = datamap.Time.data{iT}(iTime);
                        OPT.plotFlow.Tide.Title = {['Station: ',strrep(OPT.refPoint,'_',' ')];...
                            ['Getij ',datestr(vTHW(iT,1),'dd/mm/yyyy HH:MM'),...
                            ' - ',datestr(vTHW(iT,end),'dd/mm/yyyy HH:MM')]};
            
%                         if OPT.plotFlow.doublePlot
%                             OPT.plotFlowDouble = OPT.plotFlow;
%                             OPT.plotFlowDouble.Title = {'Dieptegemiddelde stroomsnelheden';['Model: ',OPT.refname];...
%                                 ['Tijd: ',datestr(refTime,'dd/mm/yyyy HH:MM')]};
%                             OPT.plotFlowDouble.Tide.nT = refTime;
%                             
%                             [hAx1,hAx2,hAx3,hAx4] = EcaTool.make2MapQuiverTide(hFig,...
%                                 sctDataRef.IKLE,sctDataRef.XYZ(:,1),sctDataRef.XYZ(:,2),magRef,...
%                                 mX{iM},mY{iM},URef,VRef,LDBRef,vTstatRef,WLstatRef,OPT.plotFlowDouble,...
%                                 datamap.IKLE.data,datamap.X.data,datamap.Y.data,mag,...
%                                 mX{iM},mY{iM},U,V,LDB,vTstat,WLstat,OPT.plotFlow);
%                             
%                         else
                            
                            [hAx1,hAx2] = EcaTool.makeMapQuiverTide(hFig,datamap.IKLE.data,datamap.X.data,datamap.Y.data,mag,...
                                mX{iM},mY{iM},U,V,LDB,vTstat,WLstat,OPT.plotFlow);
                            
%                         end
                        
                        sFile = fullfile(outFolderMap,['Dieptegemiddelde_',OPT.cPrefixes{iT+1},'_',datestr(datamap.Time.data{iT}(iTime),'yyyymmdd_HHMM'),'.png']);
                        if OPT.plotFlow.saveFigures
                            print(hFig,sFile,'-dpng');
                        end
                        
                        if OPT.plotFlow.saveAnimation
                            frame = getframe(gcf);
                            writeVideo(video,frame);
                        end
                        
                        clf;
                    end
                    if OPT.plotFlow.saveAnimation
                        close(video);
                    end
                    
                    % add plots of the maximum velocity, maximum ebb
                    % velocity, maximum flood velocity and maximum bed
                    % shear stress
                    if OPT.plotFlow.saveFigures
                    OPT.plotFlow.Title = {'Maximale dieptegemiddelde stroomsnelheid';...;...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                    EcaTool.makeMap(hFig, datamap.IKLE.data, datamap.X.data, datamap.Y.data, datamap.VelMax.data{iT},LDB,OPT.plotFlow);
                        sFile = fullfile(outFolderMap,['Maximum_Dieptegemiddelde_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        saveas(hFig,strrep(sFile,'.png','.fig'),'fig');
                        clf;

                    OPT.plotFlow.Title = {'Maximale dieptegemiddelde ebstroomsnelheid';...;...
                        [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                    EcaTool.makeMap(hFig, datamap.IKLE.data, datamap.X.data, datamap.Y.data, datamap.EbMax.data{iT},LDB,OPT.plotFlow);
                        sFile = fullfile(outFolderMap,['Maximum_Eb_Dieptegemiddelde_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        saveas(hFig,strrep(sFile,'.png','.fig'),'fig');
                        clf;
                        
                    OPT.plotFlow.Title = {'Maximale dieptegemiddelde vloedstroomsnelheid';...;...
                        [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                    EcaTool.makeMap(hFig, datamap.IKLE.data, datamap.X.data, datamap.Y.data, datamap.FloodMax.data{iT},LDB,OPT.plotFlow);
                    sFile = fullfile(outFolderMap,['Maximum_Vloed_Dieptegemiddelde_',OPT.cPrefixes{iT+1},'.png']);
                    print(hFig,sFile,'-dpng');
                    saveas(hFig,strrep(sFile,'.png','.fig'),'fig');
                    clf;
                    end

                end
                close all;
            end
            if OPT.saveresults
                save(fullfile(OPT.outDir,'0_Data','mapresults.mat'),'-struct','datamap');  
            end
        end

        function processDeltaFields(OPT,sType)
            % function to make delta plots for unstructured meshes
            
            % load map output of reference run if delta figures are request
            if ~isempty(OPT.refmodel);
                display(' --- loading reference map data');
                datamapRef = load(fullfile(OPT.refmodel,'0_Data','mapresults.mat'));
                % loading data
                datamap = load(fullfile(OPT.outDir,'0_Data','mapresults.mat'));
                                
               [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = EcaTool.checkInterpolations(...
                   datamap.IKLE.data,datamap.X.data,datamap.Y.data,OPT,datamapRef.X.data,datamapRef.Y.data,OPT.refname);
               
                LDB = {};
                for iL=1:numel(OPT.plotFlow.Landboundary)
                    LDB = [LDB, Telemac.readKenue(OPT.plotFlow.Landboundary{iL})];
                end
                    
                % plot difference in VelMax, FloodMax, EbMax
                hFig = figure;
                set(hFig,'Visible', OPT.visibility);
                OPT.plotFlow = EcaTool.figureLayout(hFig,OPT.plotFlow);
                hold on;
                for iM=1:nrMaps
                    outFolderMap = fullfile(OPT.outDir,'4_FlowFields',OPT.plotFlow.Frames{iM});
                    if ~isdir(outFolderMap)
                        mkdir(outFolderMap);
                    end
                    
                    OPT.plotFlow.XLim = vLimXY(iM,1:2);
                    OPT.plotFlow.YLim = vLimXY(iM,3:4);
                    sColorbarLabel = '(<0) afname stroomsnelheid                   toename stroomsnelheid (>0)';
                    nrPeriod=3;
                    for iT=1:nrPeriod
                        % for iV = 1:nrVar -> datamap.(sVar(iV)).data ->
                        % sVar = VelMax, EbMax, FloodMax, TauMax
                        MaxRef          = datamapRef.VelMax.data{iT};
                        MaxData         = nan(size(MaxRef));
                        MaxData(Ind)    = Triangle.interpTriangle(sctInterp{iM},datamap.VelMax.data{iT});
                        deltaMax        = zeros(size(MaxRef));
                        deltaMax(Ind)   = MaxData(Ind)-MaxRef(Ind);
                        
                        if isfield(datamapRef,'EbMax')
                            EbMaxRef        = datamapRef.EbMax.data{iT};
                        else
                            EbMaxRef = nan(size(MaxRef));
                        end
                        EbMaxData       = nan(size(MaxRef));
                        EbMaxData(Ind)  = Triangle.interpTriangle(sctInterp{iM},datamap.EbMax.data{iT});
                        deltaEbMax      = zeros(size(MaxRef));
                        deltaEbMax(Ind) = EbMaxData(Ind)-EbMaxRef(Ind);
                        
                        if isfield(datamapRef,'FloodMax')
                            FloodMaxRef        = datamapRef.FloodMax.data{iT};
                        else
                            FloodMaxRef = nan(size(MaxRef));
                        end
                        FloodMaxData       = nan(size(MaxRef));
                        FloodMaxData(Ind)  = Triangle.interpTriangle(sctInterp{iM},datamap.FloodMax.data{iT});
                        deltaFloodMax      = zeros(size(MaxRef));
                        deltaFloodMax(Ind) = FloodMaxData(Ind)-FloodMaxRef(Ind);
                        
                        % maximum velocity
                        axis equal;
                        EcaTool.axisLayout(gca,OPT.plotFlow);
                        hold on;
                        Plot.plotTriangle(datamapRef.X.data, datamapRef.Y.data, deltaMax, datamapRef.IKLE.data);
                        shading interp;
                        EcaTool.setDeltaColor(gca,OPT.plotFlow.Delta.caxis,OPT.plotFlow.Delta.colorbarTick,sColorbarLabel,OPT.plotFlow.Delta.FontSize)
                        for iL=1:numel(LDB)
                            plot(LDB{iL}(:,1),LDB{iL}(:,2),'-k','linewidth',2);
                        end
                        % finish plot
                        EcaTool.scaleAxisTicks(gca,0.001);
                        title({'Verschil in maximale dieptegemiddelde stroomsnelheden';...
                            [OPT.name,' versus ',OPT.refname];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]},'Fontsize',OPT.plotFlow.FontSize)
                        sFile = fullfile(outFolderMap,['Delta_Maximum_Dieptegemiddelde_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        saveas(hFig,strrep(sFile,'.png','.fig'),'fig');
                        clf;

                        % maximum eb velocity
                        axis equal;
                        EcaTool.axisLayout(gca,OPT.plotFlow);
                        hold on;
                        Plot.plotTriangle(datamapRef.X.data, datamapRef.Y.data, deltaEbMax, datamapRef.IKLE.data);
                        shading interp;
                        EcaTool.setDeltaColor(gca,OPT.plotFlow.Delta.caxis,OPT.plotFlow.Delta.colorbarTick,sColorbarLabel,OPT.plotFlow.Delta.FontSize)
                        for iL=1:numel(LDB)
                            plot(LDB{iL}(:,1),LDB{iL}(:,2),'-k','linewidth',2);
                        end
                        % finish plot
                        EcaTool.scaleAxisTicks(gca,0.001);
                        title({'Verschil in maximale dieptegemiddelde ebstroomsnelheden';...
                            [OPT.name,' versus ',OPT.refname];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]},'Fontsize',OPT.plotFlow.FontSize)
                        sFile = fullfile(outFolderMap,['Delta_Maximum_Eb_Dieptegemiddelde_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        saveas(hFig,strrep(sFile,'.png','.fig'),'fig');
                        clf;
                        
                        % maximum flood velocity
                        axis equal;
                        EcaTool.axisLayout(gca,OPT.plotFlow);
                        hold on;
                        Plot.plotTriangle(datamapRef.X.data, datamapRef.Y.data, deltaFloodMax, datamapRef.IKLE.data);
                        shading interp;
                        EcaTool.setDeltaColor(gca,OPT.plotFlow.Delta.caxis,OPT.plotFlow.Delta.colorbarTick,sColorbarLabel,OPT.plotFlow.Delta.FontSize)
                        for iL=1:numel(LDB)
                            plot(LDB{iL}(:,1),LDB{iL}(:,2),'-k','linewidth',2);
                        end
                        % finish plot
                        EcaTool.scaleAxisTicks(gca,0.001);
                        title({'Verschil in maximale dieptegemiddelde vloedstroomsnelheden';...
                            [OPT.name,' versus ',OPT.refname];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]},'Fontsize',OPT.plotFlow.FontSize)
                        sFile = fullfile(outFolderMap,['Delta_Maximum_Vloed_Dieptegemiddelde_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        saveas(hFig,strrep(sFile,'.png','.fig'),'fig');
                        clf;

                    end
                end
                
                close all;
            end
        end
   
        function procExportVel(OPT,dataTs2D)
            % exports velocities in a matlab file
            
            %default options
            OPT.exportVelProc = Util.setDefault(OPT.exportVelProc,'timLim',[-inf inf]);
            nrPeriod = size(OPT.exportVelProc.timLim,1);
            OPT.exportVelProc = Util.setDefault(OPT.exportVelProc,'XLim',[-inf inf]);
            OPT.exportVelProc = Util.setDefault(OPT.exportVelProc,'YLim',[-inf inf]);
            OPT.exportVelProc = Util.setDefault(OPT.exportVelProc,'varList',...
                {'VelX','VelY','VelXbot50','VelYbot50','VelXtop50','VelYtop50','WatLev','Depth'});
            defPeriodName = cell(nrPeriod,1);
            for i=1:nrPeriod
                defPeriodName{i} = ['period',num2str(i,'%02.0f')];
            end
            OPT.exportVelProc = Util.setDefault(OPT.exportVelProc,'periodName',defPeriodName);
            % make dir
            outDir = fullfile(OPT.outDir,'8_matFilesVel');
            if ~exist(outDir,'dir')
                mkdir(outDir);
            end
            
            % find necessary time steps
            % slfFile = OPT.slfFile2D{1};
            slfFile = OPT.slfFile2D;
            sctData     = telheadr(slfFile);
            telTimeStep = Telemac.getTimeSteps(sctData,OPT.exportVelProc.timLim);
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(slfFile);
            
            % select output variables
            varList = OPT.exportVelProc.varList;
            outVar = [];
            % select output data
            for iVar = 1:length(varList)
                theVar = varList{iVar};
                if any(strcmpi(theVar,varNames))
                    dataOut.(theVar) = struct;
                    outVar = [outVar,iVar]; %#ok<AGROW>
                end
            end
            
            % select stations for time series
            OPT.exportVelProc = Util.setDefault(OPT.exportVelProc,'tsStats',{});
            maskStat = [];
            statList = OPT.exportVelProc.tsStats;
            for iStat =  1:length(statList)
                ind = strcmpi(statList{iStat},dataTs2D.Stations.data);
                if  sum(ind)>0
                    maskStat(iStat) = find(ind); %#ok<AGROW>
                else
                    error(['Station ',statList{iStat},' not found in data']);
                end
            end
            
            % select output points
            xLim = OPT.exportVelProc.XLim;
            yLim = OPT.exportVelProc.YLim;
            mask = dataSet.X.data>=min(xLim) & dataSet.X.data<=max(xLim) &...
                   dataSet.Y.data>=min(yLim) & dataSet.Y.data<=max(yLim);
            nrX  = sum(mask);
            dataOut.X.data = dataSet.X.data(mask);
            dataOut.Y.data = dataSet.Y.data(mask);
            
            % specify metadata 
            
            dataOut.metadata = OPT.exportVelProc.metadata;
            % loop over selected periods
            for iPeriod = 1:nrPeriod
                % preallocate
                nrTime = length(telTimeStep{iPeriod});
                dataOut.time.data  =zeros(nrTime,1);
                for i =1:length(outVar)
                    iVar = outVar(i);
                    theVar = varList{iVar};
                    dataOut.(theVar).data = zeros(nrX,nrTime) ;
                    % add metadata
                    dataOut = Dataset.addDefaultVarData(dataOut,{'unit','longname'});           
                end
                % find data for all timesteps
                for iTime = 1:nrTime
                    % read data
                    sctOptions.start  = telTimeStep{iPeriod}(iTime);
                    [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                    % add time
                    dataOut.time.data(iTime) = dataSet.Time.data(1);
                    % add data to structure
                    for i =1:length(outVar)
                        iVar = outVar(i);
                        theVar = varList{iVar};
                        dataOut.(theVar).data(:,iTime) = dataSet.(theVar).data(mask);
                    end
                end
                
                % ABR mulitplying top and bottomvelocities by two to
                % correct a mistake in the Telemac code
                wrongFields= {'VelXbot50','VelYbot50','VelXtop50','VelYtop50'};
                for iWrong = 1:length(wrongFields)
                      theVar = wrongFields{iWrong};
                      dataOut.(theVar).data = 2.*dataOut.(theVar).data;
                end
                
                
                % add time series from NetCDF file
                % select period
                if ~isempty(maskStat)
                    tsOut  = struct;
                    tTs    = dataTs2D.Time.data;
                    maskTs = tTs>=min(OPT.exportVelProc.timLim{iPeriod}) & tTs<=max(OPT.exportVelProc.timLim{iPeriod});
                    % add metadata
                    tsOut.metadata      = OPT.exportVelProc.metadata;
                    tsOut.Stations.data = dataTs2D.Stations.data(maskStat);
%                     tsOut.X.data        = cell2mat(dataTs2D.X.data(maskStat));
%                     tsOut.Y.data        = cell2mat(dataTs2D.Y.data(maskStat));
                    tsOut.X.data        = dataTs2D.X.data(maskStat);
                    tsOut.Y.data        = dataTs2D.Y.data(maskStat);
                    % add data
                    tsOut.time.data     = tTs(maskTs);
                    wlTmp = cell2mat(dataTs2D.WatLev.data(maskStat)')';
                    tsOut.WatLev.data   = wlTmp(maskTs,:);
                    % finishing metadata
                    tsOut = Dataset.addDefaultVarData(tsOut,{'unit','longname'}); %#ok<NASGU>
                end
                
                % save to disk
                outFile = fullfile(outDir,['outputData',num2str(iPeriod,'%02.0f'),OPT.exportVelProc.periodName{iPeriod},'.mat']);
                if ~isempty(maskStat)
                    save(outFile,'dataOut','tsOut');
                else
                    save(outFile,'dataOut');
                end
            end
            
        end
        
        function processFriction(dataset2D,OPT)
            % function to calculate bed shear stresses, derive max bed
            % shear stress and make difference plots with reference run
                      
            if ~isdir(fullfile(OPT.outDir,'7_BedShearStress'))
                mkdir(fullfile(OPT.outDir,'7_BedShearStress'));
            end
            
            OPT.plotFlow = Util.setDefault(OPT.plotFlow,'vThreshold',0);
            OPT.plotTau.vThreshold = OPT.plotFlow.vThreshold;
            
            %% determine time steps to be plotted (mean, spring, neap)
            % HW at reference station, 
            indRef = find(strcmp(dataset2D.Stations.data,OPT.refPoint),1,'first');
            if isempty(indRef)
                error(['No station named: ',OPT.refPoint,' available. Processing stopped']);
            end
            vTstat = dataset2D.Time.data;
            WLstat = dataset2D.WatLev.data{indRef};
            
            % determine HW at reference station near the selected periods
            % and set the start and end time of the plots at HW - 7hr to HW + 7hr
            vTHW = nan(3,2);
            
            periodData = 9/( (dataset2D.Time.data(2)-dataset2D.Time.data(1)) * 24);
            sctOption.method = 'peakdet';
            sctOption.threshold = 1;
            [indexHighData,indexLowData] = TidalAnalysis.calcHwLw(dataset2D.WatLev.data{indRef},periodData,sctOption);
            
            cFix = {'HWmean';'HWspring';'HWneap'};
            for i=1:3
                [~,~,iHw,~] = EcaTool.lookupHwLwTide(datenum(OPT.(cFix{i})),vTstat,indexHighData,indexLowData,WLstat);
                %vTHW(1,2)   = vTstat(indexHighData(iHw));
                iLw1        = find(vTstat(indexLowData)<vTstat(indexHighData(iHw)),1,'last');
                iLw2        = find(vTstat(indexLowData)>vTstat(indexHighData(iHw)),1,'first');
                vTHW(i,1)   = vTstat(indexLowData(iLw1));
                vTHW(i,2)   = vTstat(indexLowData(iLw2));
            end

            % read the map output times from the selafin file
            % map outputs is in original timezone
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            IKLEin = sctData.IKLE;
            Xin = sctData.XYZ(:,1);
            Yin = sctData.XYZ(:,2);
            for i=1:3
                % map output is in original time zone so convert the
                % requrested times (based on UTC timings) to local time
                cTHW{i} = vTHW(i,:)-OPT.dT2UTC;
            end
            telTimeStep = Telemac.getTimeSteps(sctData,cTHW);
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            
            % read the interpolation information for the velocities
            [nrMaps,vLimXY,vThinXY,vScale,Ind,mXVel,mYVel,sctInterpVel] = EcaTool.checkInterpolations(...
                        IKLEin,Xin,Yin,OPT);
            
            %% check if the variable is available
            
            if ~isempty(find(strcmp(varNames,'FrictionVel'),1,'first'))
                
                % loop over selected periods
                nrPeriod = size(vTHW,1);
                
                %% check if reference run is available
                
                if ~isempty(OPT.refmodel);
                    makeDiffMaps = true;
                    display(' --- loading reference map data');
                    datamapRef = load(fullfile(OPT.refmodel,'0_Data','mapresults.mat'));
                    IKLE = datamapRef.IKLE.data;
                    X = datamapRef.X.data;
                    Y = datamapRef.Y.data;
                    %[nrMaps,vLimXY,Ind,sctInterp] = EcaTool.checkInterpolations(X,Y,IKLEin,Xin,Yin,OPT);
                    [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = EcaTool.checkInterpolations(...
                        IKLEin,Xin,Yin,OPT,X,Y,OPT.refname);
                else
                    makeDiffMaps = false;
                    [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = EcaTool.checkInterpolations([],[],[],OPT);
                end
                
                %% load landboundaries
                
                LDB = {};
                for iL=1:numel(OPT.plotTau.Landboundary)
                    LDB = [LDB, Telemac.readKenue(OPT.plotTau.Landboundary{iL})];
                end
                
                %% if existing load 3D map file
                
                if exist(fullfile(OPT.outDir,'0_Data','mapresults.mat'),'file')>0
                    datamap = load(fullfile(OPT.outDir,'0_Data','mapresults.mat'));
                else
                    datamap.X.data      = sctData.XYZ(:,1);
                    datamap.Y.data      = sctData.XYZ(:,2);
                    datamap.IKLE.data   = sctData.IKLE;
                    datamap.TauMax.data = {};
                end
                
                %% loop through all required zooms
                
                for iM = 1:nrMaps
                    outFolderMap = fullfile(OPT.outDir,'7_BedShearStress',OPT.plotFlow.Frames{iM});
                    if ~isdir(outFolderMap)
                        mkdir(outFolderMap);
                    end
                    hFig = figure;
                    set(hFig,'Visible', OPT.visibility);
                    OPT.plotTau = EcaTool.figureLayout(hFig,OPT.plotTau);
                    OPT.plotTau = Util.setDefault(OPT.plotTau,'plotSedThres',false);
                    hold on;
                    for iT = 1:nrPeriod
                        % preallocate the max velocity maps to be considered
                        % only do this for the first loop
                        if iM==1
                            datamap.TauMax.data{iT} = zeros(sctData.nrPoints,1);
                            nrTime = length(telTimeStep{iT});
                            datamap.Time.data{iT} = zeros(nrTime,1);
                        end
                        
                        for iTime = 1:length(telTimeStep{iT})
                            sctOptions.start  = telTimeStep{iT}(iTime);
                            [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                            datamap.Time.data{iT}(iTime) = dataSet.Time.data(1)+OPT.dT2UTC;
                            
                            Tau = OPT.frictionvelocity.density.*dataSet.FrictionVel.data.^2;                            
                            % find mask
                            vel = sqrt(dataSet.VelX.data.^2+dataSet.VelY.data.^2);
                            Mask = (vel<OPT.frictionvelocity.maskVelocity & dataSet.Depth.data<OPT.frictionvelocity.maskWaterDepth) | dataSet.Depth.data<OPT.frictionvelocity.criticalWaterDepth;
                            Tau(Mask) = 0;                         

                            if ~isempty(find(strcmp('VelXbot50',varNames),1))
                                VelX = dataSet.VelXbot50.data;
                                VelY = dataSet.VelYbot50.data;                            
                                U = reshape(Triangle.interpTriangle(sctInterpVel{iM},VelX),size(mXVel{iM}));
                                V = reshape(Triangle.interpTriangle(sctInterpVel{iM},VelY),size(mYVel{iM}));
                                titleVel = 'stromingsvector in onderste helft waterkolom';
                            else
                                % mXVel{iM} = [];
                                % mYVel{iM} = [];                                
                                % U = [];
                                % V = [];
                                VelX = dataSet.VelX.data;
                                VelY = dataSet.VelY.data;                            
                                U = reshape(Triangle.interpTriangle(sctInterpVel{iM},VelX),size(mXVel{iM}));
                                V = reshape(Triangle.interpTriangle(sctInterpVel{iM},VelY),size(mYVel{iM}));
                                titleVel = 'dieptegemiddelde stromingsvector';
                            end                            
                            
                            % only durinig first map check max velocities
                            if iM==1
                                datamap.TauMax.data{iT} = max(datamap.TauMax.data{iT},Tau);
                            end
                            
                            % set all the plot options
                            OPT.plotTau.XLim = vLimXY(iM,1:2);
                            OPT.plotTau.YLim = vLimXY(iM,3:4);
                            OPT.plotTau.veMN = vThinXY(iM,:);                            
                            OPT.plotTau.vScale = vScale(iM);
                            OPT.plotTau.vCAxis = OPT.plotTau.vRangeTau;
                            OPT.plotTau.Title = {['Bodemschuifspanning (Pa) en ',titleVel];['Model: ',OPT.name];...
                                ['Tijd: ',datestr(datamap.Time.data{iT}(iTime),'dd/mm/yyyy HH:MM')]};
                            
                            OPT.plotTau.Tide = OPT.plotTau.Getij;
                            OPT.plotTau.Tide.XLim = [vTHW(iT,1)-1/24 vTHW(iT,2)+1/24];
                            OPT.plotTau.Tide.XTick = ceil((vTHW(iT,1)-1/24)*24)/24:2/24:floor((vTHW(iT,2)+1/24)*24)/24;
                            OPT.plotTau.Tide.YLim = OPT.plotFlow.Getij.YLim;
                            OPT.plotTau.Tide.nT = datamap.Time.data{iT}(iTime);
                            OPT.plotTau.Tide.Title = {['Station: ',strrep(OPT.refPoint,'_',' ')];...
                                ['Getij ',datestr(vTHW(iT,1),'dd/mm/yyyy HH:MM'),...
                                ' - ',datestr(vTHW(iT,end),'dd/mm/yyyy HH:MM')]};
                            
                            [hAx1,hAx2] = EcaTool.makeMapQuiverTide(hFig,datamap.IKLE.data,datamap.X.data,datamap.Y.data,Tau,...
                                mXVel{iM},mYVel{iM},U,V,LDB,vTstat,WLstat,OPT.plotTau);
                            sFile = fullfile(outFolderMap,['Bodemschuifspanning_',OPT.cPrefixes{iT+1},'_',datestr(datamap.Time.data{iT}(iTime),'yyyymmdd_HHMM'),'.png']);
                            print(hFig,sFile,'-dpng');
                            clf;
                        end
                        
                        % make plots of max bed shear stress
                        OPT.plotTau.Title = {'Maximale bodemschuifspanning (Pa)';['Model: ',OPT.name];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                        EcaTool.makeMap(hFig, datamap.IKLE.data, datamap.X.data, datamap.Y.data, datamap.TauMax.data{iT},LDB,OPT.plotTau);
                        sFile = fullfile(outFolderMap,['Maximum_Bodemschuifspanning_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        
                        if OPT.plotTau.plotSedThres
                            
                            dataTemp = datamap.TauMax.data{iT};
                            dataTemp(dataTemp>max(OPT.plotTau.sedThres.vRangeTau-1e-6))=max(OPT.plotTau.sedThres.vRangeTau)-1e-6;
                            EcaTool.makeMap(hFig, datamap.IKLE.data, datamap.X.data, datamap.Y.data, dataTemp,LDB,OPT.plotTau);
                            [Ctemp,Htemp] = tricontour([datamap.X.data datamap.Y.data],datamap.IKLE.data,dataTemp,[0.2 0.2],'k');
                            htri = findall(gcf,'type','patch','facecolor','none');
                            set(htri,'linewidth',2,'edgecolor',[0.2 0.8 0.2]);
                            clear dataTemp
                            legend(Htemp,'0.2 Pa','location','southwest');
                            
                            caxis(OPT.plotTau.sedThres.vRangeTau);
                            colormap(OPT.plotTau.sedThres.colorMap);
                            cb = findall(gcf,'type','colorbar');
                            cb.Ticks = OPT.plotTau.sedThres.cTicks ;
                            
%                             OPT.plotTau.Title = {'Maximale bodemschuifspanning (Pa)';...;...
%                                 [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                            sFile = fullfile(outFolderMap,['Maximum_Bodemschuifspanning_Sedimentatie',OPT.cPrefixes{iT+1},'.png']);
                            print(hFig,sFile,'-dpng');
                            
                        end
                        
                        clf;
                        
                        % if difference make plot
                        if makeDiffMaps
                            TauRef          = datamapRef.TauMax.data{iT};
                            TauData         = nan(size(TauRef));
                            TauData(Ind)    = Triangle.interpTriangle(sctInterp{iM},datamap.TauMax.data{iT});
                            deltaTau        = zeros(size(TauRef));
                            deltaTau(Ind)   = TauData(Ind)-TauRef(Ind);
                            
                            OPT.plotTau.Title = {'Verschil in maximale bodemschuifspanning (Pa)';...
                                [OPT.name,' versus ',OPT.refname];...
                                [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                            EcaTool.makeDiffMap(hFig,IKLE,X,Y,deltaTau,LDB,OPT.plotTau);
                            sFile = fullfile(outFolderMap,['Delta_Maximum_Bodemschuifspanning_',OPT.cPrefixes{iT+1},'.png']);
                            print(hFig,sFile,'-dpng');
                        end
                        
                    end
                    close;
                end
                save(fullfile(OPT.outDir,'0_Data','mapresults.mat'),'-struct','datamap');
            else
                warning(['No friction velocity specified in run ',OPT.name,' in Slf file: ',OPT.slfFile2D])
            end
            
        end
        
        function processSalinity(dataset2D,OPT)
            % function to plot and process salinity maps
            %make output directory
            outDir = fullfile(OPT.outDir,'5_Salinity');
            if ~exist(outDir,'dir')
                mkdir(outDir);
            end
            
            % determine time steps to be plotted (mean, spring, neap)
            % HW at reference station, 
            indRef = find(strcmp(dataset2D.Stations.data,OPT.refPoint),1,'first');
            if isempty(indRef)
                error(['No station named: ',OPT.refPoint,' available. Processing stopped']);
            end
            vTstat = dataset2D.Time.data;
            WLstat = dataset2D.WatLev.data{indRef};
            
            % determine HW at reference station near the selected periods
            % and set the start and end time of the plots at HW - 7hr to HW + 7hr
            vTHW = nan(3,2);
            
            periodData = 9/( (dataset2D.Time.data(2)-dataset2D.Time.data(1)) * 24);
            sctOption.method = 'peakdet';
            sctOption.threshold = 1;
            [indexHighData,indexLowData] = TidalAnalysis.calcHwLw(dataset2D.WatLev.data{indRef},periodData,sctOption);
            
            cFix = {'HWmean';'HWspring';'HWneap'};
            for i=1:3
                [~,~,iHw,~] = EcaTool.lookupHwLwTide(datenum(OPT.(cFix{i})),vTstat,indexHighData,indexLowData,WLstat);
                %vTHW(1,2)   = vTstat(indexHighData(iHw));
                iLw1        = find(vTstat(indexLowData)<vTstat(indexHighData(iHw)),1,'last');
                iLw2        = find(vTstat(indexLowData)>vTstat(indexHighData(iHw)),1,'first');
                vTHW(i,1)   = vTstat(indexLowData(iLw1));
                vTHW(i,2)   = vTstat(indexLowData(iLw2));
            end

            % read the map output times from the selafin file
            % map outputs is in original timezone
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            for i=1:3
                % map output is in original time zone so convert the
                % requrested times (based on UTC timings) to local time
                cTHW{i} = vTHW(i,:)-OPT.dT2UTC;
            end
            telTimeStep = Telemac.getTimeSteps(sctData,cTHW);
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);

            % loop over selected periods
            nrPeriod = size(vTHW,1);
            
            if ~isempty(OPT.refmodel);
                makeDiffMaps = true;
                display(' --- loading reference map data');
                datamapRef = load(fullfile(OPT.refmodel,'0_Data','mapresults.mat'));
                IKLE = datamapRef.IKLE.data;
                X = datamapRef.X.data;
                Y = datamapRef.Y.data;
                IKLEin = sctData.IKLE;
                Xin = sctData.XYZ(:,1);
                Yin = sctData.XYZ(:,2);
                [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = EcaTool.checkInterpolations(IKLEin,Xin,Yin,OPT,X,Y,OPT.refname);
            else
                makeDiffMaps = false;
                [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = EcaTool.checkInterpolations([],[],[],OPT,[],[],[]);
            end
            
            LDB = {};
            for iL=1:numel(OPT.plotFlow.Landboundary)
                LDB = [LDB, Telemac.readKenue(OPT.plotFlow.Landboundary{iL})];
            end
            
            % if existing load 3D map file
            if exist(fullfile(OPT.outDir,'0_Data','mapresults.mat'),'file')>0
                datamap = load(fullfile(OPT.outDir,'0_Data','mapresults.mat'));
            else
                datamap.X.data      = sctData.XYZ(:,1);
                datamap.Y.data      = sctData.XYZ(:,2);
                datamap.IKLE.data   = sctData.IKLE;
                datamap.SalMax.data = {};
                datamap.SalMin.data = {};
                datamap.SalMean.data = {};
            end
            
            for iM = 1:nrMaps
                outFolderMap = fullfile(OPT.outDir,'5_Salinity',OPT.plotFlow.Frames{iM});
                if ~isdir(outFolderMap)
                    mkdir(outFolderMap);
                end
            
            nrLayers = sctData.nrLayers;

            hFig = figure;
            set(hFig,'Visible', OPT.salinityPlot.visibility);
            OPT.salinityPlot = EcaTool.figureLayout(hFig,OPT.salinityPlot);
%             plotStruct = EcaTool.figureLayout(hFig,OPT.salinityPlot);

                hold on;
                for iT = 1:nrPeriod

                    % preallocate the max velocity maps to be considered
                    % only do this for the first loop
                    if iM==1
                        datamap.SalMax.data{iT} = zeros(sctData.nrPoints,1);
                        datamap.SalMean.data{iT} = zeros(sctData.nrPoints,1);
                        datamap.SalMin.data{iT} = 999*ones(sctData.nrPoints,1);
                        nrTime = length(telTimeStep{iT});
                        datamap.Time.data{iT} = zeros(nrTime,1);                   
                        for iTime = 1:length(telTimeStep{iT})
                            sctOptions.start  = telTimeStep{iT}(iTime);
                            [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                            datamap.Time.data{iT}(iTime) = dataSet.Time.data(1)+OPT.dT2UTC;
                            datamap.SalMax.data{iT} = max(datamap.SalMax.data{iT},dataSet.Sal.data);
                            datamap.SalMin.data{iT} = min(datamap.SalMin.data{iT},dataSet.Sal.data);
                            datamap.SalMean.data{iT} = datamap.SalMean.data{iT} + 1/nrTime*dataSet.Sal.data;
                        end
                    end
                    Mask = datamap.SalMin.data{iT}==999;
                    datamap.SalMin.data{iT}(Mask) = nan;
                    
                    OPT.salinityPlot.XLim = vLimXY(iM,1:2);
                    OPT.salinityPlot.YLim = vLimXY(iM,3:4);
                    % make plot of maximum salinity

                    OPT.salinityPlot.Title = {['Maximum saliniteit (ppt) - ',OPT.name];...
                        [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                    EcaTool.makeMap(hFig,dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,datamap.SalMax.data{iT}(:,1),LDB,OPT.salinityPlot);
                    sFile = fullfile(outFolderMap,['Maximum_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                    print(hFig,sFile,'-dpng');
                    clf;
                    
                    % make plot of minimum salinity

                    OPT.salinityPlot.Title = {['Minimum saliniteit (ppt) - ',OPT.name];...
                        [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                    EcaTool.makeMap(hFig,dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,datamap.SalMin.data{iT}(:,1),LDB,OPT.salinityPlot);
                    sFile = fullfile(outFolderMap,['Minimum_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                    print(hFig,sFile,'-dpng');
                    clf;

                    % make plot of mean salinity
                    OPT.salinityPlot.XLim = vLimXY(iM,1:2);
                    OPT.salinityPlot.YLim = vLimXY(iM,3:4);
                    OPT.salinityPlot.Title = {['Mean saliniteit (ppt) - ',OPT.name];...
                        [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                    EcaTool.makeMap(hFig,dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,datamap.SalMean.data{iT}(:,1),LDB,OPT.salinityPlot);
                    sFile = fullfile(outFolderMap,['Mean_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                    print(hFig,sFile,'-dpng');
                    clf;
                                        
                    % make plot of salinity amplitude                    
                    OPT.salinityPlotAmplitude = OPT.salinityPlot;
                    OPT.salinityPlotAmplitude.vCAxis = [0 10];
                    OPT.salinityPlotAmplitude.cTick = OPT.salinityPlotAmplitude.vCAxis(1):0.5:OPT.salinityPlotAmplitude.vCAxis(2);
                    OPT.salinityPlotAmplitude.colorMap = jet(length(OPT.salinityPlotAmplitude.cTick)-1);                    
                    OPT.salinityPlotAmplitude.Title = {['Amplitude saliniteit (ppt) - ',OPT.name];...
                        [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                    EcaTool.makeMap(hFig,dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,datamap.SalMax.data{iT}(:,1)-datamap.SalMin.data{iT}(:,1),LDB,OPT.salinityPlotAmplitude);
                    sFile = fullfile(outFolderMap,['Ampitude_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                    print(hFig,sFile,'-dpng');
                    clf;
                    
                    % if difference make plot
                    if makeDiffMaps
                        SalRef          = datamapRef.SalMax.data{iT};
                        SalData         = nan(size(SalRef));
                        SalData(Ind)    = Triangle.interpTriangle(sctInterp{iM},datamap.SalMax.data{iT});
                        deltaSal        = zeros(size(SalRef));
                        deltaSal(Ind)   = SalData(Ind)-SalRef(Ind);
                        
                        OPT.salinityPlot.Title = {'Verschil in maximale saliniteit (ppt)';[OPT.name ' versus ' OPT.refname];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                        EcaTool.makeDiffMap(hFig,IKLE,X,Y,deltaSal,LDB,OPT.salinityPlot);
                        sFile = fullfile(outFolderMap,['Delta_Maximum_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        clf;
                        
                        SalRef          = datamapRef.SalMin.data{iT};
                        SalData         = nan(size(SalRef));
                        SalData(Ind)    = Triangle.interpTriangle(sctInterp{iM},datamap.SalMin.data{iT});
                        deltaSal        = zeros(size(SalRef));
                        deltaSal(Ind)   = SalData(Ind)-SalRef(Ind);
                        clf;
                        
                        OPT.salinityPlot.Title = {'Verschil in minimum saliniteit (ppt)';[OPT.name ' versus ' OPT.refname];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                        EcaTool.makeDiffMap(hFig,IKLE,X,Y,deltaSal,LDB,OPT.salinityPlot);
                        sFile = fullfile(outFolderMap,['Delta_Minimum_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        clf;
                        
                        SalRef          = datamapRef.SalMean.data{iT};
                        SalData         = nan(size(SalRef));
                        SalData(Ind)    = Triangle.interpTriangle(sctInterp{iM},datamap.SalMean.data{iT});
                        deltaSal        = zeros(size(SalRef));
                        deltaSal(Ind)   = SalData(Ind)-SalRef(Ind);
                        
                        OPT.salinityPlot.Title = {'Verschil in gemiddelde saliniteit (ppt)';[OPT.name ' versus ' OPT.refname];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                        EcaTool.makeDiffMap(hFig,IKLE,X,Y,deltaSal,LDB,OPT.salinityPlot);
                        sFile = fullfile(outFolderMap,['Delta_Mean_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        clf;
                        
                        SalRef          = datamapRef.SalMax.data{iT}-datamapRef.SalMin.data{iT};
                        SalData         = nan(size(SalRef));
                        SalData(Ind)    = Triangle.interpTriangle(sctInterp{iM},datamap.SalMax.data{iT}) - Triangle.interpTriangle(sctInterp{iM},datamap.SalMin.data{iT});
                        deltaSal        = zeros(size(SalRef));
                        deltaSal(Ind)   = SalData(Ind)-SalRef(Ind);
                        
                        OPT.salinityPlotAmplitude.Delta = OPT.salinityPlot.Delta;
                        OPT.salinityPlotAmplitude.Title = {'Verschil in amplitude saliniteit (ppt)';[OPT.name ' versus ' OPT.refname];...
                            [datestr(datamap.Time.data{iT}(1),'dd/mm/yyyy HH:MM'),' - ',datestr(datamap.Time.data{iT}(end),'dd/mm/yyyy HH:MM')]};
                        EcaTool.makeDiffMap(hFig,IKLE,X,Y,deltaSal,LDB,OPT.salinityPlotAmplitude);
                        sFile = fullfile(outFolderMap,['Delta_Amplitude_Saliniteit_',OPT.cPrefixes{iT+1},'.png']);
                        print(hFig,sFile,'-dpng');
                        clf;
                    end
                    
                end
                close;
            end
            save(fullfile(OPT.outDir,'0_Data','mapresults.mat'),'-struct','datamap');

            
            %% original script

            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFileResidual);
            sctOptions.start = sctData.nrSteps;
            [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                if ~isempty(OPT.slfFileResidualRef)
                [dataSetRef,sctDataRef,varNamesRef] = Telemac.readTelemacHeader(OPT.slfFileResidualRef);
                sctOptions.start = sctData.nrSteps;
                [dataSetRef,sctDataRef] = Telemac.readTelemacData(dataSetRef,sctDataRef,varNamesRef,sctOptions);
                X = dataSetRef.X.data;
                Y = dataSetRef.Y.data;
                nrLayersRef = sctDataRef.nrLayers;
            else
                X = [];
                Y = [];
            end
  
            [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = ...
                EcaTool.checkInterpolations(dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,OPT,X,Y,OPT.refname);
                 
            LDB = {};
            for iL=1:numel(OPT.plotFlow.Landboundary)
                LDB = [LDB, Telemac.readKenue(OPT.plotFlow.Landboundary{iL})];
            end
            
            nrLayers = sctData.nrLayers;

            hFig = figure;
            set(hFig,'Visible', OPT.salinityPlot.visibility);
            OPT.salinityPlot = EcaTool.figureLayout(hFig,OPT.salinityPlot);
            for iM=1:nrMaps
                outFolderMap = fullfile(OPT.outDir,'5_Salinity',OPT.plotFlow.Frames{iM});
                if ~isdir(outFolderMap)
                    mkdir(outFolderMap);
                end
                % plot total values
                OPT.salinityPlot.XLim = vLimXY(iM,1:2);
                OPT.salinityPlot.YLim = vLimXY(iM,3:4);
                OPT.salinityPlot.Title = {'Saliniteit (ppt) aan de bodem bij einde simulatie ';OPT.name};
                EcaTool.makeMap(hFig,dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,dataSet.Sal.data(:,1),LDB,OPT.salinityPlot);
                sFile = fullfile(outFolderMap,'Saliniteit_bodem.png');
                print(hFig,sFile,'-dpng');
                clf;
                
                OPT.salinityPlot.Title = {'Saliniteit (ppt) aan de oppervlakte bij einde simulatie ';OPT.name};
                EcaTool.makeMap(hFig,dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,dataSet.Sal.data(:,nrLayers),LDB,OPT.salinityPlot);
                sFile = fullfile(outFolderMap,'Saliniteit_oppervlakte.png');
                print(hFig,sFile,'-dpng');
                clf;
                
                OPT.salinityPlot.Title = {'Verschil in saliniteit (ppt) tussen oppervlakte en bodem bij einde simulatie ';OPT.name};
                EcaTool.makeDiffMap(hFig,dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,dataSet.Sal.data(:,nrLayers)-dataSet.Sal.data(:,1),LDB,OPT.salinityPlot);
                sFile = fullfile(outFolderMap,'Delta_Saliniteit_Bodem-Oppervlakte.png');
                print(hFig,sFile,'-dpng');
                clf;
                
                % plot differences
                if ~isempty(OPT.slfFileResidualRef)
                    % bed
                    SalRef          = dataSetRef.Sal.data(:,1);
                    SalData         = nan(size(SalRef));
                    SalData(Ind)    = Triangle.interpTriangle(sctInterp{iM},dataSet.Sal.data(:,1));
                    deltaSal        = zeros(size(SalRef));
                    deltaSal(Ind)   = SalData(Ind)-SalRef(Ind);
                    OPT.salinityPlot.Title = {'Verschil in saliniteit (ppt) aan de bodem bij einde simulatie';[OPT.name 'versus' OPT.refname]};
                    EcaTool.makeDiffMap(hFig,dataSetRef.IKLE.data,dataSetRef.X.data,dataSetRef.Y.data,deltaSal,LDB,OPT.salinityPlot);
                    sFile = fullfile(outFolderMap,'Delta_Saliniteit_bodem.png');
                    print(hFig,sFile,'-dpng');
                    clf;
                    % surface
                    SalRef          = dataSetRef.Sal.data(:,nrLayersRef);
                    SalData         = nan(size(SalRef));
                    SalData(Ind)    = Triangle.interpTriangle(sctInterp{iM},dataSet.Sal.data(:,nrLayers));
                    deltaSal        = zeros(size(SalRef));
                    deltaSal(Ind)   = SalData(Ind)-SalRef(Ind);
                    OPT.salinityPlot.Title = {'Verschil in saliniteit (ppt) aan de oppervlakte bij einde simulatie';[OPT.name 'versus' OPT.refname]};
                    EcaTool.makeDiffMap(hFig,dataSetRef.IKLE.data,dataSetRef.X.data,dataSetRef.Y.data,deltaSal,LDB,OPT.salinityPlot);
                    sFile = fullfile(outFolderMap,'Delta_Saliniteit_oppervlakte.png');
                    print(hFig,sFile,'-dpng');
                    clf;
                end
        
            end
            
        end
        
        function processDischargeTransect(OPT)
            %makes a transect plot off all discharges and compares to
            %reference run
            
            %make output directory
            outDir = fullfile(OPT.outDir,'2_Longitudinal');
            if ~exist(outDir,'dir')
                mkdir(outDir);
            end
            
            % check transects to plot
            cStatsPlot = cell(length(OPT.dischargeTransect.names),1);
            vXDistances = OPT.dischargeTransect.Distance;
            vStations = dsearchn(vXDistances,OPT.dischargeTransect.DistancePlotted);
            cStatsPlot(vStations) = strrep(OPT.dischargeTransect.names(vStations),'_',' ');

            % read transects in all files
            transData = {};
            for iFile = 1:length(OPT.dischargeTransect.transectFiles)
                transData = [transData;Telemac.readKenue(OPT.dischargeTransect.transectFiles{iFile})];
            end
            nrTrans =  length(transData);
            
            OPT.dischargeTransect = Util.setDefault(OPT.dischargeTransect,'defaultTitle','Discharge at transect ');
            OPT.dischargeTransect = Util.setDefault(OPT.dischargeTransect,'timeFormat','dd-mm');
            
            % add reference to list of files
            if iscell(OPT.slfFile2D)
                slfFiles= OPT.slfFile2D;
                nrFiles = length(slfFiles);
                legString = OPT.name;
            else
                slfFiles{1} = OPT.slfFile2D;
                nrFiles = 1;
                legString{1} = OPT.name;
            end
            if isfield(OPT,'slfFile2DRef')
                if ~isempty(OPT.slfFile2DRef)
                    nrFiles = nrFiles + 1;
                    slfFiles{nrFiles} = OPT.slfFile2DRef;
                    legString{nrFiles} = OPT.refname;
                    addRef = true;
                else
                    addRef = false;
                end
            else
                addRef = false;
            end
            
            nrPeriod = size(OPT.dischargeTransect.timLim,1);
            
             volTable = cell(nrPeriod,nrTrans+1,4*nrFiles+1); 
             for iPeriod = 1:nrPeriod
                 volTable(iPeriod,2:end,1) = OPT.dischargeTransect.names';
                 for j=1:length(legString)
                     volTable{iPeriod,1,4*(j-1)+2} = ['Flood volume [m3] ',legString{j}];
                     volTable{iPeriod,1,4*(j-1)+3} = ['Ebb volume [m3] ',legString{j}];
                     volTable{iPeriod,1,4*(j-1)+4} = ['Max flood discharge [m3/s] ',legString{j}];
                     volTable{iPeriod,1,4*(j-1)+5} = ['Max ebb discharge [m3/s] ',legString{j}];
                 end
             end
             
             emptyCell = cell(nrTrans,1);
             for iTrans = 1:nrTrans
                 emptyCell{iTrans} = '';
             end

            % loop over all selected model files

            for iFile=1:nrFiles
                
                % open telemac data file    
                sctData     = telheadr(slfFiles{iFile});
                telTimeStep = Telemac.getTimeSteps(sctData,OPT.dischargeTransect.timLim);
                [dataSet,sctData,varNames] = Telemac.readTelemacHeader(slfFiles{iFile});

                
                % loop over selected periods                
                for iPeriod = 1:nrPeriod
                    % make figures
                    if iFile ==1
                        hFig(iPeriod) = figure('visible','off');
                        OPT.dischargeTransect = EcaTool.figureLayout(hFig(iPeriod),OPT.dischargeTransect);
                    end
                    
                    nrTime = length(telTimeStep{iPeriod});
                    Q = zeros(nrTime,nrTrans);
                    t = zeros(nrTime,1);
                    % loop over seleted time steps to select data
                    for iTime = 1:length(telTimeStep{iPeriod})
                        sctOptions.start  = telTimeStep{iPeriod}(iTime);
                        [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                        t(iTime) = dataSet.Time.data(1);
                        % loop over transects
                        for jTrans=1:nrTrans
                            xT = transData{jTrans}(:,1);
                            yT = transData{jTrans}(:,2);
                            if iTime~=1
%                                 Q(iTime,jTrans) = ModelUtil.calcDischargeUnstructered(dataSet,xT,yT, sctInterp(jTrans));
                                Q(iTime,jTrans) = ModelUtil.calcDischargeUnstructered(dataSet,xT,yT,0,sctInterp(jTrans));
                            else
                                [Q(iTime,jTrans),sctInterp(jTrans)] = ModelUtil.calcDischargeUnstructered(dataSet,xT,yT);
                            end
                        end
                    end
                    
                    % calculate statistics
                    floodVol = -86400.* Integrate.trapeziumRuleNeg(t,Q)';
                    ebbVol   = 86400.* Integrate.trapeziumRulePos(t,Q)';
                    maxFloodDist = max(abs(Q.*(Q<0)));
                    maxEbbDist   = max(abs(Q.*(Q>0)));
                    
                    % fill table
                    volTable(iPeriod,2:end,2+(iFile-1)*4) = num2cell(floodVol);
                    volTable(iPeriod,2:end,3+(iFile-1)*4) = num2cell(ebbVol);
                    volTable(iPeriod,2:end,4+(iFile-1)*4) = num2cell(maxFloodDist);
                    volTable(iPeriod,2:end,5+(iFile-1)*4) = num2cell(maxEbbDist);


                    % plot figure
                    figure(hFig(iPeriod));
                    OPT.dischargeTransect = Util.setDefault(OPT.dischargeTransect,'Xlabel','Transect');
                    OPT.dischargeTransect = Util.setDefault(OPT.dischargeTransect,'Ylabel','Flood volume [m^3]');
                    hold on
                    if iFile==1
                        EcaTool.axisLayout(gca,OPT.dischargeTransect);
                        title({[OPT.dischargeTransect.defaultTitle],...
                            OPT.dischargeTransect.periodName{iPeriod},...
                            [datestr(OPT.dischargeTransect.timLim{iPeriod}(1)) , ' - ' , datestr(OPT.dischargeTransect.timLim{iPeriod}(end))]});                        
%                         Plot.namePlot(OPT.dischargeTransect.names,floodVol, '-o')
                        Plot.namePlot(cStatsPlot,vXDistances,floodVol,'-o','Linewidth',1);
                        pAx1 = get(gca,'position');
                        set(gca,'position',[pAx1(1) pAx1(2)+0.075 pAx1(3) pAx1(4)-0.075]);
                    else
%                         Plot.namePlot(emptyCell,floodVol, '-o')
                        Plot.namePlot(emptyCell,vXDistances,floodVol,'-o','Linewidth',1);
                    end

                    %set(gca,'ColorOrderIndex',get(gca,'ColorOrderIndex')-1)
                    %Plot.namePlot(OPT.dischargeTransect.names,ebbVol, ':o')
                    % custom properties that change every plot
                    
                    % add difference plot. compare the one before last with
                    % the last
                    if (addRef)
                        
                        if iFile==nrFiles
                            diffFlood = floodVolTmp{iPeriod}-floodVol;
                            %diffEbb   = ebbVolTmp-ebbVol;
                            hOld = gca;
                            hNew = UtilPlot.rightAxis(hOld,OPT.dischargeTransect.ylimDiff);
                            set(gcf,'CurrentAxes',hNew);
%                             Plot.namePlot(emptyCell,diffFlood, ':o')
                            Plot.namePlot(emptyCell,vXDistances,diffFlood,'--o','Linewidth',1);
%                             legend('Verschilvolume');
                            ylabel('Verschilvolume [m³]');
                            grid on;
                            Plot.namePlot(emptyCell,vXDistances,zeros(size(vXDistances)),'-k','Linewidth',1);
                            legend('Verschilvolume');
                            set(gcf,'CurrentAxes',hOld);
                            % add differences to the table
                            volTable(iPeriod,1,nrFiles*4+2) = {'Difference Alt - Ref'};
                            volTable(iPeriod,2:end,nrFiles*4+2) = num2cell(diffFlood);
                            % add differences to the table
                            volTable(iPeriod,1,nrFiles*4+3) = {'Percentual difference'};
                            volTable(iPeriod,2:end,nrFiles*4+3) = num2cell(100.*diffFlood./floodVol);
                        else
                            floodVolTmp{iPeriod} = floodVol;
                            %ebbVolTmp   = ebbVol;
                        end
                    end
                end
            end
            
            % saving figure
            for iPeriod = 1:nrPeriod
                % lay out
                figure(hFig(iPeriod));
                legend(legString,'Location','southwest');
                % save figure
                fileName = fullfile(outDir,['Qtransect_estuarium_',num2str(iPeriod,'%02.0f'),'.png']);
                print(fileName,'-dpng','-r300');
                close(hFig(iPeriod));
                % save Table
                % save table
                fileName = fullfile(outDir,'Qtransect_estuarium.xlsx');
                theSheet = strrep(OPT.dischargeTransect.periodName{iPeriod},' ','');
                xlswrite(fileName,squeeze(volTable(iPeriod,:,:)),theSheet);
            end
        end
        
        
        function processDischarge(OPT)
            % calculate discharges on specified transects and plots
            % timeseries
            
            
            
            
            %              OPT.telFile = 'Z:\projects\18069\Scenarios\BasicTestObc04\RES2D.slf';
            %              dischargeTransectFile = 'K:\PROJECTS\18\18069_P010011 - Blankenburgtunnel Baak\07-Uitv\calibration\transectsDischargeV2.i2s';
            
            %% calculate discharge
            
            %make output directory
            outDir = fullfile(OPT.outDir,'6_Discharge');
            if ~exist(outDir,'dir')
                mkdir(outDir);
            end
            
            % read transects in all files
            transData = {};
            for iFile = 1:length(OPT.dischargePlot.transectFiles)
                transData = [transData;Telemac.readKenue(OPT.dischargePlot.transectFiles{iFile})];
            end
            
            OPT.dischargePlot = Util.setDefault(OPT.dischargePlot,'defaultTitle','Discharge at transect ');
            OPT.dischargePlot = Util.setDefault(OPT.dischargePlot,'timeFormat','dd-mm');
            
            % add reference to list of files
            if iscell(OPT.slfFile2D)
                slfFiles= OPT.slfFile2D;
                nrFiles = length(slfFiles);
                legString = OPT.name;
            else
                slfFiles{1} = OPT.slfFile2D;
                nrFiles = 1;
                legString{1} = OPT.name;
            end
            if isfield(OPT,'slfFile2DRef')
                if ~isempty(OPT.slfFile2DRef)
                    nrFiles = nrFiles + 1;
                    slfFiles{nrFiles} = OPT.slfFile2DRef;
                    legString{nrFiles} = OPT.refname;
                    addRef = true;
                else
                    addRef = false;
                end
            else
                addRef = false;
            end
            
            % loop over all selected model files
            for iFile=1:nrFiles
                
                % open telemac data file    
                sctData     = telheadr(slfFiles{iFile});
                telTimeStep = Telemac.getTimeSteps(sctData,OPT.timLim);
                [dataSet,sctData,varNames] = Telemac.readTelemacHeader(slfFiles{iFile});

                nrPeriod = size(OPT.timLim,1);
                nrTrans =  length(transData);
                % loop over selected periods                
                for iPeriod = 1:nrPeriod
                    % make figures
                    if iFile ==1
                        hFig(iPeriod) = figure;
                        OPT.dischargePlot = EcaTool.figureLayout(hFig(iPeriod),OPT.dischargePlot);
                    end
                    
                    nrTime = length(telTimeStep{iPeriod});
                    Q = zeros(nrTime,nrTrans);
                    t = zeros(nrTime,1);
                    % loop over seleted time steps to select data
                    for iTime = 1:length(telTimeStep{iPeriod})
                        sctOptions.start  = telTimeStep{iPeriod}(iTime);
                        [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                        t(iTime) = dataSet.Time.data(1);
                        % loop over transects
                        for jTrans=1:nrTrans
                            xT = transData{jTrans}(:,1);
                            yT = transData{jTrans}(:,2);
                            if iTime~=1
                                Q(iTime,jTrans) = ModelUtil.calcDischargeUnstructered(dataSet,xT,yT,0,sctInterp(jTrans));
                            else
                                [Q(iTime,jTrans),sctInterp(jTrans)] = ModelUtil.calcDischargeUnstructered(dataSet,xT,yT);
                            end
                        end
                    end
                    
                    % plot figure
                    figure(hFig(iPeriod));
                    OPT.dischargePlot = Util.setDefault(OPT.dischargePlot,'Xlabel','Time [days]');
                    OPT.dischargePlot = Util.setDefault(OPT.dischargePlot,'Ylabel','Discharge [m^3/s]');
                    
                    for jTrans=1:nrTrans
                        hAx   = subplot(nrTrans,1,jTrans);
                        hold on                        
                        qTmp  = Q(:,jTrans);
                        plot(t,qTmp);
                        % custom properties that change every plot
                        set(hAx,'xlim',OPT.timLim{iPeriod}([1 end]));
                        set(hAx,'xtick',OPT.timLim{iPeriod});
                        if OPT.timLim{iPeriod}(end)-OPT.timLim{iPeriod}(1)>2
                            timeFormat = 'dd/mm';
                        else
                            timeFormat = 'HH:MM';
                        end
                        set(hAx,'xticklabel',datestr(OPT.timLim{iPeriod},timeFormat));
                        title({[OPT.dischargePlot.defaultTitle,OPT.dischargePlot.transectName{jTrans}],...
                            [datestr(OPT.timLim{iPeriod}(1)) , ' - ' , datestr(OPT.timLim{iPeriod}(end))]});
                    end
                    % calculate statistics (mean ebb and flood discharge
                end
            end
            for iPeriod = 1:nrPeriod
                % lay out
                 figure(hFig(iPeriod));
                 for jTrans=1:nrTrans
                        hAx   = subplot(nrTrans,1,jTrans);
                        EcaTool.axisLayout(hAx,OPT.dischargePlot);                        
                        if jTrans ==1
                            legend(legString)
                        end
                 end
                % save figure
                fileName = fullfile(outDir,['Q',num2str(iPeriod,'%02.0f'),'transect',num2str(jTrans,'%02.0f'),'.png']);
                print(fileName,'-dpng','-r300');
            end
            close;
                    
        end
        
        function processTalweg(dataset2D,OPT)
            % process output on talweg points
            %make output directory
            outDir = fullfile(OPT.outDir,'10_Talweg');
            if ~exist(outDir,'dir')
                mkdir(outDir);
            end
            
            vX = OPT.talwegPlot.Points(:,1);
            vY = OPT.talwegPlot.Points(:,2);
            dd = sqrt(diff(vX).^2+diff(vY).^2);
            vD = [0;cumsum(dd)]; % opwaarts = 0
            
            % look for indices close to observation points
            % OPT.talwegPlot.startpoint
            nrPoints = numel(OPT.talwegPlot.ObsPoints.Names);
            indPoints = nan(nrPoints,1);
            for iD = 1:nrPoints
                % look up the closest point in vD corresponding to the
                % observation points specified
                nX = OPT.talwegPlot.ObsPoints.Points(iD,1);
                nY = OPT.talwegPlot.ObsPoints.Points(iD,2);
                [~,indPoints(iD)] = min(sqrt((vX-nX).^2+(vY-nY).^2));
                if strcmp(OPT.talwegPlot.startpoint,OPT.talwegPlot.ObsPoints.Names{iD})>0
                    vD = vD-vD(indPoints(iD));
                end
            end
            % reverse order to go from downstream to upstream (now in
            % upstream to downstream order)
            vD = -vD;
            
            % limits of the plot
            OPT.talwegPlot = Util.setDefault(OPT.talwegPlot,'startplot',0);
            OPT.talwegPlot = Util.setDefault(OPT.talwegPlot,'endplot',0);
            if OPT.talwegPlot.endplot == 0
                OPT.talwegPlot.endplot = max(vD);
            end
            
            % determine time steps to be plotted (mean, spring, neap)
            % HW at reference station, 
            indRef = find(strcmp(dataset2D.Stations.data,OPT.refPoint),1,'first');
            if isempty(indRef)
                error(['No station named: ',OPT.refPoint,' available. Processing stopped']);
            end
            vTstat = dataset2D.Time.data;
            WLstat = dataset2D.WatLev.data{indRef};
           % determine HW at reference station near the selected periods
            % and set the start and end time of the plots at HW - 7hr to HW + 7hr
            vTHW = nan(3,2);
            
            periodData = 9/( (dataset2D.Time.data(2)-dataset2D.Time.data(1)) * 24);
            sctOption.method = 'peakdet';
            sctOption.threshold = 1;
            [indexHighData,indexLowData] = TidalAnalysis.calcHwLw(dataset2D.WatLev.data{indRef},periodData,sctOption);
            
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWmean),vTstat,indexHighData,indexLowData,WLstat);
            [~,iLw1,iLw2]       = EcaTool.lookupTideIndices(vTstat,indexLowData,indexHighData(iHw));
            vTHW(1,:)           = [vTstat(indexLowData(iLw1))-15/60/24,vTstat(indexLowData(iLw2))+15/60/24];
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWspring),vTstat,indexHighData,indexLowData,WLstat);
            [~,iLw1,iLw2]       = EcaTool.lookupTideIndices(vTstat,indexLowData,indexHighData(iHw));
            vTHW(2,:)           = [vTstat(indexLowData(iLw1))-15/60/24,vTstat(indexLowData(iLw2))+15/60/24];
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWneap),vTstat,indexHighData,indexLowData,WLstat);
            [~,iLw1,iLw2]       = EcaTool.lookupTideIndices(vTstat,indexLowData,indexHighData(iHw));
            vTHW(3,:)           = [vTstat(indexLowData(iLw1))-15/60/24,vTstat(indexLowData(iLw2))+15/60/24];
            
%             vTHW(1,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];            
%             [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWspring),vTstat,indexHighData,indexLowData,WLstat);
%             vTHW(2,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];
%             [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWneap),vTstat,indexHighData,indexLowData,WLstat);
%             vTHW(3,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];

            % read the map output times from the selafin file
            % map outputs is in original timezone
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            for i=1:3
                % map output is in original time zone so convert the
                % requrested times (based on UTC timings) to local time
                cTHW{i} = vTHW(i,:)-OPT.dT2UTC;
            end
            telTimeStep = Telemac.getTimeSteps(sctData,cTHW);
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            sctInterp = Triangle.interpTrianglePrepare(dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,vX,vY);
            
            if isfield(OPT,'slfFile2DRef')
                if ~isempty(OPT.slfFile2DRef)
                    [dataSetRef,sctDataRef,varNamesRef] = Telemac.readTelemacHeader(OPT.slfFile2DRef);
                    telTimeStepRef = Telemac.getTimeSteps(sctDataRef,cTHW);
                    [dataSetRef,sctDataRef,varNamesRef] = Telemac.readTelemacHeader(OPT.slfFile2DRef);
                    sctInterpRef = Triangle.interpTrianglePrepare(dataSetRef.IKLE.data,dataSetRef.X.data,dataSetRef.Y.data,vX,vY);
                    addRef = true;
                else
                    addRef = false;
                end
            else
                addRef = false;
            end
                        
            for iPeriod = 1:3
                
                vLangsMaxVloed = zeros(length(vD),2); %column1: data, column2: reference
                vLangsMaxEb = zeros(length(vD),2);
                vDwarsMaxRO = zeros(length(vD),2);
                vDwarsMaxLO = zeros(length(vD),2);
                vSalMax = zeros(length(vD),2);
                vSalMin = 40*ones(length(vD),2);
                vSalMean = zeros(length(vD),2);
                vSalAmp = zeros(length(vD),2);
                if ~addRef
                    vLangsMaxVloed(:,2) = nan; %column1: data, column2: reference
                    vLangsMaxEb(:,2) = nan;
                    vDwarsMaxRO(:,2) = nan;
                    vDwarsMaxLO(:,2) = nan;
                    vSalMax(:,2) = nan;
                    vSalMin(:,2) = nan;
                    vSalMean(:,2) = nan;
                    vSalAmp(:,2) = nan;
                end
                
                hFig = figure;
                set(gcf,'Visible', OPT.visibility);
                OPT.talwegPlot.Position = [100 100 900 900];
                OPT.talwegPlot = EcaTool.figureLayout(hFig,OPT.talwegPlot);
                
                nrTime = length(telTimeStep{iPeriod});
                t = zeros(nrTime,1);
                tRef = nan;
                cLeg = {OPT.name};
                for iTime=1:nrTime
                    sctOptions.start  = telTimeStep{iPeriod}(iTime);
                    [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                    t(iTime) = dataSet.Time.data(1)+OPT.dT2UTC;
                    WatLev = Triangle.interpTriangle(sctInterp,dataSet.WatLev.data);
                    VelX = Triangle.interpTriangle(sctInterp,dataSet.VelX.data);
                    VelY = Triangle.interpTriangle(sctInterp,dataSet.VelY.data);
                    [uCross,uAlong] = Calculate.projectVector(VelX,VelY,vX,vY); % uAlong: positive is to downstream, uCross: positive is towards leftbank
                    Sal = Triangle.interpTriangle(sctInterp,dataSet.Sal.data);
                    % check for the summarising values
                    vLangsMaxVloed(:,1) = max(vLangsMaxVloed(:,1),-uAlong); % positive is normally eb, so reverse
                    vLangsMaxEb(:,1) = max(vLangsMaxEb(:,1),uAlong);
                    vDwarsMaxRO(:,1) = max(vDwarsMaxRO(:,1),-uCross);
                    vDwarsMaxLO(:,1) = max(vDwarsMaxLO(:,1),uCross);
                    vSalMax(:,1) = max(vSalMax(:,1),Sal);
                    vSalMin(:,1) = min(vSalMin(:,1),Sal);
                    vSalMean(:,1) = vSalMean(:,1)+Sal/nrTime;
                    
                    WatLevRef = nan(size(vD));
                    uCrossRef = nan(size(vD));
                    uAlongRef = nan(size(vD));
                    SalRef = nan(size(vD));
                    if addRef
                        sctOptions.start  = telTimeStepRef{iPeriod}(iTime);
                        [dataSetRef,sctDataRef] = Telemac.readTelemacData(dataSetRef,sctDataRef,varNamesRef,sctOptions);
                        tRef(iTime) = dataSetRef.Time.data(1)+OPT.dT2UTC;
                        if tRef(iTime)==t(iTime)
                            WatLevRef = Triangle.interpTriangle(sctInterpRef,dataSetRef.WatLev.data);
                            VelX = Triangle.interpTriangle(sctInterpRef,dataSetRef.VelX.data);
                            VelY = Triangle.interpTriangle(sctInterpRef,dataSetRef.VelY.data);
                            [uCrossRef,uAlongRef] = Calculate.projectVector(VelX,VelY,vX,vY); % uAlong: positive is to downstream, uCross: positive is towards leftbank
                            SalRef = Triangle.interpTriangle(sctInterpRef,dataSetRef.Sal.data);
                            cLeg{2} = OPT.refname;
                            % check for the summarising values
                            vLangsMaxVloed(:,2) = max(vLangsMaxVloed(:,2),-uAlongRef); % positive is normally eb, so reverse
                            vLangsMaxEb(:,2) = max(vLangsMaxEb(:,2),uAlongRef);
                            vDwarsMaxRO(:,2) = max(vDwarsMaxRO(:,2),-uCrossRef);
                            vDwarsMaxLO(:,2) = max(vDwarsMaxLO(:,2),uCrossRef);
                            vSalMax(:,2) = max(vSalMax(:,2),SalRef);
                            vSalMin(:,2) = min(vSalMin(:,2),SalRef);
                            vSalMean(:,2) = vSalMean(:,2)+SalRef/nrTime;
                        end
                    end
                    
                    % make figure
                    
%                     OPT.talwegPlot.XLim = [OPT.talwegPlot.startplot OPT.talwegPlot.endplot];
%                     distxax = OPT.talwegPlot.endplot-OPT.talwegPlot.startplot;
%                     % about 10 ticks
%                     nT = ceil(distxax/10/5000)*5000;
%                     OPT.talwegPlot.XTick = ceil(min(OPT.talwegPlot.XLim)/5000)*5000:nT:floor(max(OPT.talwegPlot.XLim)/5000)*5000;
%                     OPT.talwegPlot.XLabel = ['talweg [km] vanaf ',OPT.talwegPlot.startpoint];
%                     
%                     % waterstand
%                     hAx = subplot(3,1,1); hold on;
%                     
%                     [AX,H1,H2] = plotyy(vD,WatLevRef,vD,WatLev-WatLevRef);
%                     set(H1,'color',[0.93 0.69 0.13],'linewidth',1);
%                     set(H2,'color',[0.35 0.35 0.35],'linewidth',1,'linestyle','--');
%                     plot(AX(1),vD,WatLev,'color',[0 0.45 0.74],'linewidth',1);
%                     set(AX(1),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick,'XTickLabel',OPT.talwegPlot.XTick/1000);
%                     set(AX(2),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick);
%                     set(AX(1),'ylim',[OPT.talwegPlot.wlLim(1) OPT.talwegPlot.wlLim(end)],'ytick',OPT.talwegPlot.wlLim)
%                     set(AX(2),'ylim',[OPT.talwegPlot.wldiff(1) OPT.talwegPlot.wldiff(end)],'ytick',OPT.talwegPlot.wldiff);
%                     xlabel(AX(1),OPT.talwegPlot.XLabel);
%                     ylabel(AX(1),'Waterstand [mTAW]');
%                     ylabel(AX(2),'Verschil [m]');
%                     set(AX(1),'YColor','k','fontsize',OPT.talwegPlot.FontSize); 
%                     set(AX(2),'YColor',[0.35 0.35 0.35],'fontsize',OPT.talwegPlot.FontSize);
%                     grid on ; box on;
%                     
%                     for iD = 1:length(indPoints)
%                         if (vD(indPoints(iD))>=OPT.talwegPlot.startplot)&&(vD(indPoints(iD))<=OPT.talwegPlot.endplot)
%                         text(vD(indPoints(iD)),OPT.wlLim(end)-0.05*(OPT.wlLim(end)-OPT.wlLim(1)),...
%                             OPT.talwegPlot.ObsPoints.Names{iD},'color','k',...
%                             'rotation',90,'horizontalalignment','right','verticalalignment','middle','Interpreter','none');
%                         end
%                     end
%                     
%                     title({['Talweg estuarium op ',datestr(t(iTime),'dd/mm/yyyy HH:MM')],...
%                         [OPT.name ' versus ' OPT.refname]},'fontsize',OPT.talwegPlot.FontSize+2);
%                     
%                     % langsstroming en dwarsstroming
%                     hAx = subplot(3,1,2); hold on;
%                     [AX,H1,H2] = plotyy(vD,uAlongRef,vD,uAlong-uAlongRef);
%                     [AX2,H3,H4] = plotyy(vD,uCrossRef,vD,uCross-uCrossRef);
%                     
%                     set(H1,'color',[0.93 0.69 0.13],'linewidth',1,'linestyle','-');
%                     set(H3,'color',[0.93 0.69 0.13],'linewidth',1,'linestyle','--');
%                     set(H2,'color',[0.35 0.35 0.35],'linewidth',1,'linestyle','-');
%                     set(H4,'color',[0.35 0.35 0.35],'linewidth',1,'linestyle','--');
%                     h(1) = plot(AX(1),vD,uAlong,'color',[0 0.45 0.74],'linewidth',1,'linestyle','-');
%                     h(2) = plot(AX(1),vD,uCross,'color',[0 0.45 0.74],'linewidth',1,'linestyle','--');
%                     plot(AX(1),vD,zeros(size(vD)),'color','k','linewidth',1,'linestyle','-');
%                     
%                     set(AX(1),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick,'XTickLabel',OPT.talwegPlot.XTick/1000);
%                     set(AX(2),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick,'XTickLabel',OPT.talwegPlot.XTick/1000);
%                     set(AX2(1),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick,'XTickLabel',OPT.talwegPlot.XTick/1000);
%                     set(AX2(2),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick,'XTickLabel',OPT.talwegPlot.XTick/1000);
%                     set(AX(1),'ylim',[OPT.talwegPlot.velLim(1) OPT.talwegPlot.velLim(end)],'ytick',OPT.talwegPlot.velLim);
%                     set(AX(2),'ylim',[OPT.talwegPlot.veldiff(1) OPT.talwegPlot.veldiff(end)],'ytick',OPT.talwegPlot.veldiff);
%                     set(AX2(1),'ylim',[OPT.talwegPlot.velLim(1) OPT.talwegPlot.velLim(end)],'ytick',OPT.talwegPlot.velLim)
%                     set(AX2(2),'ylim',[OPT.talwegPlot.veldiff(1) OPT.talwegPlot.veldiff(end)],'ytick',OPT.talwegPlot.veldiff);
%                                        
%                     xlabel(AX(1),OPT.talwegPlot.XLabel);
%                     xlabel(AX2(1),OPT.talwegPlot.XLabel);
%                     ylabel(AX(1),{'Stroomsnelheid [m/s]';'>0: afwaarts & naar linkoever'});
%                     ylabel(AX(2),'Verschil [m/s]');
%                     set(AX(1),'YColor','k','fontsize',OPT.talwegPlot.FontSize); 
%                     set(AX(2),'YColor',[0.35 0.35 0.35],'fontsize',OPT.talwegPlot.FontSize);
%                     set(AX2(1),'YColor','k','fontsize',OPT.talwegPlot.FontSize); 
%                     set(AX2(2),'YColor',[0.35 0.35 0.35],'fontsize',OPT.talwegPlot.FontSize);                    
%                     grid on; box on;
%                     
%                     cA = get(AX(1),'position');
%                     set(AX(2),'position',cA);
%                     set(AX2(1),'position',cA);
%                     set(AX2(2),'position',cA);
%             
%                     cL = legend(h,{'Langsstroming','Dwarsstroming'},'location','northoutside','orientation','horizontal','fontsize',OPT.talwegPlot.FontSize-2);
%                     cP = get(cL,'position');
%                     set(cL,'position',[cA(1)+cA(3)/2-cP(3)/2 cA(2)+cA(4) cP(3) cP(4)],'box','off');
%                     
%                     % saliniteit
%                     hAx = subplot(3,1,3); hold on;
%                     [AX,H1,H2] = plotyy(vD,SalRef,vD,Sal-SalRef);
%                     H3 = plot(AX(1),vD,Sal,'color',[0 0.45 0.74],'linewidth',1);
%                     set(H1,'color',[0.93 0.69 0.13],'linewidth',1);
%                     set(H2,'color',[0.35 0.35 0.35],'linewidth',1,'linestyle','--');
%                     set(AX(1),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick,'XTickLabel',OPT.talwegPlot.XTick/1000);
%                     set(AX(2),'xlim',OPT.talwegPlot.XLim,'xtick',OPT.talwegPlot.XTick);
%                     set(AX(1),'ylim',[OPT.talwegPlot.salLim(1) OPT.talwegPlot.salLim(end)],'ytick',OPT.talwegPlot.salLim)
%                     set(AX(2),'ylim',[OPT.talwegPlot.saldiff(1) OPT.talwegPlot.saldiff(end)],'ytick',OPT.talwegPlot.saldiff);
%                     xlabel(AX(1),OPT.talwegPlot.XLabel);
%                     ylabel(AX(1),'Saliniteit [ppt]');
%                     ylabel(AX(2),'Verschil [ppt]');
%                     set(AX(1),'YColor','k','fontsize',OPT.talwegPlot.FontSize); 
%                     set(AX(2),'YColor',[0.35 0.35 0.35],'fontsize',OPT.talwegPlot.FontSize);
%                     grid on ; box on;
%                                         
%                     legend([H3 H1],cLeg,'orientation','horizontal','location',[0.5-0.4 0.015 0.8 0.025],'fontsize',OPT.talwegPlot.FontSize);
%                     
%                     sFile = fullfile(OPT.outDir,'10_Talweg',['talweg_',OPT.cPrefixes{iPeriod+1},'_',datestr(t(iTime),'yyyymmdd_HHMM'),'.png']);
%                     print(hFig,sFile,'-dpng');
%                     clf;
     
                end
                close;
                
                hFig = figure;
                set(gcf,'Visible', OPT.visibility);
                OPT.talwegPlot.Position = [100 100 1200 600];
                OPT.talwegPlot = EcaTool.figureLayout(hFig,OPT.talwegPlot);

                % make figures
                OPT.talwegPlot.XLim = [OPT.talwegPlot.startplot OPT.talwegPlot.endplot];
                distxax = OPT.talwegPlot.endplot-OPT.talwegPlot.startplot;
                nT = ceil(distxax/10/5000)*5000;
                OPT.talwegPlot.XTick = ceil(min(OPT.talwegPlot.XLim)/5000)*5000:nT:floor(max(OPT.talwegPlot.XLim)/5000)*5000;
                OPT.talwegPlot.XTickLabel = OPT.talwegPlot.XTick/1000;
                OPT.talwegPlot.XLabel = ['talweg [km] vanaf ',OPT.talwegPlot.startpoint];
                                
                % langsstroming
                % make function that plots the values on y-axis and the
                % difference on the other axis
                plotOpt = OPT.talwegPlot;
                plotOpt.YLim{1} = (OPT.talwegPlot.velLim-min(OPT.talwegPlot.velLim))/2;
                plotOpt.YLim{2} = OPT.talwegPlot.veldiff;
                plotOpt.YLabel{1} = 'Maximale langsstroming [m/s]';
                plotOpt.YLabel{2} = 'Verschil [m/s]';
                plotOpt.colors{1} = [0 0.45 0.74; 0 0.45 0.74];
                plotOpt.linetype{1} = {'-';'--'};
                plotOpt.colors{2} = [0.93 0.69 0.13; 0.93 0.69 0.13];
                plotOpt.linetype{2} = {'-';'--'};
                plotOpt.colors{3} = [0.35 0.35 0.35];
                plotOpt.linetype{3} = {'-';'--'};
                plotOpt.plotZero = false;
                plotOpt.cLegend{1} = {'Vloed data';'Eb data';'Vloed referentie';'Eb referentie'}; % if empty 
                plotOpt.cLegend{2} = {'Vloed verschil';'Eb verschil'};
                plotOpt.cLegendLocation = '';
                plotOpt.sTitle = {'Verschil in maximale langsstroming langsheen talweg',...
                        [OPT.name ' versus ' OPT.refname]};
                
                [ax1, ax2] = EcaTool.makeTalwegPlot(vD,[vLangsMaxVloed(:,1) vLangsMaxEb(:,1)],...
                    [vLangsMaxVloed(:,2) vLangsMaxEb(:,2)],...
                    [vLangsMaxVloed(:,1)-vLangsMaxVloed(:,2) vLangsMaxEb(:,1)-vLangsMaxEb(:,2)],plotOpt);
                
                for iD = 1:length(indPoints)
                        if (vD(indPoints(iD))>=OPT.talwegPlot.startplot)&&(vD(indPoints(iD))<=OPT.talwegPlot.endplot)
                        text(vD(indPoints(iD)),plotOpt.YLim{1}(end)-0.025*(plotOpt.YLim{1}(end)-plotOpt.YLim{1}(1)),...
                            OPT.talwegPlot.ObsPoints.Names{iD},'color','k',...
                            'rotation',90,'horizontalalignment','right','verticalalignment','middle','Interpreter','none','Parent',ax1);
                        end
                end
                
                sFile = fullfile(OPT.outDir,'10_Talweg',['talweg_',OPT.cPrefixes{iPeriod+1},'_variatie_max_langsstroming.png']);
                print(hFig,sFile,'-dpng');               
                clf;
                
                % dwarsstroming
                plotOpt = OPT.talwegPlot;
                plotOpt.YLim{1} = (OPT.talwegPlot.velLim-min(OPT.talwegPlot.velLim))/8;
                plotOpt.YLim{2} = OPT.talwegPlot.veldiff;
                plotOpt.YLabel{1} = 'Maximale dwarsstroming [m/s]';
                plotOpt.YLabel{2} = 'Verschil [m/s]';
                plotOpt.colors{1} = [0 0.45 0.74; 0 0.45 0.74];
                plotOpt.linetype{1} = {'-';'--'};
                plotOpt.colors{2} = [0.93 0.69 0.13; 0.93 0.69 0.13];
                plotOpt.linetype{2} = {'-';'--'};
                plotOpt.colors{3} = [0.35 0.35 0.35];
                plotOpt.linetype{3} = {'-';'--'};
                plotOpt.plotZero = false;
                plotOpt.cLegend{1} = {'RO data';'LO data';'RO referentie';'LO referentie'}; % if empty 
                plotOpt.cLegend{2} = {'RO verschil';'LO verschil'};
                plotOpt.cLegendLocation = '';
                plotOpt.sTitle = {'Verschil in maximale dwarsstroming langsheen talweg',...
                        [OPT.name ' versus ' OPT.refname]};
                
                [ax1, ax2] = EcaTool.makeTalwegPlot(vD,[vDwarsMaxRO(:,1) vDwarsMaxLO(:,1)],...
                    [vDwarsMaxRO(:,2) vDwarsMaxLO(:,2)],...
                    [vDwarsMaxRO(:,1)-vDwarsMaxRO(:,2) vDwarsMaxLO(:,1)-vDwarsMaxLO(:,2)],plotOpt);
                
                for iD = 1:length(indPoints)
                        if (vD(indPoints(iD))>=OPT.talwegPlot.startplot)&&(vD(indPoints(iD))<=OPT.talwegPlot.endplot)
                        text(vD(indPoints(iD)),plotOpt.YLim{1}(end)-0.025*(plotOpt.YLim{1}(end)-plotOpt.YLim{1}(1)),...
                            OPT.talwegPlot.ObsPoints.Names{iD},'color','k',...
                            'rotation',90,'horizontalalignment','right','verticalalignment','middle','Interpreter','none','Parent',ax1);
                        end
                end
                
                sFile = fullfile(OPT.outDir,'10_Talweg',['talweg_',OPT.cPrefixes{iPeriod+1},'_variatie_max_dwarsstroming.png']);
                print(hFig,sFile,'-dpng');               
                clf;
                  
                % salinteit max, min, mean
                plotOpt = OPT.talwegPlot;
                plotOpt.YLim{1} = OPT.talwegPlot.salLim;
                plotOpt.YLim{2} = OPT.talwegPlot.saldiff;
                plotOpt.YLabel{1} = 'Saliniteit [ppt]';
                plotOpt.YLabel{2} = 'Verschil [ppt]';
                plotOpt.colors{1} = [0 0.45 0.74; 0 0.45 0.74; 0 0.45 0.74];
                plotOpt.linetype{1} = {'-';'--';'-.'};
                plotOpt.colors{2} = [0.93 0.69 0.13; 0.93 0.69 0.13; 0.93 0.69 0.13];
                plotOpt.linetype{2} = {'-';'--';'-.'};
                plotOpt.colors{3} = [0.35 0.35 0.35];
                plotOpt.linetype{3} = {'-';'--';'-.'};
                plotOpt.plotZero = false;
%                 plotOpt.cLegend{1} = {'Max sal';'Mean sal';'Min sal'}; % if empty                 
%                 plotOpt.cLegend{2} = {};
                plotOpt.cLegend{1} = {'Max sal data';'Mean sal data';'Min sal data';'Max sal referentie';'Mean sal referentie';'Min sal referentie'}; % if empty 
                plotOpt.cLegend{2} = {'Max verschil';'Mean verschil';'Min verschil'};
                plotOpt.cLegendLocation = 'southwest';
%                 plotOpt.sTitle = {'Verschil in saliniteit langsheen talweg',...
%                         [OPT.name ' versus ' OPT.refname]};
                plotOpt.sTitle = ['Saliniteit langsheen talweg: ',OPT.name];
                
                [ax1, ax2] = EcaTool.makeTalwegPlot(vD,[vSalMax(:,1) vSalMean(:,1) vSalMin(:,1)],...
                    [vSalMax(:,2) vSalMean(:,2) vSalMin(:,2)],...
                    [vSalMax(:,1)-vSalMax(:,2) vSalMean(:,1)-vSalMean(:,2) vSalMin(:,1)-vSalMin(:,2)],plotOpt);
%                 [ax1, ax2] = EcaTool.makeTalwegPlot(vD,[vSalMax(:,1) vSalMean(:,1) vSalMin(:,1)],...
%                     [],...
%                     [],plotOpt);                
                
                for iD = 1:length(indPoints)
                        if (vD(indPoints(iD))>=OPT.talwegPlot.startplot)&&(vD(indPoints(iD))<=OPT.talwegPlot.endplot)
                        text(vD(indPoints(iD)),plotOpt.YLim{1}(end)-0.025*(plotOpt.YLim{1}(end)-plotOpt.YLim{1}(1)),...
                            OPT.talwegPlot.ObsPoints.Names{iD},'color','k',...
                            'rotation',90,'horizontalalignment','right','verticalalignment','middle','Interpreter','none','Parent',ax1);
                        end
                end
                
                sFile = fullfile(OPT.outDir,'10_Talweg',['talweg_',OPT.cPrefixes{iPeriod+1},'_variatie_salinteit_v2.png']);
                print(hFig,sFile,'-dpng');               
                saveas(hFig,strrep(sFile,'png','fig'),'fig')
                clf;

                
                % saliniteit amplitude
                vSalAmp = vSalMax-vSalMin;                
                plotOpt = OPT.talwegPlot;
                plotOpt.YLim{1} = OPT.talwegPlot.salLim/2;
                plotOpt.YLim{2} = OPT.talwegPlot.saldiff;
                plotOpt.YLabel{1} = 'Amplitude saliniteit [ppt]';
                plotOpt.YLabel{2} = 'Verschil [ppt]';
                plotOpt.colors{1} = [0 0.45 0.74; 0 0.45 0.74];
                plotOpt.linetype{1} = {'-';'--'};
                plotOpt.colors{2} = [0.93 0.69 0.13; 0.93 0.69 0.13];
                plotOpt.linetype{2} = {'-';'--'};
                plotOpt.colors{3} = [0.35 0.35 0.35];
                plotOpt.linetype{3} = {'-';'--'};
                plotOpt.plotZero = false;
                plotOpt.cLegend{1} = {'data';'referentie'}; % if empty 
                plotOpt.cLegend{2} = {'verschil'};
                plotOpt.cLegendLocation = '';
                plotOpt.sTitle = {'Verschil in saliniteitsamplitude langsheen talweg',...
                        [OPT.name ' versus ' OPT.refname]};
                
               [ax1, ax2] = EcaTool.makeTalwegPlot(vD,vSalAmp(:,1),vSalAmp(:,2),vSalAmp(:,1)-vSalAmp(:,2),plotOpt);
                
                for iD = 1:length(indPoints)
                        if (vD(indPoints(iD))>=OPT.talwegPlot.startplot)&&(vD(indPoints(iD))<=OPT.talwegPlot.endplot)
                        text(vD(indPoints(iD)),plotOpt.YLim{1}(end)-0.025*(plotOpt.YLim{1}(end)-plotOpt.YLim{1}(1)),...
                            OPT.talwegPlot.ObsPoints.Names{iD},'color','k',...
                            'rotation',90,'horizontalalignment','right','verticalalignment','middle','Interpreter','none','Parent',ax1);
                        end
                end
 
                sFile = fullfile(OPT.outDir,'10_Talweg',['talweg_',OPT.cPrefixes{iPeriod+1},'_variatie_saliniteitsamplitude.png']);
                print(hFig,sFile,'-dpng');               
                clf;
                
                strTemp = struct;
                strTemp.scenarioName = OPT.name;
                strTemp.refName = OPT.refname;
                strTemp.vLangsMaxVloed = vLangsMaxVloed;
                strTemp.vLangsMaxEb = vLangsMaxEb;
                strTemp.vDwarsMaxRO = vDwarsMaxRO;
                strTemp.vDwarsMaxLO = vDwarsMaxLO;
                strTemp.vSalMax = vSalMax;
                strTemp.vSalMin = vSalMin;
                strTemp.vSalMean = vSalMean;
                strTemp.vSalAmp = vSalAmp;
                strTemp.vD = vD;
                strTemp.indPoints = indPoints;
                strTemp.Names = OPT.talwegPlot.ObsPoints.Names;
                strTemp.vXlim = [OPT.talwegPlot.startplot OPT.talwegPlot.endplot];

                save(fullfile(OPT.outDir,'0_Data',['talweg_output_',OPT.cPrefixes{iPeriod+1},'.mat']),'-struct','strTemp');

            end
            close;
            
        end
        
        function [ax1,ax2] = makeTalwegPlot(vX,vData,vRef,vDiff,plotOpt)
            % function to make longplots adding data, reference data and
            % difference on the second axis (if not empty)
            nrData = size(vData,2);
            nrRef = size(vRef,2);
            nrDiff = size(vDiff,2);
            h1 = nan(nrData+nrRef,1);
            h2 = nan(nrDiff,1);
            
            if isempty(plotOpt.cLegendLocation)
            ax1 = subplot(1,4,1:3); hold on;
            end
            [AX,H1,H2] = plotyy(vX,vRef(:,1),vX,vDiff(:,1));
            hold(AX(1));
            hold(AX(2));
            set(H1,'color',plotOpt.colors{2}(1,:),'linewidth',1.5,'linestyle',plotOpt.linetype{2}{1});
            set(H2,'color',plotOpt.colors{3}(1,:),'linewidth',1,'linestyle',plotOpt.linetype{3}{1});
            h1(nrData+1) = H1;
            h2(1) = H2;
            hold on;
            for iD=2:nrRef
                h1(nrData+iD) = plot(AX(1),vX,vRef(:,iD),'color',plotOpt.colors{2}(iD,:),'linewidth',1.5,'linestyle',plotOpt.linetype{2}{iD});
            end            
            for iD=1:nrData
                h1(iD) = plot(AX(1),vX,vData(:,iD),'color',plotOpt.colors{1}(iD,:),'linewidth',1.5,'linestyle',plotOpt.linetype{1}{iD});
            end
            for iD = 2:nrDiff
                h2(iD) = plot(AX(2),vX,vDiff(:,iD),'color',plotOpt.colors{3}(1,:),'linewidth',1,'linestyle',plotOpt.linetype{3}{iD});
            end
            if plotOpt.plotZero
                plot(AX(1),vX,zeros(size(vX)),'-k');
            end

            set(AX(1),'xlim',plotOpt.XLim,'xtick',plotOpt.XTick,'XTickLabel',plotOpt.XTickLabel);
            set(AX(2),'xlim',plotOpt.XLim,'xtick',plotOpt.XTick,'XTickLabel',plotOpt.XTickLabel);
            set(AX(1),'ylim',[plotOpt.YLim{1}(1) plotOpt.YLim{1}(end)],'ytick',plotOpt.YLim{1});
            set(AX(2),'ylim',[plotOpt.YLim{2}(1) plotOpt.YLim{2}(end)],'ytick',plotOpt.YLim{2});

            xlabel(AX(1),plotOpt.XLabel);
            ylabel(AX(1),plotOpt.YLabel{1});
            ylabel(AX(2),plotOpt.YLabel{2});

            set(AX(1),'YColor','k','fontsize',plotOpt.FontSize);
            set(AX(2),'YColor',plotOpt.colors{3}(1,:),'fontsize',plotOpt.FontSize);
            grid on; box on;
            title(plotOpt.sTitle,'fontsize',plotOpt.FontSize+1);
            
            if isempty(plotOpt.cLegendLocation)          
                ax2 = subplot(1,4,4); hold on;
                cL = legend(ax2,[h1;h2],[plotOpt.cLegend{1};plotOpt.cLegend{2}],'location','northwest','fontsize',plotOpt.FontSize);
                axis off
            else
                cL = legend([h1;h2],[plotOpt.cLegend{1};plotOpt.cLegend{2}],'location',plotOpt.cLegendLocation,'fontsize',plotOpt.FontSize);
                ax1 = AX(1);
                ax2 = [];
            end
%
            

        end
        
        function scaleAxisTicks(hAx,nScale)
            xt=get(hAx,'xtick');
            xt={xt};
            set(hAx,'xticklabel',cellfun(@(x) x*nScale,xt,'UniformOutput',false));
            yt=get(hAx,'ytick');
            yt={yt};
            set(hAx,'yticklabel',cellfun(@(x) x*nScale,yt,'UniformOutput',false));
        end
        
        function figOpt = figureLayout(hFig,figOpt)
            % set options for figure layout
            figOpt = Util.setDefault(figOpt,'PaperPositionMode','auto');
            figOpt = Util.setDefault(figOpt,'Position',[100 100 1600 1000]);
            %figOpt = Util.setDefault(figOpt,'PaperPosition',[100 100 1600 1000]);
            [~,normalProp] = EcaTool.figProp();
             for i=1:length(normalProp)
                propName = normalProp{i};
                if isfield(figOpt,propName)
                    set(hFig,propName,figOpt.(propName));
                end
            end
        end
        
        function axisOpt = defaultLayout(axisOpt)
            % default layout options
            axisOpt = Util.setDefault(axisOpt,'XGrid','on');
            axisOpt = Util.setDefault(axisOpt,'YGrid','on');
            axisOpt = Util.setDefault(axisOpt,'FontSize',10);
            axisOpt = Util.setDefault(axisOpt,'Box','on');
            axisOpt = Util.setDefault(axisOpt,'timeFormat','dd-mm');
        end
        
        function axisLayout(hAx,axisOpt)
            %set axis properties
            axisOpt = EcaTool.defaultLayout(axisOpt);
            % optionally set user defined properties
            [textProp,axProp] = EcaTool.axisProp();
            for i=1:length(axProp)
                propName = axProp{i};
                if isfield(axisOpt,propName)
                    set(hAx,propName,axisOpt.(propName));
                end
            end
            % optionally set user defined texts
            % TODO: individually change properties
            for i=1:length(textProp)
                propName = textProp{i};
                if isfield(axisOpt,propName)
                    hAx.(propName).String = axisOpt.(propName);
                end
            end            
            
        end
        
        function [textProp,normalProp] = figProp()
            % function to get editable figure properties
            textProp  = {};
            normalProp = {'PaperPosition','PaperPositionMode','PaperSize','Position'};
        end
        
        function [textProp,normalProp] = axisProp()
            % function to get editable axis properties
            textProp = {'Title','XLabel','XTickLabel','YLabel','YTickLabel'};
            normalProp = {'FontName', 'FontUnits', 'FontSize', 'FontAngle',...
                'FontWeight','FontSmoothing','TickLabelInterpreter', ...
                'XLim','XLimMode','YLim','YLimMode','XDir','YDir',...
                'CLim','CLimMode','ALim','ALimMode','ColorOrder',...
                'ColorOrderIndex','LineStyleOrder','LineStyleOrderIndex',...
                'TickDir','TickDirMode',   'TickLength','GridLineStyle',...
                'MinorGridLineStyle','GridColor','GridColorMode','MinorGridColor','MinorGridColorMode',...
                'GridAlpha','GridAlphaMode','MinorGridAlpha','MinorGridAlphaMode',...
                'XAxisLocation','XColor','XColorMode','XTick','XTickMode','XTickLabelRotation', ...
                'XScale', 'XTickLabelMode','XMinorTick','YAxisLocation','YColor','YColorMode', ...
                'YTick','YTickMode','YTickLabelRotation',  'YScale', 'YTickLabelMode','YMinorTick',...
                'BoxStyle','LineWidth','Color','SortMethod',  ...
                'TitleFontWeight','TitleFontSizeMultiplier','LabelFontSizeMultiplier',...
                'XGrid','XMinorGrid','YGrid','YMinorGrid','ZGrid','ZMinorGrid','Box'};
            
        end
        
        function rotatedAxisTicks(hAx,cTicks,nRot)
            % function to set the ticklabels and axis right when rotating
            % the ticks
            set(hAx,'xticklabel',cTicks);
            vAxPos = get(hAx,'position');
            set(hAx,'position',[vAxPos(1) vAxPos(2)*3 vAxPos(3) vAxPos(4)-vAxPos(2)*2]);
            rotateticklabel(hAx,nRot);
        end
        
        function cM = setDeltaColor(hAx,vCAxis,nTick,sColorbarLabel,nFontSize) 
            % function to make a delta colormap, set it to the figure and
            % add a colorbar
            
            if nargin<5
                nFontSize = 10;
            end
            if isempty(nTick)
                vYt = vCAxis;
            else
                vYt = vCAxis(1):nTick:vCAxis(2);
            end
            nCpos = sum(vYt>0)-1;
            nCneg = sum(vYt<0)-1;
            % blue colors (min 2) (negative values)
            cMb   = [0.02 0.03 0.49;0.73 0.83 0.96];
            cMbt  = [linspace(cMb(1,1),cMb(2,1),nCneg)' linspace(cMb(1,2),cMb(2,2),nCneg)' linspace(cMb(1,3),cMb(2,3),nCneg)'];
            % red colors (min 2) (positive values)
            cMr   = [0.93 0.84 0.84;0.64 0.08 0.18];
            cMrt  = [linspace(cMr(1,1),cMr(2,1),nCpos)' linspace(cMr(1,2),cMr(2,2),nCpos)' linspace(cMr(1,3),cMr(2,3),nCpos)'];
            if ~isempty(find(vYt==0,1))
                cMmid = [1 1 1; 1 1 1];
            else
                cMmid = [1 1 1];
            end
            cM    = [cMbt;cMmid;cMrt];
            if ~isempty(hAx)
                colormap(hAx,cM);
                cb=colorbar(hAx);
                caxis(hAx,vCAxis);
                cYt = cellfun(@(x) num2str(x,'%.2f'), num2cell(vYt), 'UniformOutput', false);
                cYt{1} = '';
                cYt{end} = '';
                set(cb,'ytick',vYt,'yticklabel',cYt);
                
                if ~isempty(sColorbarLabel)
                    ylabel(cb,sColorbarLabel,'fontsize',nFontSize);
                end
            end
            
        end
        
        function hAx = makeMap(hG,IKLE,X,Y,VAR,LDB,plotStruct)
            
            % prepare everything
            if isempty(hG)
                figure;
                hG = gca;
            else
                if isgraphics(hG,'figure')
                    figure(hG);
                    hG = gca;
                else
                    axes(hG)
                end
            end
            if ~isfield(plotStruct,'colorMap')
                plotStruct.colorMap = jet;
            end
            if ~isfield(plotStruct,'vCAxis')
                plotStruct.vCAxis = [min(VAR(:)) max(VAR(:))];
            end
            % start plotting
            hold on;
            axis equal;
            EcaTool.axisLayout(hG,plotStruct);
            hold on;
            Plot.plotTriangle(X, Y, VAR, IKLE);
            shading interp;
            colormap(plotStruct.colorMap);
            cb=colorbar;
            caxis([plotStruct.vCAxis(1) plotStruct.vCAxis(end)]);
            vCbTick = get(cb,'ytick');
            plotStruct = Util.setDefault(plotStruct,'cTick',vCbTick);
            set(cb,'ytick',plotStruct.cTick);
            for iL=1:numel(LDB)
                plot(LDB{iL}(:,1),LDB{iL}(:,2),'-k','linewidth',2);
            end
            % finish plot
            if isfield(plotStruct,'vScaleAxis')
                EcaTool.scaleAxisTicks(hG,plotStruct.vScaleAxis);
            end
            hAx = hG;
        end
        
        function [nrMaps,vLimXY,vThinXY,vScale,Ind,mX,mY,sctInterp] = checkInterpolations(IKLEin,Xin,Yin,OPT,X,Y,refRun)
                % function to prepare interpolations based on input excel,
                % reference mesh and coordinates to be interpolated to
                %
                % INPUT:
                % - IKLEin: connection of vectors input mesh
                % - Xin: vector with x coordinates mesh
                % - Yin: vector with y coordinates mesh
                % - OPT: needs to contain OPT.plotFlow.excelFrames,
                % OPT.plotFlow.Frames, OPT.outDir
                % - X: optional - direct specification of vector with x coordinates to be interpolated on
                % - Y: optional - direct specification of vector with y coordinates to be interpolated on
                % - refRun: optional - to interpolate to another mesh, 
                % if specified the script will search
                % if there is already an interpolation with this name. If
                % empty the script will check the excel file on the
                % required interpolation names and matrices
                %
                % OUTPUT:
                % - nrMaps: number of maps to be visualised
                % - vLimXY: matrix with limits per map
                % - vThinXY: thinning of X and Y matrix (only relevant for vectors)
                % - vScale: scaling of vectors (only relevant for vectors)
                % - Ind: (in case of refRun) indices of the X,Y that are in the max range of
                % vLimXY (in case of no refRun is empty).
                % - mX: matrix to be interpolated on per map or for the
                % refRun
                % - mY: matrix to be interpolated on per map or for the
                % refRun
                % - sctInterp: interpolation matrix per map or for the
                % refRun
                
                if nargin<5
                    X = [];
                    Y = [];
                    refRun = [];
                end
                
                % interpolate both meshes on the same grid
                % interpolate on reference mesh
                % check if this is already done before
                % check required interpolations
                [numFr,txtFr,~] = xlsread(OPT.plotFlow.excelFrames);
                indTitle = find(strcmp(txtFr(:,1),'Title'),1,'first');
                cInterps = txtFr(2:indTitle-1,1);
                cExtTitles = txtFr(indTitle+1:end,1);
                if isempty(refRun)
                    cExtInterps = txtFr(indTitle+1:end,6);
                else
                    % refRun is specified: overrule
                    cExtInterps = cellstr(repmat(refRun,numel(cExtTitles),1));
                end
                nrMaps = numel(OPT.plotFlow.Frames);
                vLimXY = zeros(nrMaps,4);
                vThinXY = ones(nrMaps,2);
                vScale = ones(nrMaps,1);
                mX = cell(nrMaps,1);
                mY = cell(nrMaps,1);
                indExtent = nan(nrMaps,1);
                sctInterp = cell(nrMaps,1);
                % read frame information
                
                for iM = 1:nrMaps
                    indExtent(iM) = find(strcmp(OPT.plotFlow.Frames{iM},cExtTitles),1,'first');
                    vLimXY(iM,:) = numFr(indExtent(iM)+indTitle-1,1:4);
                    vThinXY(iM,:) = numFr(indExtent(iM)+indTitle-1,6:7);
                    vScale(iM) = numFr(indExtent(iM)+indTitle-1,8);
                        
                    if isempty(refRun)
                        % make the interpolation matrix for all the maps,
                        % in case of the reference frame only one
                        % interpolation matrix has to be made
                        
                        % read map information
                        indInterp = find(strcmp(cExtInterps{indExtent(iM)},cInterps),1,'first');
                        vX = numFr(indInterp,1):numFr(indInterp,5):numFr(indInterp,2);
                        vY = numFr(indInterp,3):numFr(indInterp,6):numFr(indInterp,4);
                        [mX{iM},mY{iM}] = meshgrid(vX,vY);
                                                
                    end
                     
                end
                
                % make largest extent when using refRun
                Ind = [];
                if ~isempty(refRun)    
                    Ind = find(X>=min(vLimXY(:,1))-1000 & X<=max(vLimXY(:,2))+1000 &...
                        Y>=min(vLimXY(:,3))-1000 & Y<=max(vLimXY(:,4))+1000);
                    vX{1} = X(Ind);
                    vY{1} = Y(Ind);
                    mX = repmat(vX,nrMaps,1);
                    mY = repmat(vY,nrMaps,1);
                end
                
                % check if all required interps are already there.
                % If not start creating them
                if exist(fullfile(OPT.outDir,'0_Data','sctInterp.mat'),'file')>0
                    Interp = load(fullfile(OPT.outDir,'0_Data','sctInterp.mat'));
                else
                    Interp = struct;
                    Interp.Names = {};
                    Interp.sctInterp = {};
                    Interp.X = {};
                    Interp.Y = {};
                    Interp.sType = {};
                end
                    
                % interpolation matrix
                makeInterp = true;
                for iM = 1:nrMaps
                    indData = [];
                    if numel(Interp.Names)>0
                        indData = find(strcmp(cExtInterps{indExtent(iM)},Interp.Names),1,'first');
                        if ~isempty(indData)
                            makeInterp = false;
                            sctInterp{iM} = Interp.sctInterp{indData};
                            mXt = Interp.X{indData};
                            mYt = Interp.Y{indData};
                            if abs(length(mX{iM}(:))-length(mXt(:)))>0 || abs(length(mY{iM}(:))-length(mYt(:)))>0
                                warning('interpolation matrices dont agree, matrix will be overwritten with new one');
                                makeInterp = true;
                            end
                        end
                    end
                    if makeInterp
                        if isempty(indData)
                            indData = numel(Interp.Names)+1;
                        end
                        if ~isempty(refRun)
                            Interp.sType{indData} = 'Unstructured';
                        else
                            Interp.sType{indData} = 'Structured';
                        end
                        Interp.Names{indData} = cExtInterps{indExtent(iM)};
                        Interp.X{indData} = mX{iM};
                        Interp.Y{indData} = mY{iM};
                        Interp.sctInterp{indData} = Triangle.interpTrianglePrepare(IKLEin,Xin,Yin,mX{iM}(:),mY{iM}(:));
                        sctInterp{iM} = Interp.sctInterp{indData};
                    end
                end   
                
                % save data so it can be read next time
                if ~isdir(fullfile(OPT.outDir,'0_Data'))
                    mkdir(fullfile(OPT.outDir,'0_Data'))
                end
                save(fullfile(OPT.outDir,'0_Data','sctInterp.mat'),'-struct','Interp');
                
                
        end
        
        function makeDiffMap(hFig,IKLE,X,Y,VAR,LDB,plotStruct)
                
            a = EcaTool.makeMap(hFig,IKLE,X,Y,VAR,LDB,plotStruct);
            figure(hFig);
            cb_hand1 = findall(hFig, 'Tag', 'Colorbar');
            plotStruct.Delta = Util.setDefault(plotStruct.Delta,'caxis',get(cb_hand1,'Limits'));
            plotStruct.Delta = Util.setDefault(plotStruct.Delta,'colorbarTick',get(cb_hand1,'Ticks'));
            plotStruct.Delta = Util.setDefault(plotStruct.Delta,'sColorbarLabel','');
            
            EcaTool.setDeltaColor(a,plotStruct.Delta.caxis,...
                plotStruct.Delta.colorbarTick,plotStruct.Delta.sColorbarLabel,plotStruct.Delta.FontSize)

        end
        
        function [hAx1,hAx2] = makeMapQuiverTide(hFig,IKLE,X,Y,VAR,mX,mY,U,V,LDB,vT,vVar,OPT)
            
            figure(hFig);
            hAx1 = subplot(4,1,[1 3]);
            hold on;
            axis equal;
            EcaTool.axisLayout(hAx1,OPT);
            Plot.plotTriangle(X, Y, VAR, IKLE);
            shading interp;
            caxis(OPT.vCAxis);
            colormap(OPT.colorMap);
            colorbar;
            % check if there is data in U and V
            if ~isempty(U) && ~isempty(V)
                mag = sqrt(U.^2+V.^2);
                % apply vector thinning:
                mask = (mag<1e-12)|(isnan(U))|(isnan(V));
                mX(mask)=nan;
                mY(mask)=nan;              
                if OPT.vThreshold>0
                   U = U./max(mag,OPT.vThreshold);
                   V = V./max(mag,OPT.vThreshold);
                end
                Xc = mX(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                Yc = mY(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                U = U(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                V = V(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                qm = quiver(Xc,Yc,OPT.vScale*U,OPT.vScale*V,0);
                set(qm,'color',[0 0 0],'linewidth',1.25);
            end
            % add lanboundaries
            for iL=1:numel(LDB)
                plot(LDB{iL}(:,1),LDB{iL}(:,2),'-k','linewidth',2);
            end
            % finish plot
            title(OPT.Title,'Fontsize',OPT.FontSize)
            EcaTool.scaleAxisTicks(hAx1,OPT.vScaleAxis);
            %vAx1Pos = get(hAx,'position');
            
            % time series plot
            hAx2 = subplot(4,1,4); hold on;            
            EcaTool.axisLayout(hAx2,OPT.Tide);
            plot(vT,vVar,'-b','linewidth',1.5);
            hold on;
            plot(repmat(OPT.Tide.nT,[1 2]),OPT.Tide.YLim,'-r','linewidth',1.5);
            % Limieten, titels, legenda
            datetick(gca,'x','HH:MM','keeplimits','keepticks');
            vAx2Pos = get(gca,'position');
            % lower position to avoid the title is covering the xlabels of
            % the map
            set(hAx2,'position',[vAx2Pos(1) vAx2Pos(2)-0.05 vAx2Pos(3) vAx2Pos(4)]);
            title(OPT.Tide.Title,'Fontsize',OPT.Tide.FontSize,'Interpreter','none'); % NEDERLANDS
            
        end
        
        function [hAx1,hAx2,hAx3,hAx4] = make2MapQuiverTide(hFig,...
                IKLEref,Xref,Yref,VARref,mXref,mYref,Uref,Vref,LDBref,vTref,vVarref,OPTref,...
                IKLE,X,Y,VAR,mX,mY,U,V,LDB,vT,vVar,OPT)
            
            figure(hFig);
            
            hAx1 = subplot(4,2,[1 3 5]);
            hold on;
            axis equal;
            EcaTool.axisLayout(hAx1,OPTref);
            Plot.plotTriangle(Xref, Yref, VARref, IKLEref);
            shading interp;
            caxis(OPTref.vCAxis);
            colormap(OPTref.colorMap);
            colorbar;
            % check if there is data in U and V
            if ~isempty(Uref) && ~isempty(Vref)
                mag = sqrt(Uref.^2+Vref.^2);
                % apply vector thinning:
                mask = (mag<1e-12)|(isnan(Uref))|(isnan(Vref));
                mXref(mask)=nan;
                mYref(mask)=nan;              
                if OPTref.vThreshold>0
                   Uref = Uref./max(mag,OPTref.vThreshold);
                   Vref = Vref./max(mag,OPTref.vThreshold);
                end
                Xc = mXref(1:OPTref.veMN(1):end,1:OPTref.veMN(2):end);
                Yc = mYref(1:OPTref.veMN(1):end,1:OPTref.veMN(2):end);
                Uref = Uref(1:OPTref.veMN(1):end,1:OPTref.veMN(2):end);
                Vref = Vref(1:OPTref.veMN(1):end,1:OPTref.veMN(2):end);
                qm = quiver(Xc,Yc,OPTref.vScale*Uref,OPTref.vScale*Vref,0);
                set(qm,'color',[0 0 0],'linewidth',1.25);
            end
            % add lanboundaries
            for iL=1:numel(LDBref)
                plot(LDBref{iL}(:,1),LDBref{iL}(:,2),'-k','linewidth',2);
            end
            % finish plot
            title(OPTref.Title,'Fontsize',OPTref.FontSize)
            EcaTool.scaleAxisTicks(hAx1,OPTref.vScaleAxis);
            %vAx1Pos = get(hAx,'position');
            
            % time series plot
            hAx2 = subplot(4,2,7); hold on;            
            EcaTool.axisLayout(hAx2,OPTref.Tide);
            plot(vTref,vVarref,'-b','linewidth',1.5);
            hold on;
            plot(repmat(OPTref.Tide.nT,[1 2]),OPTref.Tide.YLim,'-r','linewidth',1.5);
            % Limieten, titels, legenda
            datetick(gca,'x','HH:MM','keeplimits','keepticks');
            vAx2Pos = get(gca,'position');
            % lower position to avoid the title is covering the xlabels of
            % the map
            set(hAx2,'position',[vAx2Pos(1) vAx2Pos(2)-0.05 vAx2Pos(3) vAx2Pos(4)]);
            title(OPTref.Tide.Title,'Fontsize',OPTref.Tide.FontSize,'Interpreter','none'); % NEDERLANDS            
            
            % 2e figuur:
            
            hAx3 = subplot(4,2,[2 4 6]);
            hold on;
            axis equal;
            EcaTool.axisLayout(hAx3,OPT);
            Plot.plotTriangle(X, Y, VAR, IKLE);
            shading interp;
            caxis(OPT.vCAxis);
            colormap(OPT.colorMap);
            colorbar;
            % check if there is data in U and V
            if ~isempty(U) && ~isempty(V)
                mag = sqrt(U.^2+V.^2);
                % apply vector thinning:
                mask = (mag<1e-12)|(isnan(U))|(isnan(V));
                mX(mask)=nan;
                mY(mask)=nan;              
                if OPT.vThreshold>0
                   U = U./max(mag,OPT.vThreshold);
                   V = V./max(mag,OPT.vThreshold);
                end
                Xc = mX(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                Yc = mY(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                U = U(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                V = V(1:OPT.veMN(1):end,1:OPT.veMN(2):end);
                qm = quiver(Xc,Yc,OPT.vScale*U,OPT.vScale*V,0);
                set(qm,'color',[0 0 0],'linewidth',1.25);
            end
            % add lanboundaries
            for iL=1:numel(LDB)
                plot(LDB{iL}(:,1),LDB{iL}(:,2),'-k','linewidth',2);
            end
            % finish plot
            title(OPT.Title,'Fontsize',OPT.FontSize)
            EcaTool.scaleAxisTicks(hAx3,OPT.vScaleAxis);
            %vAx1Pos = get(hAx,'position');
            
            % time series plot
            hAx4 = subplot(4,2,8); hold on;            
            EcaTool.axisLayout(hAx4,OPT.Tide);
            plot(vT,vVar,'-b','linewidth',1.5);
            hold on;
            plot(repmat(OPT.Tide.nT,[1 2]),OPT.Tide.YLim,'-r','linewidth',1.5);
            % Limieten, titels, legenda
            datetick(gca,'x','HH:MM','keeplimits','keepticks');
            vAx2Pos = get(gca,'position');
            % lower position to avoid the title is covering the xlabels of
            % the map
            set(hAx4,'position',[vAx2Pos(1) vAx2Pos(2)-0.05 vAx2Pos(3) vAx2Pos(4)]);
            title(OPT.Tide.Title,'Fontsize',OPT.Tide.FontSize,'Interpreter','none'); % NEDERLANDS
            
            
        end
        
        function sct = collectCrossSection(dataset3D,vInd,indT)
            sFields = fields(dataset3D);
            for iI=1:length(vInd)
                for iT=indT
                    for iS = 1:numel(sFields)
                        switch sFields{iS}
                            case 'X'
                                sct.X(:,iI) = squeeze(dataset3D.X.data(vInd(iI)));
                            case 'Y'
                                sct.Y(:,iI) = squeeze(dataset3D.Y.data(vInd(iI)));
                            case 'VelX'
                                sct.VelX(:,iI) = squeeze(dataset3D.VelX.data{vInd(iI)}(:,iT));
                            case 'VelY'
                                sct.VelY(:,iI) = squeeze(dataset3D.VelY.data{vInd(iI)}(:,iT));
                            case 'VelZ'
                                sct.VelZ(:,iI) = squeeze(dataset3D.VelZ.data{vInd(iI)}(:,iT));
                            case 'Sal'
                                sct.Sal(:,iI) = squeeze(dataset3D.Sal.data{vInd(iI)}(:,iT));
                            case 'Z'
                                sct.Z(:,iI) = squeeze(dataset3D.Z.data{vInd(iI)}(:,iT));
                        end
                    end
                end
            end
            
            
        end
        
        function makeCrossSection(X,Z,VAR,OPT)
            
            %             contourf(repmat(transpose(dataset3D.Time.data),20,1),dataset3D.Z.data{10},uCross);
            %             colorbar
            %             grid on;
            %             EcaTool.setDeltaColor(gca);
            
            % figure; contourf(repmat(transpose(dataset3D.Time.data),20,1),dataset3D.Z.data{10},dataset3D.Sal.data{10}); colorbar
            % dynamicDateTicks; grid on;
            
            % figure; contourf(repmat(transpose(dataset3D.Time.data),20,1),dataset3D.Z.data{10},uCross); colorbar
            % EcaTool.setDeltaColor(gca,[-0.5 0.5],0.1,'(<0) inflow            outflow (>0)')
            % dynamicDateTicks; grid on;
        end
        
        function stats = processStatisticsFields(dataset2D,var,OPT)
            % function to process the statistics of the map output of a run
            % INPUTS:
            %         - dataset2D: input data in Telemac format
            %         - var: name of variable to process in dataset2D, if
            %         components of a vector need to be combined specify
            %         them in a cell array: {'VelX','VelY'}
            %         - OPT: options
            % OUTPUTS:
            %         - stats with dimensions length(X) x 3 (mean, spring, neap) 
            %           containing: stats.X, stats.Y, stats.IKLE, stats.min, stats.mean, stats.max
            
            % determine time steps to be plotted (mean, spring, neap)
            % HW at reference station, 
            indRef = find(strcmp(dataset2D.Stations.data,OPT.refPoint),1,'first');
            if isempty(indRef)
                error(['No station named: ',OPT.refPoint,' available. Processing stopped']);
            end
            vTstat = dataset2D.Time.data;
            WLstat = dataset2D.WatLev.data{indRef};
            
            % determine HW at reference station near the selected periods
            % and set the start and end time of the plots at HW - 7hr to HW + 7hr
            vTHW = nan(3,2);
            
            periodData = 9/( (dataset2D.Time.data(2)-dataset2D.Time.data(1)) * 24);
            sctOption.method = 'peakdet';
            sctOption.threshold = 1;
            [indexHighData,indexLowData] = TidalAnalysis.calcHwLw(dataset2D.WatLev.data{indRef},periodData,sctOption);
            
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWmean),vTstat,indexHighData,indexLowData,WLstat);
            vTHW(1,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];
            
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWspring),vTstat,indexHighData,indexLowData,WLstat);
            vTHW(2,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];
            
            [~,~,iHw,~]                                     = EcaTool.lookupHwLwTide(datenum(OPT.HWneap),vTstat,indexHighData,indexLowData,WLstat);
            vTHW(3,:)                                       = [vTstat(indexHighData(iHw))-7/24,vTstat(indexHighData(iHw))+7/24];
            
            % read the map output times from the selafin file
            % map outputs is in original timezone
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            for i=1:3
                % map output is in original time zone so convert the
                % requrested times (based on UTC timings) to local time
                cTHW{i} = vTHW(i,:)-OPT.dT2UTC;
            end
            telTimeStep = Telemac.getTimeSteps(sctData,cTHW);
            [dataSet,sctData,varNames] = Telemac.readTelemacHeader(OPT.slfFile2D);
            
            % loop over selected periods
            nrPeriod = size(vTHW,1);
            
            stats = struct;
            stats.X = sctData.XYZ(:,1);
            stats.Y = sctData.XYZ(:,2);
            stats.IKLE = sctData.IKLE;
            stats.times = cTHW;
            stats.min = 1e30*ones(length(stats.X),nrPeriod);
            stats.mean = zeros(length(stats.X),nrPeriod);
            stats.max = -1e30*ones(length(stats.X),nrPeriod);
            val = zeros(length(stats.X),1);
            
            for iT = 1:nrPeriod
                for iTime = 1:length(telTimeStep{iT})
                    sctOptions.start  = telTimeStep{iT}(iTime);
                    [dataSet,sctData] = Telemac.readTelemacData(dataSet,sctData,varNames,sctOptions);
                    datamap.Time.data{iT}(iTime) = dataSet.Time.data(1)+OPT.dT2UTC;
                    if iscell(var)
                        if numel(var)>1
                            val1 = dataSet.(var{1}).data;
                            val2 = dataSet.(var{2}).data;
                            val = sqrt(val1.^2+val2.^2);
                        else
                            val = dataSet.(var).data;
                        end
                    else
                        val = dataSet.(var).data;
                    end
                    stats.min(:,iT) = min(stats.min(:,iT),val);
                    stats.max(:,iT) = max(stats.max(:,iT),val);
                    stats.mean(:,iT) = stats.mean(:,iT)+val/length(telTimeStep{iT});
                end
            end
            
            stats.min(stats.min==1e30) = nan;
            stats.max(stats.max==-1e30) = nan;
        end
                    
    end
end