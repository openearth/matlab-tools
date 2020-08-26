classdef CosaTool < handle
    %CosaTool Coastal Safety Tool
    
    
    %Public properties
    properties
        Property1;
    end
    
    properties(Constant)
        seedNumbers = [12345678 12345001:12345010];
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
        
        
        
        function [calibTable] = autoCalibrate1D2D(calibTable,iter,opt)
            % Pick new calibration values for Swash automatic 1D-2D
            % calibration
            opt = Util.setDefault(opt,'Hm0Tolerance',0.03);
            opt = Util.setDefault(opt,'Tmm10Tolerance',0.05);
            
            opt = Util.setDefault(opt,'SetupTolerance',0.05);
            
          
            
            if ~any(strcmp('Hm0',calibTable.Properties.VariableNames))
                calibTable.Hm0(iter) = calibTable.targetHm0(iter)*2;
                calibTable.swl(iter) = calibTable.targetSetup;
                calibTable.Hm0Diff(iter,1) = inf;
                calibTable.setupDiff(iter,1) = inf;
                calibTable.Tmm10Diff = inf;
            elseif iter>1
                setupDiff = calibTable.modelSetup(iter-1)-calibTable.swl(iter-1);
                alpha = (setupDiff./calibTable.Hm0(iter-1)); %Alpha=  setup/hOff --> rule of thumb, typically order of 10 -20% for fully broken waves
                
                if calibTable.Tp(iter-1)==calibTable.Tp(iter) %Only do following rows if iter>1.
                    
                    % Tolerances
                    warning off
                    calibTable.Hm0Diff(iter-1,1) = (calibTable.modelHm0(iter-1)/calibTable.targetHm0(iter-1) - 1);
                    calibTable.Tmm10Diff(iter-1,1) = (calibTable.modelTmm10(iter-1)/calibTable.targetTmm10(iter-1) - 1);
                    
                    calibTable.setupDiff(iter-1,1) = (calibTable.modelSetup(iter-1) - calibTable.targetSetup(iter-1));
                    warning on
                    
                    if abs(calibTable.Hm0Diff(iter-1)) <= opt.Hm0Tolerance && abs(calibTable.setupDiff(iter-1)) <= opt.SetupTolerance
                        calibTable.convergedExclTmm10(iter-1) =true;
                        if  abs(calibTable.Tmm10Diff(iter-1)) <= opt.Tmm10Tolerance
                            calibTable.convergedInclTmm10(iter-1) = true;
                        else
                            calibTable.convergedInclTmm10(iter-1) = false;
                        end
                        
                        
                    else
                        calibTable.convergedExclTmm10(iter-1) = false;
                        calibTable.convergedInclTmm10(iter-1) = false;
                        
                    end
                end
                % Calculate new values for offshore wave height and swl,
                % using black magic and voodoo.
                hm0New = interp1(calibTable.modelHm0(end-1:end),calibTable.Hm0(end-1:end),calibTable.targetHm0(end),'linear','extrap');
                if hm0New<0
                    hm0New = calibTable.Hm0(iter-1)*0.8;
                end
                hm0New = max(min(hm0New,1.25*calibTable.Hm0(iter-1)),0.75*calibTable.Hm0(iter-1));
                setupNew= alpha*hm0New;
                swlNew = calibTable.targetSetup(iter-1) - setupNew ;
                % Correction on the wave height because zNew is changed:
                hm0New = hm0New + 0.08*(calibTable.modelSetup(iter-1)-calibTable.targetSetup(iter-1));
                
                calibTable.Hm0(iter) = hm0New;
                calibTable.swl(iter) = swlNew;
            end
            
        end
        
        function [calibTable] = calibSwash1D(opt)
            % [calibTable] = calibSwash1D(opt)
            %
            % Swash 1D calibration
            %
            %
            % Inputs: opt structure, containing:
            %     opt.outputFolder Results folder (where the table will be saved);
            %     opt.maxIter Maximum iterations. Default = 10;
            % Outputs:
            % output %Structure with relevant outputs
            %
          
            opt = Util.setDefault(opt,'offshoreWGInputfile','gauge5mTAW.wvg');
            opt = Util.setDefault(opt,'dykeToeWGInputfile','gaugeDykeToe.wvg');
            opt = Util.setDefault(opt,'bottomFile','swash.bot');
            opt = Util.setDefault(opt,'maxIter',15);
            opt = Util.setDefault(opt,'analysisDur',100*60);
            opt = Util.setDefault(opt,'smooth',1);
            opt = Util.setDefault(opt,'isEnsemble',false);
            opt = Util.setDefault(opt,'reducedHm0Log', 0);
            opt = Util.setDefault(opt,'modifiedHm0Offshore',0);
            
            filesToCopy = {
                'bottomFile'
                'offshoreWGInputfile'
                'dykeToeWGInputfile'
                };
            
            fprintf('SWASH 1D Calibration of profile %s.\n',opt.RunName);
            
            %Output folder
            opt.outputFolder = fullfile(opt.resultsRootFolder,opt.RunName);
            if opt.isEnsemble
                opt.outputFolder = fullfile(opt.outputFolder,'ensembles',sprintf('ensemble_%02u',opt.ensembleNumber));
            end
            if ~exist(opt.outputFolder,'dir')>0
                mkdir(opt.outputFolder)
            end
            
            % Prepare calibration table
            calibTableFile = fullfile(opt.outputFolder,'calibtable.csv');
            calibTable = table;
            calibTable.convergedExclTmm10 = false;
            calibTable.convergedInclTmm10 = false;
            currentOffshoreTp = opt.offshoreTp1D;
            % If doing ensemble modelling, do as first guess the
            % results from all finished ensembles
            if opt.isEnsemble 
                iter=1;
                calibTable.Hm0(iter) = opt.offshoreHm01D; %This is the calibrated value from the first (non-ensemble) run
                calibTable.swl(iter) = opt.swl1D; %This is the calibrated value from the first (non-ensemble) run
                calibTable.Hm0Diff(iter,1) = inf;
                calibTable.setupDiff(iter,1) = inf;
                calibTable.Tmm10Diff = inf;
            end    
 
            iter=1;

            while iter <= opt.maxIter && ~calibTable.convergedInclTmm10(end)
                
                while iter <= opt.maxIter && ~calibTable.convergedExclTmm10(end)
                    % Put target values in table
                    warning off;
                    calibTable.iter(iter) = iter; %Lots of iters
                    warning on;
                    calibTable.targetHm0(iter) = opt.dikeToeHm02D;
                    calibTable.targetTmm10(iter) = opt.dikeToeTmm102D;
                    calibTable.targetSetup(iter) = opt.dikeToeSetup2D;
                    calibTable.Tp(iter) = currentOffshoreTp;
                                      
                    calibOpt = struct;
                    calibTable = CosaTool.autoCalibrate1D2D(calibTable,iter,calibOpt);
                    
                    % If the Hm0 has been changed because of Tm-1,0 (See below, 'If not converged includ Tm-1,0')
                    
                    if opt.modifiedHm0Offshore > 0 
                        calibTable.Hm0(end) = opt.modifiedHm0Offshore;
                    end
                    
                    if iter > 1 && calibTable.convergedExclTmm10(iter-1) && calibTable.Tp(iter-1)==calibTable.Tp(iter) && opt.modifiedHm0Offshore == 0
                        calibTable(iter,:)=[];
                        if ~calibTable.convergedInclTmm10(iter-1)
                            fprintf('Profile %s has converged for Hm0 and setup but not for period. Will adjust automatically.\n',opt.RunName);
                        end
                        continue;
                    end
                    
                    if opt.modifiedHm0Offshore > 0
                         opt.modifiedHm0Offshore = 0 ; 
                    end
                    
                    calibTable.directory{iter} = fullfile(char(opt.Swash1DCalibRootRunFolder),...
                        char(sprintf('1D_calib_%s_iter%03u',opt.RunName,iter)));
                    calibTable.filename{iter} = 'calib1d.sws';
                    calibTable.nx(iter) = opt.nxCalib;
                    calibTable.lenx(iter) = opt.lenxCalib;
                    
                    if opt.isEnsemble
                        calibTable.seedText(iter) = {sprintf('SET SEED %u',...
                            opt.seedNumber)};
                    else
                        calibTable.seedText(iter)= {''};
                    end
                    % Write Swash input file
                    Swash.writeInput(opt.calib1dProtorun,table2struct(calibTable(iter,:)));
                    
                    % Create directory if it does not exist 
                    
                    if ~exist(calibTable.directory{iter},'dir')
                        mkdir(calibTable.directory{iter});
                    end
                
                    % Copy bathy files
                    for iF = 1:numel(filesToCopy)
                        copyfile(fullfile(opt.bathyRunFolder,opt.RunName,opt.(filesToCopy{iF})),...
                            fullfile(calibTable.directory{iter},opt.(filesToCopy{iF})));
                    end
                    
                    % Run Swash for this iteration
                    curDir = pwd;
                    cd(calibTable.directory{iter})
                    fprintf('Running SWASH... ');
                    [~,file1] = fileparts(calibTable.filename{iter});
                    [status,cmdout] = system(['swashrun ' file1]);
                    if status~=0;
                        warning(cmdout);
                    end
                    cd(curDir);
                    fprintf('SWASH finished.\n');
                    
                    % Postprocess
                    resOpt.runFolder = calibTable.directory{iter};
                    resOpt.dykeToeWGResultfile = opt.dykeToeWGResultfile;
                    resOpt.steeringFile = calibTable.filename{iter};
                    resOpt.analysisDur = opt.analysisDur;
                    resOpt.plotResults = false;
                    
                    res = CosaTool.swashStandardPostprocess(resOpt);
                    
                    % Put results in calibration table
                    calibTable.modelHm0(iter) = res.toeGauge.Hm0;
                    calibTable.modelTmm10(iter) = res.toeGauge.Tmm10;
                    calibTable.modelSetup(iter) = res.toeGauge.setup;
                    
                    % Display output
                    calibTable = calibTable(:,{'iter','convergedExclTmm10','convergedInclTmm10','targetHm0','modelHm0','Hm0Diff',...
                        'targetSetup','modelSetup','setupDiff','Tmm10Diff','targetTmm10','modelTmm10',...
                        'Tp','Hm0','swl','directory','filename','nx','lenx'});
                    disp(calibTable)
                    
                    
                    % Update iteration counter
                    iter = iter+1;
                end
                
                % If not converged incl. Tmm10
                if ~calibTable.convergedInclTmm10(end);
                    if abs(calibTable.Tmm10Diff(end)) > 0 & opt.reducedHm0Log == 0  % If the model Tmm-1,0 is higher than the target, try first to reduce the wave height a bit before changing Tp
                         opt.modifiedHm0Offshore = calibTable.Hm0(end)/(1+0.05+calibTable.Hm0Diff(end));
                         opt.reducedHm0Log  =  1;
                    else                                                            % If it doesnt work, then go with Tp
                         currentOffshoreTp = currentOffshoreTp / (1+calibTable.Tmm10Diff(end)*0.75);
                         opt.modifiedHm0Offshore = 0;
                         opt.reducedHm0Log  =  0;
                    end
                    calibTable.convergedExclTmm10(end)=false;
                end
            end
            
            % Display output
            calibTable = calibTable(:,{'iter','convergedExclTmm10','convergedInclTmm10','targetHm0','modelHm0','Hm0Diff',...
                'targetSetup','modelSetup','setupDiff','targetTmm10','modelTmm10','Tmm10Diff',...
                'Tp','Hm0','swl','directory','filename','nx','lenx'});
            disp(calibTable)

            writetable(calibTable,calibTableFile);
            
            % Make output figures of final iteration
            if opt.plotResults
                
                if ~exist('resOpt')
                    resOpt.runFolder = calibTable.directory{1};
                    resOpt.steeringFile = calibTable.filename{1};
                    resOpt.analysisDur = opt.analysisDur;
                    resOpt.dykeToeWGResultfile = opt.dykeToeWGResultfile;
                    
                end                
                    
                resOpt.plotResults = opt.plotResults;
                resOpt.offshoreWGResultfile = opt.offshoreWGResultfile;
                resOpt.dykeToeWGResultfile = opt.dykeToeWGResultfile;
                resOpt.blockResultfile = opt.blockResultfile;
                resOpt.resultsRootFolder = opt.resultsRootFolder;
                resOpt.outputFolder = opt.outputFolder;
                resOpt.RunName = opt.RunName;
                resOpt.smooth = opt.smooth;
                resOpt.ProfileFile = opt.ProfileFile;
                resOpt.xOffset = opt.xOffset;
                resOpt.DykeToeX = opt.DykeToeX;
                resOpt.DykeTopX = opt.DykeTopX;
                resOpt.plotOverviewFig = false;
                                
                CosaTool.swashStandardPostprocess(resOpt);
            end
        end
        
        function [calibTable] = calibSwash1DEnsemble(opt)
            % [] = calibSwash1DEnsemble(opt)
            %
            % Swash 1D calibration for ensemble runs
            %
            % Inputs: opt structure, containing:
            %     opt.outputFolder Results folder (where the table will be saved);
            %     opt.maxIter Maximum iterations. Default = 10;
            % Outputs:
            % output %Structure with relevant outputs
            %
            opt = Util.setDefault(opt,'numEnsemble',7);
            
            % Make table of ensembles
            allEns = struct2table(opt);
            allEns.Swash1DCalibRootRunFolder = string(allEns.Swash1DCalibRootRunFolder);
            allEns.ensembleNumber = 1;
            allEns.isEnsemble = false;
            % Trim a bit
            allEns.seedNumber = CosaTool.seedNumbers(1);
            % Reorder table columns. Only works after for MATLAB 2018a and later but
            % that's OK, it's only a lay-out thing
            ver = version('-release');
            if str2double(ver(1:4))>=2018
                allEns = movevars(allEns,'ensembleNumber','After','RunName');
                allEns = movevars(allEns,'seedNumber','After','ensembleNumber');
            end
            
            % Loop over all ensembles
            for iEns = 2:opt.numEnsemble+1; %Loop over all ensembles
                fprintf('Ensemble number %i.\n',iEns);
                
                allEns(iEns,:) = allEns(1,:); %Make new row in table
                allEns.convergedExclTmm10(iEns)=false;
                allEns.convergedInclTmm10(iEns)=false;
                
                
                allEns(iEns,:).ensembleNumber = iEns;
                allEns(iEns,:).isEnsemble = true;
                allEns(iEns,:).seedNumber =  CosaTool.seedNumbers(iEns);
                allEns.Swash1DCalibRootRunFolder(iEns) = fullfile(...
                    char(allEns.Swash1DCalibRootRunFolder(1)),'ensembles',sprintf('ensemble%u',iEns));
                
                allEns.offshoreHm01D(iEns) = mean(allEns.offshoreHm01D(1:iEns-1));
                allEns.swl1D(iEns) = mean(allEns.swl1D(1:iEns-1));
                calibTable = CosaTool.calibSwash1D(table2struct(allEns(iEns,:)));
                
                allEns.offshoreHm01D(iEns) = calibTable.Hm0(end);
                allEns.offshoreTp1D(iEns) = calibTable.Tp(end);
                allEns.swl1D(iEns) = calibTable.swl(end);
                allEns.convergedExclTmm10(iEns) = calibTable.convergedExclTmm10(end);
                allEns.convergedInclTmm10(iEns) = calibTable.convergedInclTmm10(end);
                allEns.dikeToeTmm101D(iEns) = calibTable.modelTmm10(end);
                allEns.Tmm10Diff(iEns) = calibTable.Tmm10Diff(end);
                allEns.offshoreTp1D(iEns) = calibTable.Tp(end);
                writetable(allEns,fullfile(opt.resultsRootFolder,opt.RunName,'ensembles.csv'));
                
            end
            
            
            
        end
        
        
        function [xprof,yprof,iprof,jprof] = defineProfGraph(ds,opt)
            % [xprof,yprof,iprof,jprof] = defineProfGraph(ds, opt)
            %
            % graphically determine profiles
            %Defaults
            if nargin ==1;
                opt = struct;
            end;
            opt = Util.setDefault(opt,'interp',true);
            
            x = ds.X.data;
            y = ds.Y.data;
            z = squeeze(ds.BotDep.data(end,:,:));
            
            % plot data
            figure;
            pcolor(x,y,z);
            axis equal;
            xlabel('x [m]')
            ylabel('y [m]')
            
            
            
            % get start and end coordinates
            i = 1;
            xprof = [];
            yprof = [];
            hold on;
            if opt.interp
                title({'Click 2 point (start and end) per profile.'
                    'Will interpolate lines between start and end.'
                    'Right-click to end.'});
            else
                title({'Click 1 point per profile. Will automatically draw cross-shore profiles.'
                    'Right-click to end.'});
            end
            while true
                
                % start coordinate
                [x0,y0,w] = ginput(1);
                if w~=1
                    break;
                end
                plot(x0,y0,'mo','markerfacecolor','m')
                text(x0,y0,num2str(i),'fontsize',9,'color','k')
                if opt.interp;
                    % end coordinate
                    [x1,y1,w] = ginput(1);
                    if w~=1
                        break;
                    end
                    
                    plot(x1,y1,'mo','markerfacecolor','m')
                    plot([x0 x1],[y0 y1],'m-','linewidth',1.5)
                    text(x0,y0,num2str(i),'fontsize',6,'color','k')
                else
                    x1 = x0;
                    y1 = y0;
                end
                xprof(i,1) = x0; %#ok<AGROW>
                xprof(i,2) = x1; %#ok<AGROW>
                yprof(i,1) = y0; %#ok<AGROW>
                yprof(i,2) = y1; %#ok<AGROW>
                i = i + 1;
                
            end
            % get i and j from the data
            iprof = nan(size(xprof));
            jprof = nan(size(xprof));
            
            for iCol = 1:size(xprof,2)
                [iprof(:,iCol),jprof(:,iCol)]  = Interpolate.getIndNearest(...
                    xprof(:,iCol),yprof(:,iCol),ds.X.data,ds.Y.data);
            end
            %             [iprof,jprof]  = Interpolate.getIndNearest(xprof,yprof,x,y);
            
        end
        
        function [vOffset] = duneOffset(xOffset,sctInput,Xlocs,prof);
            if xOffset<0;
                vOffset = 9e9;
                return;
            end
            xHi=prof.dist';
            zHi = prof.bath';
            
            zHi2a = interp1(prof.dist,prof.bath,xHi-xOffset);
            
            zHi2 = min([zHi;zHi2a]);
            zHi3 = max([zHi2;sctInput.criticalwl*ones(size(zHi2))]);
            zHi3(xHi>=Xlocs.Xw.X)=zHi(xHi>=Xlocs.Xw.X);
            zDiff = zHi-zHi3;
            zDiff(xHi>=Xlocs.Xw.X)=0;
            zDiff(zDiff<0)=0;
            
            vOffset = trapz(xHi,zDiff);
            
        end
        
        
        
        function  [] = dunePostProcess(sctInput)
            
            sctInput = Util.setDefault(sctInput,'duneProfile','NoBuildings');

            % Post processing of the dune assessment - Figures
                        
            if isstring(sctInput.prof) == 1
               prof = sctInput.prof{1};
            else
               prof = sctInput.prof;
            end
            
            UtilPlot.reportFigureTemplate(15,10);
            plot(prof.dist(:),prof.bathInit(:),'color',[0 0.5 0]);
            
            hold on
            grid on
            box on
            plot(prof.dist(:),prof.bath(:),'r')
            plot([prof.dist(1) prof.dist(end)],[sctInput.criticalwl sctInput.criticalwl],'b')
            plot([sctInput.Xlocs.Xd.X,sctInput.Xlocs.Xd.X],[sctInput.criticalwl max(prof.bathInit)],'k--')
            text(sctInput.Xlocs.Xd.X-2,max(prof.bathInit),'X_d','horizontalalignment','right','FontSize',9);
            
            plot([sctInput.Xlocs.Xe.X,sctInput.Xlocs.Xe.X],[sctInput.criticalwl max(prof.bathInit)+0.5],'k--')
            text(sctInput.Xlocs.Xe.X+1,max(prof.bathInit)+0.5,'X_e','horizontalalignment','left','FontSize',9);
            
            plot([sctInput.Xlocs.Xv.X,sctInput.Xlocs.Xv.X],[sctInput.Xlocs.Xv.Z max(prof.bathInit)],'k--')
            text(sctInput.Xlocs.Xv.X-2,max(prof.bathInit),'X_v','horizontalalignment','right','FontSize',9);
            
            %Blue patch

            patch(sctInput.Xlocs.bluePolygonx,sctInput.Xlocs.bluePolygony,'b','LineWidth',1);
            
            
            blueVol = polyarea(sctInput.Xlocs.bluePolygonx,sctInput.Xlocs.bluePolygony);
            blueVol/(sctInput.erodedArea*0.25)                                                                      % Check on blue patch area
            
            if strcmp(sctInput.duneProfile,'NoBuildings') == 1                                                      % Points exclusively for the No building case
                
                plot([sctInput.Xlocs.Xw.X,sctInput.Xlocs.Xw.X],[sctInput.criticalwl max(prof.bathInit)+2],'k--')
                text(sctInput.Xlocs.Xw.X+2,max(prof.bathInit)+2,'X_w','horizontalalignment','left','FontSize',9);    
                
                if isfield(sctInput.Xlocs,'magentaPolygonx')
                    % Magenta patch
                    patch(sctInput.Xlocs.magentaPolygonx,sctInput.Xlocs.magentaPolygony,'m','LineWidth',1);

                    purpleVol = polyarea(sctInput.Xlocs.magentaPolygonx,sctInput.Xlocs.magentaPolygony);
                    purpleVol/(sctInput.minimumArea)                                                                     % Check on magenta patch area
                end
                
            elseif strcmp(sctInput.duneProfile,'Buildings') == 1
            
                plot([sctInput.Xlocs.A.X,sctInput.Xlocs.A.X],[sctInput.Xlocs.A.Z max(prof.bathInit)],'k--')
                text(sctInput.Xlocs.A.X-2,max(prof.bathInit)-0.5,'A','horizontalalignment','right','FontSize',9);
                
                if sctInput.Xlocs.C.X == sctInput.Xlocs.Xe.X
                    plot([sctInput.Xlocs.Xe.X,sctInput.Xlocs.Xe.X],[sctInput.criticalwl max(prof.bathInit)+0.5],'k--')
                    text(sctInput.Xlocs.Xe.X-2,max(prof.bathInit)+0.5,'X_e = C ','horizontalalignment','right','FontSize',9);
                else
                    plot([sctInput.Xlocs.C.X,sctInput.Xlocs.C.X],[sctInput.criticalwl max(prof.bathInit)+0.5],'k--')
                    text(sctInput.Xlocs.C.X-1,max(prof.bathInit)-0.5,'C ','horizontalalignment','left','FontSize',9);
                end
                
                plot([sctInput.Xlocs.A.X, sctInput.Xlocs.Xv.X],[sctInput.Xlocs.A.Z, sctInput.Xlocs.C.Z],'-m','LineWidth',1.5)
                plot([sctInput.Xlocs.A.X, sctInput.Xlocs.B.X],[sctInput.Xlocs.A.Z, sctInput.Xlocs.B.Z],'-m','LineWidth',1.5)
            end
            
            
            ylim([(sctInput.criticalwl*0.85) max(prof.bathInit*1.2)])
            
            match=closest(max(prof.bathInit),prof.bathInit(:));
            index=find(prof.bathInit(:)==match,1,'last');
            
            match2=closest(sctInput.criticalwl,prof.bathInit(:));
            index2=find(prof.bathInit(:)==match2,1,'first');
            
            if isfield(sctInput.Xlocs,'Xv')
                xlim([prof.dist(index2,1)*0.85 sctInput.Xlocs.Xv.X+5]);
            else
                xlim([prof.dist(index2,1)*0.85 prof.dist(index,1)*1.05]);
            end
            
            legend('Pre-storm profile','Post-storm profile','Critical water level','location','southwest')
            ylabel('z [m TAW]','fontsize',9);
            xlabel('x [x]','fontsize',9);
            
            p1 = [0.15   0.6445    0.32   0.27];
            
            dataStr11=  sprintf('Stability Characteristics\nDune ratio (post-storm)\nPost-storm dune height (m)\nTheoretical dune height (m)\nCritical Water Level (m TAW)\nEroded area(m^2)');
            
            txt11   = annotation('textbox','units','normalized',...
                'Position',p1,'horizontalalignment','left',...
                'String',dataStr11,'interpreter','tex','fontsize',8);
            
            
            dataStr12=  sprintf('\n%.2f { }\n%.2f { }\n%.2f { }\n%.2f { }\n%.2f { }',...
                sctInput.duneRatio,sctInput.heightDune,sctInput.minimumHeight,sctInput.criticalwl,sctInput.erodedArea);
            txt22  = annotation('textbox','units','normalized',...
                'Position',p1,'horizontalalignment','right',...
                'String',dataStr12,'interpreter','tex','fontsize',8);
            
            txt11   = annotation('textbox','units','normalized',...
                'Position',p1,'horizontalalignment','left',...
                'String',dataStr11,'interpreter','tex','fontsize',8);
            
            title(sctInput.RunName, 'Interpreter', 'none');
            
            if exist ('..\Xbeach\postproc\DuneAssessment') ~= 7
                mkdir '..\Xbeach\postproc\DuneAssessment'
            end
            
            if isstring(sctInput.prof) == 1
                UtilPlot.saveFig(fullfile('..\Xbeach\postproc\DuneAssessment',sctInput.RunName{1}));
                savefig(fullfile('..\Xbeach\postproc\DuneAssessment',sctInput.RunName{1}));
            else
                UtilPlot.saveFig(fullfile('..\Xbeach\postproc\DuneAssessment',sctInput.RunName));
                savefig(fullfile('..\Xbeach\postproc\DuneAssessment',sctInput.RunName));
            end

        end
        
        function [duneRatio,erodedArea] = duneAssessment(sctInput)
            % function to do the dune assessment according to the
            % methodology of the coastal safety plan flanders
            
            erodedArea = sctInput.originalDune-sctInput.poststormDune;
            duneRatio =(sctInput.poststormDune -(0.25*erodedArea))/sctInput.minimumArea;
            
        end
        
        function height_dune = CalcHeightDune(sctInput,bathy)
            
            wl = sctInput.criticalwl;
            
            maxheight = max(bathy.Z(min(find(bathy.X>=sctInput.xStartDune)):max(find(bathy.X<=sctInput.xEndDune))));
            height_dune = maxheight-wl;
            
        end
        
        function minimumHeight = calcMinHeight(sctInput)
            minimumHeight = 0.12*sctInput.offshoreTp2D_Xbeach*sqrt(sctInput.offshoreHm02D_Xbeach);
        end
        
        function minimumArea =calcMinDune(sctInput)
            minimumHeight = CosaTool.calcMinHeight(sctInput);
            minimumArea=(1.5*minimumHeight^2)+(3*minimumHeight);
        end
        
        function original_dune = calcDune(sctInput)
            % function to calculate the volume change in the island
            
            wl = sctInput.criticalwl;
            
            prof = sctInput.prof;
            pos_end=find(prof.dist<=sctInput.duneEnd,1,'last');
            pos_start=find(prof.dist>=sctInput.duneStart,1,'first');
            
            prof=prof(pos_start:pos_end,:);
            
            
            x = prof.dist;
            y = prof.bathInit-wl;
            y(y<0)=0;
            
            original_dune = trapz(x,y);
        end
        
        function poststormDune = calcErodedDune(sctInput)
            % function to calculate the volume change in the island
            wl = sctInput.criticalwl;
            
            prof = sctInput.prof;
            posEnd = find(prof.dist<=sctInput.duneEnd,1,'last');
            posStart = find(prof.dist>=sctInput.duneStart,1,'first');
            prof = prof (posStart:posEnd,:);
            
            x = prof.dist;
            y = prof.bath-wl;
            y(y<0) = 0;
            poststormDune = trapz(x,y);
        end
        
        function Xlocs = calcXpoints(sctInput)
            %% [] = calcXpoints (sctInput)
            % Calculates Xd, Xe, Xv and Xw from the Xbeach output for a no building case (as defined in Methodologie kustveiligheidstoets, 2016)
            % Calculates Xd, Xe, Xv, A,B and C for a building case (as defined in Methodologie kustveiligheidstoets, 2016)
                        
            sctInput = Util.setDefault(sctInput,'duneProfile','NoBuildings');
                                 
%             posEnd = find(sctInput.prof.dist<=sctInput.duneEnd,1,'last');                % Grid point of dune start. For Building case, take the safety line
%             posStart = find(sctInput.prof.dist>=sctInput.duneStart,1,'first');           % Grid point of dune end
%             
%             prof = sctInput.prof(posStart:posEnd,:);
            prof = sctInput.prof;
            
            % Firstly, calculate the points that are common for both the building and the No building case (i.e. Xd, Xe and Xv)
            %% Xv: location of the safety line  
            
            if strcmp(sctInput.duneProfile,'NoBuildings') == 1
                safLine = 7;                                                              % Safety line at +7 m TAW
                posXvMinus1 = find(prof.bath-safLine>0,1,'last');                         % Grid point Xv-1 
                posXvPlus1 = posXvMinus1+1;                                               % Grid point Xv+1 

                %Interpolation between the following grid point and the previous grid point
                 
                if posXvPlus1 <= length(prof.bath)                    
                    Xlocs.Xv.X = interp1([prof.bath(posXvMinus1),prof.bath(posXvPlus1)],[prof.dist(posXvMinus1),prof.dist(posXvPlus1)],safLine);
                else 
                    Xlocs.Xv.X = prof.dist(end);
                end 
                    
                Xlocs.Xv.Z = safLine;    
            else                                                                         % If it is not to be cut off at the + 7, take the last point along the profile. building must therefore be clipped beforehand
                Xlocs.Xv.X = sctInput.prof.dist(end);
                Xlocs.Xv.Z = sctInput.prof.bath(end);
            end
           
         
            %% Xd: intersection of the critical water level and the remaining dune - Common for dune with building and dune without building
            
            posXdPlus1 = find(prof.bath>=sctInput.criticalwl,1,'first');                  % Grid point Xd+1       
            posXdMinus1 = posXdPlus1-1;                                                   % Grid point Xd-1                 
             
           
            % Interpolation between the following grid point and the previous grid point
            
            if ~isempty(posXdMinus1)
                Xlocs.Xd.X = interp1([prof.bath(posXdMinus1),prof.bath(posXdPlus1)],[prof.dist(posXdMinus1),prof.dist(posXdPlus1)],sctInput.criticalwl);
                Xlocs.Xd.Z = sctInput.criticalwl;
            else
                Xlocs.Xd.X = prof.dist(end);
                Xlocs.Xd.Z = prof.bath(end);
            end

            
            %% XeSimp: most landward point where dune erosion occurs (without toeslag)

                erosionMargin = 0.01;                                                        % Margin so that it does not take very small variations between bathInit and bath as erosion
                posErosion = find(prof.bathInit-prof.bath>erosionMargin,1,'last')+1;             

                if posErosion > length(prof.dist)
                    Xlocs.XeSimp.X = prof.dist(end);
                    Xlocs.XeSimp.Z = prof.bath(end);
                else
                    Xlocs.XeSimp.X = prof.dist(posErosion);
                    Xlocs.XeSimp.Z = prof.bath(posErosion);
                end
                
            %% Xe: more landward point where dune erosion occurs (including toeslag). Find offset for blue area - Extra erosion volume
                      
            % Calculation of Xe by iteratively shifting the eroded profile to the seaward direction


                y = prof.bath-sctInput.criticalwl;                                                 % y variable for area calculation (eroded bathy - critical wl)
                y(y<0) = 0;   


                iterArea = 0;                                                                      % Area for iteration 
                iterAreaCheck = 0;
                erosionPlus = 0.25*sctInput.erodedArea;                                            % Extra erosion (toeslag)

                j=0;                                                                               % Grid point for iteration

                while iterArea < erosionPlus         
                    j = j+1;           
                    yIter = y;                                                                     % Elevation of shifted profile
                    yIter(j+1:end) = y(1:end-j);                                                   % y is shifted in an iterative process (iter * dx to the right)
                    yIter(1:j) = 0;                                                                % yIter vector is completed with 0's at the beginning
                    yIter(min(find(yIter>y)):end) =  y(min(find(yIter>y)):end);                    % yIter when it exceedes y is set to y
                    iterArea = trapz(prof.dist,y-yIter);

                    if iterArea == iterAreaCheck                                                   % Check if the area does not increase, then it is checking already seaward of the dune, then stop the sim
                       Xlocs.bluePolygony = [];
                       Xlocs.bluePolygonx = [];
                       break
                    else
                       iterAreaCheck = iterArea;
                    end               

                end

                if max(find(yIter<y))< length(yIter)
                    Xlocs.Xe.X = prof.dist(max(find(yIter<y))+1);
                    Xlocs.Xe.Z = prof.bath(max(find(yIter<y))+1);
                else
                    Xlocs.Xe.X = prof.dist(end);
                    Xlocs.Xe.Z = prof.bath(end);
                end

                % Take coordinates for blue polygon (toeslag)
                Xlocs.bluePolygonx = [Xlocs.Xd.X; prof.dist(yIter~=y);Xlocs.Xe.X;flipud(prof.dist(yIter~=y));Xlocs.Xd.X];                                               
                Xlocs.bluePolygony = [Xlocs.Xd.Z; y(yIter~=y) + sctInput.criticalwl ;Xlocs.Xe.Z ;flipud(yIter(yIter~=y)) + sctInput.criticalwl ;Xlocs.Xd.Z];             
                
                % Obtain the eroded profile including toeslag
                prof.toeslag = prof.bath - sctInput.criticalwl;
                prof.toeslag(prof.toeslag >= 0) = 0;
                prof.toeslag = prof.toeslag + yIter + sctInput.criticalwl;
                
            
                
            
            % Now, do the specific points for each case (Building or no buildings) 
            if strcmp(sctInput.duneProfile,'NoBuildings') == 1
               
                %% Xw: most landward point of the crown of the border profile (grensprofiel)

                y = prof.toeslag-sctInput.criticalwl;                                         % y variable for area calculation (eroded bathy - critical wl)
                y(y<0) = 0;

                iterPos = find(y>0,1,'first')-1;                                              % Position in the array for iteration
                iterArea = 0;                                                                 % Area for iteration
                

                while iterArea<sctInput.minimumArea;
                   iterPos = iterPos+1;
                   if iterPos <= length(y)                    
                       iterArea = trapz(prof.dist(1:iterPos),y(1:iterPos));
                       Xlocs.stability = 1;                                                   % The dune fulfills criteria from Methodologie kustveiligheidstoets, 2016
                   else  
                       Xlocs.stability = 0;                                                   % The dune doesnt fulfill criteria from Methodologie kustveiligheidstoets, 2016
                       warning(strcat('Profile', sctInput.RunName,' is instable'))
                       break
                   end
                end

                if Xlocs.stability == 1                                                       % Only Xw exists if the dune is stable
                    Xlocs.Xw.X = prof.dist(iterPos);
                    Xlocs.Xw.Z = prof.bath(iterPos);  
                else
                    Xlocs.Xw.X = NaN;
                    Xlocs.Xw.Z = NaN;  
                end
           
                % Take distance.  Xv-Xw. The shortest 'critical distance' corresponds to the 'critical profile'

                if Xlocs.stability == 1
                    Xlocs.criticalDist = Xlocs.Xv.X - Xlocs.Xw.X;
                    % Take coordinates for magenta polygon (Grens profiel)
                    Xlocs.magentaPolygonx = [prof.dist(prof.toeslag > sctInput.criticalwl & prof.dist <= Xlocs.Xw.X); Xlocs.Xw.X; Xlocs.Xw.X; prof.dist(find(prof.toeslag>sctInput.criticalwl,1,'first')-1)];
                    Xlocs.magentaPolygony = [prof.toeslag(prof.toeslag > sctInput.criticalwl & prof.dist <= Xlocs.Xw.X); Xlocs.Xw.Z; sctInput.criticalwl; sctInput.criticalwl];
                else 
                    Xlocs.criticalDist = 0;
                end
                
            elseif strcmp(sctInput.duneProfile,'Buildings') == 1
                
               % A. 5 m seaward from the safety line
               
               Xlocs.A.X = Xlocs.Xv.X - 5;
               Xlocs.A.Z = Xlocs.Xv.Z;
               
               % C. Where it intersects the cross-shore section
               
               posCxPlus = min(find(prof.bath > Xlocs.A.Z));
               posCxMinus = posCxPlus - 1;
               
               Xlocs.C.Z = Xlocs.A.Z;
               Xlocs.C.X = interp1([prof.bath(posCxMinus),prof.bath(posCxPlus)],[prof.dist(posCxMinus),prof.dist(posCxPlus)],Xlocs.C.Z);
               
               % Check if it is landward from Xe, if it is, take Xe
               
               if Xlocs.C.X > Xlocs.Xe.X
                   
                   Xlocs.C.X =  Xlocs.Xe.X;
                   Xlocs.C.Z =  Xlocs.Xe.Z;
               end
               
               % B. Down with the 1:1.5 slope (taken from the -5 m TAW)
               
               Xlocs.B.X = Xlocs.A.X - 1.5*(Xlocs.A.Z - (-5));
               Xlocs.B.Z = -5;
               
               lineAB.X = prof.dist(prof.dist>=Xlocs.B.X & prof.dist <= Xlocs.A.X);
               lineAB.Z = interp1([Xlocs.B.X, Xlocs.A.X],[Xlocs.B.Z, Xlocs.A.Z],lineAB.X);
                
               if numel(find(lineAB.Z > prof.bath(prof.dist>=Xlocs.B.X & prof.dist <= Xlocs.A.X))) > 1
                   Xlocs.buildingSafeDune = 0;
               else
                   Xlocs.buildingSafeDune = 1;
               end
            end    
        end
        
        
        
        function [] = extractProfiles(sctInput)
            
            % [] = extractProfiles(sctInput)
            %
            % Extract cross-shore profiles from XBeach run for use in SWASH
            
            sctInput = Util.setDefault(sctInput,'writeTextOutput',true);
            sctInput = Util.setDefault(sctInput,'plotProfiles',true);
            
            % Load bathymetry
            
            sctOpt.vars = {'zb','zb0'};
            ds = XBeach.readData(sctInput.modelDir,sctOpt);
            dsi = XBeach.loadInitBathy(sctInput);
            
           % Do check on size of dsi compared to ds. If different, interpolate dsi
            
            if size(ds.X.data,1) ~= size(dsi.InitBotlev.data,1) | size(ds.X.data,2) ~= size(dsi.InitBotlev.data,2)
              fieldDsi = fieldnames(dsi);
              for j = 1:numel(fieldDsi)
                  if fieldDsi{j} ~= 'X' & fieldDsi{j} ~= 'Y'
                      dsi.(fieldDsi{j}).data = interp2(dsi.X.data,dsi.Y.data,dsi.(fieldDsi{j}).data,ds.X.data,ds.Y.data);
                  end
              end
             
            dsi.X.data = ds.X.data;
            dsi.Y.data = ds.Y.data;              
            end
            
            
            if ~isfield(ds,'InitBotDep');
                zHard = dsi.HardLayer.data;
            else
                zHard = nan(size(ds.BotDep.data,2),size(ds.BotDep.data,3));
            end
            
            % Interpolate if grid cells are not the same from ds and dsi
            
            %Get profiles
            
            sctInput = Util.setDefault(sctInput,'interp',true);
            
            defOpt.interp = sctInput.interp; %Options structure for defineProfGraph
            if ~sctInput.interp
                if isfield(sctInput,'iprof')
                    iprof = sctInput.iprof;
                    jprof = sctInput.jprof;
                elseif isfield(sctInput,'xprof')
                    xprof = sctInput.xprof;
                    yprof = sctInput.yprof;
                    iprof = nan(size(xprof));
                    jprof = nan(size(xprof));
                    
                    for iCol = 1:size(xprof,2)
                        [iprof(:,iCol),jprof(:,iCol)]  = Interpolate.getIndNearest(...
                            xprof(:,iCol),yprof(:,iCol),ds.X.data,ds.Y.data);
                    end
                else
                    [~,~,iprof,jprof] = CosaTool.defineProfGraph(ds,defOpt);
                    % Reinterpolate i and j values to have 1 cross-shore
                    % line
                    iprof = repmat(round(mean(iprof,2)),1,size(iprof,2));
                    jprof = repmat([1,size(ds.X.data,2)],size(jprof,1),1);
                end
                % check  variables
                for i = 1:size(iprof,1)
                    if (iprof(i,1)~=iprof(i,2)) && (jprof(i,1)~=jprof(i,2))
                        error(['Invalid profile: ', num2str(i),'. At least one of the points must be equal.']);
                    end
                    if (iprof(i,1)==iprof(i,2)) && (jprof(i,1)==jprof(i,2))
                        error(['Invalid profile: ', num2str(i),'. The two points must be different.']);
                    end
                end
            else
                if isfield(sctInput,'xprof')
                    xprof = sctInput.xprof;
                    yprof = sctInput.yprof;
                else
                    [xprof,yprof] = CosaTool.defineProfGraph(ds,defOpt);
                end
                % check data
            end
            
            % get some defaults
            sctInput  = Util.setDefault(sctInput,'nrPoint',100);
            sctInput  = Util.setDefault(sctInput,'timeStep',size(ds.BotDep.data,1));
            
            
            x = ds.X.data;
            y = ds.Y.data;
            z = squeeze(ds.BotDep.data(sctInput.timeStep,:,:));
            if any(size(z)==1)
                z = z';
            end
            if isfield(ds,'InitBotDep');
                zInit = squeeze(ds.InitBotDep.data(1,:,:));
            else
                % If initial bottom level is not in results file (zb0),
                % try to grab it from the input file
                if isfield(dsi,'InitBotlev')
                    if isequal(dsi.X.data(:),x(:));
                        zInit = dsi.InitBotlev.data;
                    else
                        zInit = interp2(dsi.X.data,dsi.Y.data,dsi.InitBotlev.data,x,y);
                    end
                else
                    zInit = nan(size(z));
                end
            end
            
     
            
            % loop over all profiles
            if sctInput.interp
                % preallocate
                nrProf = size(xprof,1);
                dist = cell(nrProf,1);
                bath = cell(nrProf,1);
                bathInit = cell(nrProf,1);
                % Print output to console
                fprintf('\nxprof = \n');
                for i =1:size(xprof,1);
                    fprintf('%.2f\t',xprof(i,:));
                    fprintf('\n');
                end
                fprintf('\nyprof = \n');
                for i =1:size(yprof,1);
                    fprintf('%.2f\t',yprof(i,:));
                    fprintf('\n');
                end
                % prepare interpolation
                
                myInterp = scatteredInterpolant(x(:),y(:),z(:));
                myInterpInit = scatteredInterpolant(x(:),y(:),zInit(:));
                myInterpHard = scatteredInterpolant(x(:),y(:),zHard(:));
                
                t = (0:1/(sctInput.nrPoint-1):1)';
                for i=1:nrProf
                    % make points on a line
                    xTmp = xprof(i,1)+(xprof(i,2)-xprof(i,1)).*t;
                    yTmp = yprof(i,1)+(yprof(i,2)-yprof(i,1)).*t;
                    % interpolate
                    dist{i} = [0;cumsum(sqrt( diff(xTmp).^2 + diff(yTmp).^2))];
                    bath{i} = myInterp(xTmp,yTmp);
                    bathInit{i} = myInterpInit(xTmp,yTmp);
                    hardLayer{i} = myInterpHard(xTmp,yTmp);
                end
            else
                % preallocate
                nrProf = size(iprof,1);
                dist = cell(nrProf,1);
                bath = cell(nrProf,1);
                bathInit = cell(nrProf,1);
                hardLayer = cell(nrProf,1);
                % Print output to console
                fprintf('\niprof = \n');
                for i =1:size(iprof,1);
                    fprintf('%u\t',iprof(i,:));
                    fprintf('\n');
                end
                fprintf('jprof = \n');
                for i =1:size(jprof,1);
                    fprintf('%u\t',jprof(i,:));
                    fprintf('\n');
                end
                fprintf('\nxprof = \n');
                for i =1:size(iprof,1);
                    fprintf('%.1f\t',x([iprof(i,1)],[jprof(i,1) jprof(i,2)]));
                    fprintf('\n');
                end
                fprintf('yprof = \n');
                for i =1:size(jprof,1);
                    fprintf('%.1f\t',y(iprof(i,1),[jprof(i,1) jprof(i,2)]));
                    fprintf('\n');
                end
                
                % get data from all profiles
                for i=1:nrProf
                    if iprof(i,1)~=iprof(i,2)
                        di = sign(iprof(i,2)-iprof(i,1));
                        xTmp = x(iprof(i,1):di:iprof(i,2),jprof(i,1));
                        yTmp = y(iprof(i,1):di:iprof(i,2),jprof(i,1));
                        zTmp = z(iprof(i,1):di:iprof(i,2),jprof(i,1));
                        zTmpInit = zInit(iprof(i,1):di:iprof(i,2),jprof(i,1));
                        zHardTmpInit = zHard(iprof(i,1):di:iprof(i,2),jprof(i,1));
                    else
                        dj = sign(jprof(i,2)-jprof(i,1));
                        xTmp = x(iprof(i,1),jprof(i,1):dj:jprof(i,2));
                        yTmp = y(iprof(i,1),jprof(i,1):dj:jprof(i,2));
                        zTmp = z(iprof(i,1),jprof(i,1):dj:jprof(i,2));
                        zTmpInit = zInit(iprof(i,1),jprof(i,1):dj:jprof(i,2));
                        zHardTmpInit = zHard(iprof(i,1),jprof(i,1):dj:jprof(i,2));
                        
                    end
                    dist{i} = [0;cumsum(sqrt( diff(xTmp(:)).^2 + diff(yTmp(:)).^2))];
                    bath{i} = zTmp;
                    bathInit{i} = zTmpInit;
                    hardLayer{i} = zHardTmpInit;
                end
                
                
            end
            
            % plot profiles to check
            if sctInput.plotProfiles
                CosaTool.plotProfiles(dist,bath,bathInit,hardLayer,sctInput)
            end
            % Plot profiles in the zone
            if ~sctInput.interp
                %If we are taking the profiles on the grid lines -> plot
                %the actual grid lines
                xprofPlot = nan(size(iprof));
                yprofPlot = nan(size(jprof));
                for i = 1:size(iprof,1);%In a perfect world, this would be vectorized. Alas!
                    for j = 1:size(iprof,2);
                        xprofPlot(i,j) = x(iprof(i,j),jprof(i,j));
                        yprofPlot(i,j) = y(iprof(i,j),jprof(i,j));
                    end
                end
            else
                xprofPlot = xprof;
                yprofPlot = yprof;
            end
            if ~any(size(y)==1)%Only if 2D
                CosaTool.plotProfileLocations(x,y,zInit,xprofPlot,yprofPlot,sctInput);
            end
            % save profiles
            % Put in table for easy csv export
            
            if sctInput.writeTextOutput
                for i = 1:nrProf
                    profTable = table;
                    profTable.dist = dist{i}(:);
                    profTable.bath = bath{i}(:);
                    profTable.bathInit = bathInit{i}(:);
                    profTable.hardLayer = hardLayer{i}(:);
                    if isfield(sctInput,'profileName')
                        fileOut = [sctInput.profileName{i} '.csv'];
                    else
                        fileOut = sprintf('postprofile_%u.csv',i);
                    end
                    writetable(profTable,...
                        fullfile(sctInput.outputFolder,fileOut));
                    
                end
            end
        end
        
        
        function [] = makeStormTs(sctInput)
            % [] = makeStormTs(sctInput)
            %
            % Create a design storm timeseries
            
            % get parameters
            sctInput =  Util.setDefault(sctInput,'tStorm',45);
            sctInput =  Util.setDefault(sctInput,'tWave',125);
            sctInput =  Util.setDefault(sctInput,'dt',15);
            sctInput = Util.setDefault(sctInput,'tideloc',2);
            
            dt     = sctInput.dt/24/60;
            stormDuration = sctInput.tStorm/24;
            waveDuration  = sctInput.tWave/24;
            
            if stormDuration>waveDuration
                error(['The value of tStorm (',num2str(stormDuration),' day) should be smaller than the value of tWave (',num2str(waveDuration),' day)']);
            end
            sctInput =  Util.setDefault(sctInput,'tShift',0.0);
            tShift  = sctInput.tShift/24;
            
            
            % make time series for tide
            
            tWlInp  = 0:dt:stormDuration;
            
            tTide      = sctInput.timeTide/24;
            wl         = sctInput.wlTide + sctInput.refLevelCor;
            watlevTide = CosaTool.interpTide(tTide,wl,tWlInp,stormDuration);
            
            % get wind setup
            watlev = watlevTide + sctInput.hStorm.*cos(pi.*(tWlInp/stormDuration-0.5)).^2;
            
            % Include column with 0 water level (for the back side) if tideloc = 2
            
            if sctInput.tideloc == 2
                watlev = [watlev; zeros(size(watlev))];
            end
            
            % write data
            sctInput = Util.setDefault(sctInput,'wlFile','tide.txt');
            fileName = fullfile(sctInput.outputFolder,sctInput.wlFile);
            CosaTool.writeStormTs(fileName,tWlInp',watlev');
            
            % make time series for waves (xbecah wbctype jons_table)
            % <Hm0> <Tp> <mainang> <gammajsp> <s> <duration> <dtbc>
            
            
            sctInput   = Util.setDefault(sctInput,'dtbc',1.0);
            sctInput   = Util.setDefault(sctInput,'dtWav',sctInput.dt);
            dtWav      = sctInput.dtWav/60/24;
            % generate time
            tWavInp  = (dtWav/2:dtWav:stormDuration)';
            tWav  = tWavInp - 0.5.*stormDuration;
            
            %prepare data
            hSig     = sctInput.hSigMax.*cos(pi.*(tWav+tShift)./waveDuration).^2;
            % Note that  it is not quadratic. The equations are different.
            tPeak    = sctInput.tPeakMax.*cos(pi.*(tWav+tShift)./waveDuration);
            wavDir   = sctInput.wavDir.*ones(size(tWav));
            duration = dtWav.*ones(size(tWav))*86400;
            gammajsp = sctInput.gammajsp.*ones(size(tWav));
            s        = sctInput.dirspread.*ones(size(tWav));
            dtbc     = sctInput.dtbc.*ones(size(tWav));
            
            % write data
            data  = [hSig,tPeak,wavDir,gammajsp,s,duration,dtbc];
            sctInput = Util.setDefault(sctInput,'waveFile','waves.txt');
            fileName = fullfile(sctInput.outputFolder,sctInput.waveFile);
            CosaTool.writeStormTs(fileName,[],data);
            
            % make plots to check
            CosaTool.plotStormTs(tWav,hSig,tPeak,tWlInp-0.5.*stormDuration,watlev(1,:),watlevTide,sctInput)
            
        end
        
        function [] = overtopSwashPreprocess(opt)
            % [] = overtopSwashPreprocness(opt)
            %
            % Swash 1D overtopping run preparation
            %
            %
            % Inputs: opt structure, containing:
            %     opt.outputFolder Results folder (where the table will be saved);
            %     opt.maxIter Maximum iterations. Default = 10;
            % Outputs:
            % output %Structure with relevant outputs
            %
            opt = Util.setDefault(opt,'offshoreWGInputfile','gauge5mTAW.wvg');
            opt = Util.setDefault(opt,'dykeToeWGInputfile','gaugeDykeToe.wvg');
            opt = Util.setDefault(opt,'dykeTopWGInputfile','gaugeDykeTop.wvg');
            opt = Util.setDefault(opt,'bottomFile','swash.bot');
            opt = Util.setDefault(opt,'isEnsemble',false);
            
            
            filesToCopy = {
                'bottomFile'
                'offshoreWGInputfile'
                'dykeToeWGInputfile'
                'dykeTopWGInputfile'
                };
            
            fprintf('SWASH 1D Overtopping run preprocessing of profile %s.\n',opt.RunName);
            
            
            runOpt.directory = fullfile(opt.Swash1DOvertopRootRunFolder,...
                sprintf('%s',opt.RunName));
            runOpt.filename = 'overtop1d.sws';
            runOpt.nx = opt.nxOvertop;
            runOpt.lenx = opt.lenxOvertop;
            runOpt.dxOvtp = opt.dxOvtp;
            runOpt.swl = opt.swl1D;
            runOpt.Hm0 = opt.offshoreHm01D;
            runOpt.Tp = opt.offshoreTp1D;
            runOpt.depmin = opt.depMin;
            runOpt.highCour = opt.highCour;
			runOpt.lowCour = opt.lowCour;
			runOpt.discret = opt.discret;
			runOpt.inittstep = opt.inittstep;
            
			
            
            if isfield(opt,'seed')
                runOpt.seed = opt.seed;
            end                
            
            if opt.isEnsemble
                runOpt.seedText = sprintf('SET SEED %u',...
                    opt.seedNumber);
            else
                runOpt.seedText= '';
            end
            
            % Write Swash input file
            Swash.writeInput(opt.overtop1dProtorun,runOpt);
            
            % Copy bathy and wave gauge files
            for iF = 1:numel(filesToCopy)
                copyfile(fullfile(char(opt.bathyRunFolder),char(opt.RunName),char(opt.(filesToCopy{iF}))),...
                    fullfile(char(runOpt.directory),char(opt.(filesToCopy{iF}))));
            end
            
            % Copy sub file
            copyfile(opt.overtop1dProtosub,fullfile(char(runOpt.directory),'run_swash.sub'));
            
        end
        
        function overtopSwashPreprocessEnsemble(opt)
            % [] = calibSwash1DEnsemble(opt)
            %
            % Swash 1D calibration for ensemble runs
            %
            %
            % Inputs: opt structure, containing:
            %     opt.outputFolder Results folder (where the table will be saved);
            %     opt.maxIter Maximum iterations. Default = 10;
            % Outputs:
            % output %Structure with relevant outputs
            %
            opt = Util.setDefault(opt,'numEnsemble',7);
            
            % Make table of ensembles
            allEns = readtable(fullfile(opt.ensemblesRootFolder,opt.RunName,'ensembles.csv'));
            allEns.bathyRunFolder = repmat(string(opt.bathyRunFolder),opt.numEnsemble+1,1)
            allEns.bottomFile = repmat(string(opt.bottomFile),opt.numEnsemble+1,1);
            allEns.offshoreWGInputfile = repmat(string(opt.offshoreWGInputfile),opt.numEnsemble+1,1);
            allEns.dykeToeWGInputfile = repmat(string(opt.dykeToeWGInputfile),opt.numEnsemble+1,1);
            allEns.dykeTopWGInputfile = repmat(string(opt.dykeTopWGInputfile),opt.numEnsemble+1,1);
            
            
            %             allEns.Swash1DCalibRootRunFolder = string(allEns.Swash1DCalibRootRunFolder);
            % Copy overtopping volume for first Ensemble
            allEns.overtopVol(1)= opt.overtopVol;
            allEns.overtopVol(2:end)=nan;
%             allEns.overtopVol_Liter(1:end)=nan;
            % Loop over all ensembles
            for iEns = 2:opt.numEnsemble+1 %Loop over all ensembles
                allEns.Swash1DOvertopRootRunFolder(iEns) = fullfile(...
                    allEns.Swash1DOvertopRootRunFolder(1),'ensembles',sprintf('ensemble%u',iEns));
                CosaTool.overtopSwashPreprocess(table2struct( allEns(iEns,:)));
            end
            
        end
        
        function plotProfiles(x,y,yInit,hardLayer,opt)
            % Plot cross-shore profile
            
            nrProf = length(x);
            makeProfNames =  ~isfield(opt,'profileName'); %Whether to make our own profile names
            for i=1:nrProf
                UtilPlot.reportFigureTemplate(15,7);
                %                 subaxis(1,1,1,'mb',0.2);
                hold on;
                if any(~isnan(hardLayer{i}));
                    plot(x{i},hardLayer{i},'k','displayname','Hard layer');
                end
                plot(x{i},yInit{i},'displayname','Initial profile');
                plot(x{i},y{i},'displayname','Post-storm profile');
                
                
                if makeProfNames
                    profName = ['Profile ',num2str(i,'%02.0f')];
                else
                    profName = opt.profileName{i};
                end
                title(profName,'interpreter','none');
                
                %Simple volume calculation
                if isfield(opt,'eroVolContour')
                    ind1 = find(yInit{i}>opt.eroVolContour,1);
                    mask = ind1:numel(yInit{i});
                    eroVol = trapz(x{i}(mask),y{i}(mask)) - ...
                        trapz(x{i}(mask),yInit{i}(mask));
                    erosionText = sprintf('Volume change landward of %s pre-storm %.1f m contour: %.2f m^3/m.',...
                        char(10),opt.eroVolContour,eroVol);
                    text(0.5,0.2,erosionText,'units','normalized');
                end
                
                %Layout stuff
                legend('location','northwest');
                grid on;
                box on;
                xlabel('Distance [m]');
                ylabel('Profile [m]');
                ylim([floor(min(min([y{i}(:) yInit{i}(:)]))-1) ceil(max(max([y{i}(:) yInit{i}(:)]))+1)]);
                
                figFilename = profName;
                print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220')
                savefig([fullfile(opt.outputFolder,figFilename)])
            end
            
        end
        
        function plotProfileLocations(x,y,zInit,xprofPlot,yprofPlot,opt)
            % plotProfileLocations(x,y,zInit,xprofPlot,yprofPlot,opt)
            %
            % Plot locations of profiles
            %%
            makeProfNames =  ~isfield(opt,'profileName'); %Whether to make our own profile names
            
            figure;
            hold all;
            if max(x)<10^4
                sf = 1;
                xlabel('x [m]')
                ylabel('y [m]')
            else
                sf = 1000;
                xlabel('x [km]')
                ylabel('y [km]')
            end
            hp = pcolor(x/sf,y/sf,zInit);
            
            hp.LineWidth = 0.5;
            hp.EdgeAlpha = 0.3;
            axis equal;
            
            try;
                UtilPlot.topoBathyMap(min(zInit(:)),0,max(zInit(:)));
            catch
                warning('Need openearthtools to make pretty bathy');
            end
            cb = colorbar;
            cb.Label.String = 'z [m TAW]';
            
            box on;
            grid on;
            
            
            for i =1:size(xprofPlot,1);
                plot(xprofPlot(i,:)/sf,yprofPlot(i,:)/sf,'r','linewidth',2)
                if makeProfNames
                    profName = ['Prof. ',num2str(i,'%02.0f')];
                else
                    profName = opt.profileName{i};
                end
                text((xprofPlot(i,1)+0.1*diff(xprofPlot(i,[end 1])))/sf,...
                    (yprofPlot(i,1)-0.1*diff(yprofPlot(i,[end 1])))/sf,...
                    profName,'color','r','interpreter','none');
                
            end
            title('Coastal Safety Tool - Profile Locations');
            figFilename = ['profileLocations'];
            print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220')
            savefig(fullfile(opt.outputFolder,figFilename));
            %%
        end
        
        
        function plotStormTs(tWav,hSig,tPeak,tWl,wl,wlTide,opt)
            %plotStormTs(tWav,hSig,tPeak,tWl,wl,wlTide)
            %
            %Plot storm time series
            
            tWl = tWl*24;
            subplot(3,1,1)
            plot(tWl,wl,'-x',tWl,wlTide,'-x',tWl,wl-wlTide,'-x')
            legend('Total','Tide','Surge')
            ylabel('\zeta [m]');
            grid on
            
            tWav= tWav*24;
            subplot(3,1,2)
            plot(tWav,hSig,'-x')
            ylabel('H_s [m]')
            grid on
            
            
            subplot(3,1,3)
            plot(tWav,tPeak,'-x')
            xlabel('t [h]')
            ylabel('T_p [s]')
            grid on
            
            figFilename = ['stormTs'];
            print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220');
            savefig(fullfile(opt.outputFolder,figFilename))
            
        end
        
        function plotSwashBathy(xRaw,zRaw,xSwash,zSwash,xOffset,xGaugePlot,nameGaugePlot,runName)
            % plotSwash2Dbathy(xRaw,zRaw,xSwash,zSwash,xOffset,xGaugePlot,nameGaugePlot,runName);
            %
            % Control plot of Swash 2D Bathy
            
            if nargin<8
                runName='';
            end
            
            figure;
            hold all;
            box on;
            grid on;
            plot(xRaw,zRaw,'displayname','Input profile');
            plot(xSwash-xOffset,zSwash,'.-','DisplayName','Profile for Swash');
            
            legend('location','northwest');
            
            zGaugePlot = interp1(xSwash-xOffset,zSwash,xGaugePlot-xOffset);
            plot(xGaugePlot-xOffset,zGaugePlot,'kx','HandleVisibility','off');
            
            for i = 1:numel(xGaugePlot);
                text(xGaugePlot(i)-xOffset,zGaugePlot(i)+2,nameGaugePlot{i},'horizontalalignment','center');
            end
            
            ylim([min(zSwash) max(zSwash)+4]);
            
            title(runName,'interpreter','none');
            
            drawnow;
        end
        
        function plotSwashOutput(opt);
            % Make standard output plots of Swash output
            %
            % plotSwashOutput(opt);
            opt = Util.setDefault(opt,'baseFileName','SWASH');
            opt = Util.setDefault(opt,'plotOverviewFig',true);
            
            
            if min(size(opt.block.Xp))>2 %If 2D run, add 2D plots
                %% Contour plot of Hm0
                f1 = UtilPlot.reportFigureTemplate('portrait',10);
                
                xTransect = opt.toeGauge.x;
                
                subaxis(1,1,1,'mr',0.3,'mt',0.20,'ml',0.08,'mb',0.12);
                hold all;
                
                pos = get(gca,'position');
                hold all;
                pcolor(opt.block.Xp,opt.block.Yp,opt.block.Hsig);
                plot(xTransect*[1 1],[min(min(opt.block.Yp)) max(max(opt.block.Yp))],'color',[0.8500    0.3250    0.0980]);
                shading interp;
                plot(1e6*[-1 1],100*[1 1],'k');
                plot(1e6*[-1 1],200*[1 1],'k');
                plot(1e6*[-1 1],300*[1 1],'k');
                xlim([min(min(opt.block.Xp)) max(max(opt.block.Xp))]);
                xlabel('x (m)');
                ylabel('y (m)');
                cb = colorbar('northoutside');
                % set(gca,
                set(cb,'position',[0.08 .82 0.62 0.05]);
                ti = title('H_{m0}','units','normalized','position',[.5 1.2 0]);
                box on;
                
                subaxis(1,1,1,'mr',0.05,'mt',0.2,'ml',0.75,'mb',0.12);
                hold all;
                
                [~,ind] = min(abs(opt.block.Xp(1,:)-xTransect));
                plot(opt.block.Hsig(:,ind),opt.block.Yp(:,ind),'color',[0.8500    0.3250    0.0980]);
                xl2 = get(gca,'xlim');
                plot(1e6*[-1 1],100*[1 1],'k');
                plot(1e6*[-1 1],200*[1 1],'k');
                plot(1e6*[-1 1],300*[1 1],'k');
                xlim(xl2);
                box on;
                grid on;
                set(gca,'yticklabel',[]);
                xlabel('H_{m0} (m)');
                
                figFilename = ['Hm0_' opt.baseFileName];
                print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220');
                %             savefig(fullfile(opt.outputFolder,figFilename));
                %% Contour plot of Setup
                f1 = UtilPlot.reportFigureTemplate('portrait',10);
                
                
                subaxis(1,1,1,'mr',0.3,'mt',0.20,'ml',0.08,'mb',0.12);
                hold all;
                
                pos = get(gca,'position');
                hold all;
                pcolor(opt.block.Xp,opt.block.Yp,opt.block.Setup);
                plot(xTransect*[1 1],[min(min(opt.block.Yp)) max(max(opt.block.Yp))],'color',[0.8500    0.3250    0.0980]);
                shading interp;
                xlabel('x (m)');
                ylabel('y (m)');
                plot(1e6*[-1 1],100*[1 1],'k');
                plot(1e6*[-1 1],200*[1 1],'k');
                plot(1e6*[-1 1],300*[1 1],'k');
                xlim([min(min(opt.block.Xp)) max(max(opt.block.Xp))]);
                cb = colorbar('northoutside');
                % set(gca,
                set(cb,'position',[0.08 .82 0.62 0.05]);
                ti = title('Setup','units','normalized','position',[.5 1.2 0]);
                
                box on;
                
                subaxis(1,1,1,'mr',0.05,'mt',0.2,'ml',0.75,'mb',0.12);
                [~,ind] = min(abs(opt.block.Xp(1,:)-xTransect));
                hold all;
                plot(opt.block.Setup(:,ind),opt.block.Yp(:,ind),'color',[0.8500    0.3250    0.0980]);
                box on;
                grid on;
                xl2 = get(gca,'xlim');
                plot([xl2(1),xl2(2)],100*[1 1],'k');
                plot([xl2(1),xl2(2)],200*[1 1],'k');
                plot([xl2(1),xl2(2)],300*[1 1],'k');
                %                 xlim(nanmean(opt.block.Setup(:,ind))+[-0.015 0.015]);
                
                set(gca,'yticklabel',[]);
                xlabel('Setup (m)');
                
                
                figFilename = ['setup_' opt.baseFileName];
                print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220');
                %             savefig(fullfile(opt.outputFolder,figFilename));
                
            end
            %Now come the plots of 1D stuff
            %% Cross-shore plot
            %             xyyplot = [ [gauge.x]' [gauge.Hm0]' [gauge.Tmm10]' [gauge.Hm0_min]' [gauge.Hm0_max]' [gauge.Tmm10_min]' [gauge.Tmm10_max]'];
            %             xyyplot = sortrows(xyyplot);
            co = lines;
            f1 = UtilPlot.reportFigureTemplate('portrait',11);
            
            %Bathy panel
            ax(1) = subaxis(4,1,1);
            hold all
            plot(opt.block.Xp(1,:),-1 * mean(opt.block.Botlev,1)+opt.refLevel,'k');
            plot(opt.block.Xp(1,:),opt.refLevel*ones(size(opt.block.Xp(1,:))));
            %             plot(opt.block.Xp(1,:),opt.block.Setup+opt.refLevel,'b--');
            ylimVec = ylim;
            if isfield(opt,'topGaugeTS')
                plot([opt.topGaugeTS.X.data(1),opt.topGaugeTS.X.data(1)],[ylimVec(1),ylimVec(2)]);
            end
            grid on;
            box on;
            xlim([min(min(opt.block.Xp)) max(max(opt.block.Xp))]);
           
            ylabel('z (m TAW)');
            set(gca,'xticklabel',[]);
            
            %MWL panel
            ax(2) = subaxis(4,1,2);
            hold all
            
            plot(opt.block.Xp(1,:),opt.refLevel*ones(size(opt.block.Xp(1,:))));
            plot(opt.block.Xp(1,:),mean(opt.block.Setup,1)+opt.refLevel,'--','color',co(2,:));
            plot(opt.offGauge.x,opt.offGauge.setup,'x','color',co(4,:),'linewidth',1.5);
            plot(opt.toeGauge.x,opt.toeGauge.setup,'x','color',co(4,:),'linewidth',1.5);
            
            grid on;
            box on;
            xlim([min(min(opt.block.Xp)) max(max(opt.block.Xp))]);
            ylim(opt.refLevel*[1 1] +  prctile(abs(opt.block.Setup(:)),95)*3.*[-1 1]);
            ylabel('z (m TAW)');
            set(gca,'xticklabel',[]);
            
            
            %Wave height panel
            ax(3) = subaxis(4,1,3);
            hold all
            % plot(opt.block.Xp,-1 * opt.block.Botlev+refLevel,'k');
            % plot(opt.block.Xp,refLevel*ones(size(opt.block.Xp)),'b');
            plot(opt.block.Xp(1,:),mean(opt.block.Hsig,1),'-');
            %             plot(xyyplot(:,1),xyyplot(:,2),'x');
            plot(opt.offGauge.x,opt.offGauge.Hm0,'x','color',co(4,:),'linewidth',1.5);
            plot(opt.toeGauge.x,opt.toeGauge.Hm0,'x','color',co(4,:),'linewidth',1.5);
            ylim([0 nanmedian(mean(opt.block.Hsig,1))*1.5]);
            % errorbar(xyyplot(:,1),xyyplot(:,2),xyyplot(:,2)-xyyplot(:,4),-xyyplot(:,2)+xyyplot(:,5));
            % plot(opt.block.Xp,0*opt.block.Xp,'k--','linewidth',0.5);
            grid on;
            box on;
            xlim([min(min(opt.block.Xp)) max(max(opt.block.Xp))]);
            ylabel('H_{m0} (m)');
            set(gca,'xticklabel',[]);
            
            [dfr,indOffX] = min(abs((opt.block.Xp(1,:)-opt.offGauge.x)));
            indY = find(rem(opt.block.Yp(:,1),100)==0&opt.block.Yp(:,1)>90&opt.block.Yp(:,1)<=310);
            
            %Wave period panel
            ax(4) = subaxis(4,1,4);
            hold all
            % plot(opt.block.Xp,-1 * opt.block.Botlev+refLevel,'k');
            % plot(opt.block.Xp,refLevel*ones(size(opt.block.Xp)),'b');
            %             plot(xyyplot(:,1),xyyplot(:,3),'-');
            % errorbar(xyyplot(:,1),xyyplot(:,3),xyyplot(:,3)-xyyplot(:,6),-xyyplot(:,3)+xyyplot(:,7));
            plot(opt.offGauge.x,opt.offGauge.Tmm10,'x','color',co(4,:),'linewidth',1.5);
            plot(opt.toeGauge.x,opt.toeGauge.Tmm10,'x','color',co(4,:),'linewidth',1.5);
            grid on;
            box on;
            ylabel('T_{m-1,0} (s)');
            xlabel('x (m)');
            xlim([min(min(opt.block.Xp)) max(max(opt.block.Xp))]);
            ylim([0 max([opt.offGauge.Tmm10 opt.toeGauge.Tmm10])*1.3]);
            
            linkaxes(ax,'x');
            figFilename = ['cross_shore_' opt.baseFileName];
            print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r300');
            savefig(fullfile(opt.outputFolder,figFilename));
            %% Plot spectra
            
            f1 = UtilPlot.reportFigureTemplate('portrait',8);
            
            
            % Panel 1: at -5m TAW
            subaxis(1,2,1,'mb',0.12,'sh',0.1);
            hold all;
            
            plot(opt.offGauge.f,opt.offGauge.Sf,'displayname','SWASH');
            
            if exist('jonswap1','file')==0
                addOpenEarth
            end
            
            targetSpec = jonswap1(opt.offGauge.f*2*pi,'Hs',opt.targetHm0,'wp',2*pi/opt.targetTp);
            plot(opt.offGauge.f,targetSpec,'--','displayname','JONSWAP');
            
            xlim([0 0.5]);
            ylim([0 1.3*max(targetSpec)]);
            
            xlabel('f (Hz)');
            ylabel('S (m^2s)');
            box on;
            legend show;
            title('-5 m TAW');
            
            % Panel 2: at dyke toe
            subaxis(1,2,2);
            
            plot(opt.toeGauge.f,opt.toeGauge.Sf,'displayname','SWASH');
            
            xlim([0 0.5])
            xlabel('f (Hz)');
            ylabel('S (m^2s)');
            box on;
            title('Dijkteen');
            % legend show;
            
            figFilename = ['spectrum_' opt.baseFileName];
            print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r300');
            savefig(fullfile(opt.outputFolder,figFilename));
            
            %% Plot overtopping timeseries
            
            if isfield(opt,'topGaugeTS')
                title('Overslag bovenaan de Zeedijk');
                f1 = UtilPlot.reportFigureTemplate('portrait',8);
                
                
                % Panel 1: Water depth
                axO(1) = subaxis(3,1,1,'mb',0.15,'sh',0.1);
                hold all;
                h = opt.topGaugeTS.Depth.data;
                h(h==-99)=0;
                plot(opt.topGaugeTS.Time.data,h);
                set(gca,'XTicklabel',{});
                ylabel('h [m]');
                box on;
                grid on;
                
                
                % Panel 2: Flow velocity
                axO(2) = subaxis(3,1,2);
                hold all;
                plot(opt.topGaugeTS.Time.data,opt.topGaugeTS.Vksi.data);
                ylabel('u [m/s]');
                box on;
                grid on;
                set(gca,'XTicklabel',{});
                
                % Panel 3: Discharge
                axO(3) = subaxis(3,1,3);
                hold all;
                plot(opt.topGaugeTS.Time.data,opt.topGaugeTS.Qksi.data);
                plot(opt.topGaugeTS.Time.data,opt.topGaugeTS.Vksi.data.*h);
                
                xlabel('Tijd [s]');
                ylabel('Q [m^3/(m s)]');
                box on;
                grid on;
                
                linkaxes(axO,'x');
                
                figFilename = ['overtopping_' opt.baseFileName];
                print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r300');
                savefig(fullfile(opt.outputFolder,figFilename));
            end
            
            %% Plot Cross-shore overview figure;
            if opt.plotOverviewFig;
                if min(size(opt.block.Xp)) == 1  % If doing the plot for a 1D case
                    vectLoop = 1:2;
                else
                    vectLoop = 1;
                end
                for ij = vectLoop
                    co = lines;
                    f1 = UtilPlot.reportFigureTemplate('portrait',9);
                    ax = axes('position',[ 0.100    0.1312    0.8  0.53]);
                    % Load pre-storm bathy;
                    % Read input profile
                    prof = readtable(opt.ProfileFile);
                    plot(prof.dist,prof.bathInit,'displayname','Pre-storm profile');

                    %Bathy post-storm
                    hold all
                    plot(opt.block.Xp(1,:)-opt.xOffset,-1 * mean(opt.block.Botlev,1)+opt.refLevel,...
                        'displayname','Post-storm profile');
                    if isfield(opt,'topGaugeTS')
                        ylimVec = ylim;
                        plot([opt.topGaugeTS.X.data(1)-opt.xOffset,opt.topGaugeTS.X.data(1)-opt.xOffset],[ylimVec(1),ylimVec(2)],'displayname','Ovtp gauge location');
                    end
                    xDist = prof.dist;
                    zHard = prof.hardLayer;
                    mask = abs(prof.hardLayer-prof.bath)<3;
                    zHard(~mask)=nan;
                    plot(xDist,zHard,'k','displayname','Dike');

                    % MWL
                    plot(opt.block.Xp(1,:)-opt.xOffset,mean(opt.block.Setup,1)+opt.refLevel,'--','color',co(4,:),...
                        'displayname','MWL [m TAW]');

                    %Wave height
                    plot(opt.block.Xp(1,:)-opt.xOffset,mean(opt.block.Hsig,1),'-','displayname','H_{m0}[m]',...
                        'color',co(5,:));

                    a = version('-release');
                    if str2double(a(1:4))>=2017;
                        legend('location','southeast','autoupdate','off');
                    else
                        legend('location','southeast');
                    end
                    lix = 1e9*[-1 1];
                    %             plot(opt.block.Xp(1,:)-opt.xOffset,opt.refLevel*ones(size(opt.block.Xp(1,:))));
                    plot(lix,zeros(size(lix)),'k','linewidth',.5);


                    ylabel('z [m TAW]');
                    xlabel('x [m]')
                    grid on;
                    box on;
                    ylim(1.1*[min(prof.bathInit)-5 max(prof.bathInit)]);
                    xlim([-10 max(prof.dist)+10]);
                    %

                    ti = title({opt.RunName},'fontsize',11,'interpreter','none',...
                        'units','normalized','Position',[.5 1.505]);

                    plot(opt.DykeToeX,0,'.','markersize',8,'color',co(4,:));
                    plot(opt.DykeTopX,0,'.','markersize',8,'color',co(4,:));

                    p1 = [    0.1   0.67    0.2    0.24];
                    dataStr11=  sprintf('2D Offshore \nH_{m0}\nMWL\nT_p');


                    txt11   = annotation('textbox','units','normalized',...
                        'Position',p1,'horizontalalignment','left',...
                        'String',dataStr11,'interpreter','tex','fontsize',9);


                    dataStr12=  sprintf('\n%.2f m_{ }\n%.2f m{ }\n%.1f s_{ } ',...
                        opt.offshoreHm02DInp,opt.swl2D,opt.offshoreTp2D);
                    txt22  = annotation('textbox','units','normalized',...
                        'Position',p1,'horizontalalignment','right',...
                        'String',dataStr12,'interpreter','tex','fontsize',9);
                    
                    p2 = [    0.4   0.67    0.2    0.24];
                    if ij == 2
                        dataStr21=  sprintf('1D Calib Offshore \nH_{m0}\nMWL\nT_p');


                        txt21   = annotation('textbox','units','normalized',...
                            'Position',p2,'horizontalalignment','left',...
                            'String',dataStr21,'interpreter','tex','fontsize',9);
                    else
                        dataStr21=  sprintf('2D DikeToe \nH_{m0}\nMWL\nT_{m-1,0}');
                        txt21   = annotation('textbox','units','normalized',...
                            'Position',p2,'horizontalalignment','left',...
                            'String',dataStr21,'interpreter','tex','fontsize',9);
                    end

                    try
                        if ij == 2
                            dataStr22=  sprintf('\n%.2f m_{ }\n%.2f m{ }\n%.1f s_{ } ',...
                                opt.offshoreHm01D,opt.swl1D,opt.offshoreTp1D);
                        else
                           dataStr22=  sprintf('\n%.2f m_{ }\n%.2f m{ }\n%.1f s_{ } ',...
                                opt.dikeToeHm02D,opt.dikeToeSetup2D,opt.dikeToeTmm102D);
                        end
                        txt22  = annotation('textbox','units','normalized',...
                            'Position',p2,'horizontalalignment','right',...
                            'String',dataStr22,'interpreter','tex','fontsize',9);
                        p3 = [    0.7    0.67    0.2    0.24];
                        dataStr31 = sprintf('Overtopping\nq');
                        txt31   = annotation('textbox','units','normalized',...
                            'Position',p3,'horizontalalignment','left',...
                            'String',dataStr31,'interpreter','tex','fontsize',9);
                        dataStr32 = sprintf('\n%.2f L/(m s)',opt.overtopVol*1000);
                        txt32   = annotation('textbox','units','normalized',...
                            'Position',p3,'horizontalalignment','right',...
                            'String',dataStr32,'interpreter','tex','fontsize',9);
                    end

                    if min(size(opt.block.Xp)) > 1
                        figFilename = ['Overview ' opt.baseFileName];
                    else
                        if ij == 2
                            figFilename = ['Overview ' opt.baseFileName '1DCalibValues'];
                        else
                            figFilename = ['Overview ' opt.baseFileName '2DToeValues'];
                        end
                    end
                    print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r300');
                    savefig(fullfile(opt.outputFolder,figFilename));
                
                end
            end
        end
        function bathyOut = profTobathy(sctInput)
            % bathyOut = profTo2Dbathy(sctInput,dim);
            %
            % Convert post-storm profile to bathy file for SWASH
            % Inputs:
            % sctInput: Input structure, containing the following fields:
            
            %Defaults
            sctInput = Util.setDefault(sctInput,'DykeHoriz',200);
            sctInput = Util.setDefault(sctInput,'OffshoreHoriz',100);
            sctInput = Util.setDefault(sctInput,'OffshoreZ',-15);
            sctInput = Util.setDefault(sctInput,'OffshoreSlope',1/35);
            sctInput = Util.setDefault(sctInput,'dx',2);
            sctInput = Util.setDefault(sctInput,'offshoreWGInputfile','gauge5mTAW.wvg');
            sctInput = Util.setDefault(sctInput,'dykeToeWGInputfile','gaugeDykeToe.wvg');
            sctInput = Util.setDefault(sctInput,'dykeTopWGInputfile','gaugeDykeTop.wvg');
            sctInput = Util.setDefault(sctInput,'bottomFile','swash.bot');
            sctInput = Util.setDefault(sctInput,'dim',1);
            sctInput = Util.setDefault(sctInput,'DykeTopHoriz',2*sctInput.dx);
            sctInput = Util.setDefault(sctInput,'DykeBackslope',1/5);
            sctInput = Util.setDefault(sctInput,'DykeBackslopeHoriz',150);
            sctInput = Util.setDefault(sctInput,'dykeToeXDef','manual');
            sctInput = Util.setDefault(sctInput,'clipWithDepth',true);
            sctInput = Util.setDefault(sctInput,'offshoreClipZ',-5);   
            
            % Put in a few defaults for 1D or 2D
            switch sctInput.dim
                case 1
                    sctInput = Util.setDefault(sctInput,'dy',4);
                    sctInput = Util.setDefault(sctInput,'ny',0);
                    sctInput = Util.setDefault(sctInput,'yWG',0);
                case 2
                    sctInput = Util.setDefault(sctInput,'dy',4);
                    sctInput = Util.setDefault(sctInput,'ny',100);
                    sctInput = Util.setDefault(sctInput,'yWG',[100 200 300]);
            end
            
            fprintf('Processing profile %s.\t',sctInput.RunName);
            
            % Read input profile
            prof = readtable(sctInput.ProfileFile);
            
            % Make a raw profile - dx doesn't matter yet, will reinterpolate later
            xRaw = prof.dist(:)';
            zRaw = prof.bath(:)';
            zInitial=prof.bathInit(:)';
            
            
            switch sctInput.dykeProfile % What to do with the dyke
                case 'removeDyke' %Remove and replace with a flat profile
                    
                    % Find toe of dyke
                    switch sctInput.dykeToeXDef
                        case 'manual'
                            xToe = sctInput.DykeToeX;
                            zToe = interp1(xRaw,zRaw,xToe);
                            
                        case 'auto'
                            
                            % Take last wet point as the dike dike toe point
             
                            zToeInd = min(find(zRaw > sctInput.swl2D));
                            zToeInd = zToeInd - 1;
                            xToe = xRaw(zToeInd);
                            zToe = zRaw(zToeInd);

                    end
                    
                    % Check that there is no 1:10 slope before the dike toe 
                    
                    dzdx(1) = 0;
                    for j = 2:length(xRaw)
                        dzdx(j) = (zRaw(j) - zRaw(j-1))/(xRaw(j) - xRaw(j-1));
                    end

                    iSteeper = min(find(dzdx > 1/10)); 

                    if ~isempty(iSteeper)
                        if xRaw(iSteeper - 1) < xToe
                            xToe = xRaw(iSteeper - 1);
                            zToe = zRaw(iSteeper - 1);
                        end
                    end

                    bathyOut.xToe = xToe;
                    sctInput.DykeToeX = xToe;

                    
                    % Clip at toe of dyke and add 200 landward
                    xRaw2 = [xRaw(xRaw<=xToe) xToe xToe+sctInput.DykeHoriz];
                    zRaw2 = [zRaw(xRaw<=xToe) zToe zToe];
                    
                    % Remove stuff seaward of -5m TAW or a defined X value 
                    if sctInput.clipWithDepth == 1                   % If clipping is done based on Z
                        i1 = find(zRaw2>sctInput.offshoreClipZ,1);
                        xRaw2(1:i1-1)=[];
                        zRaw2(1:i1-1)=[];
                        xOffset0 = xRaw2(1);
                        xRaw2 = xRaw2-xOffset0;
                    else                                             % If not, it is done based on X
                        i1 = find(xRaw2<sctInput.offshoreClipX);
                        xRaw2(1:i1(end))=[];
                        zRaw2(1:i1(end))=[];
                        xOffset0 = xRaw2(1);
                        xRaw2 = xRaw2-xOffset0;
                    end
                                            
                    % Add 1:35 slope at the seaward edge
                    if zRaw2(1)>sctInput.OffshoreZ;
                        
                        xOffset = sctInput.OffshoreHoriz + ...
                            (zRaw2(1)-sctInput.OffshoreZ)/sctInput.OffshoreSlope;
                        xRaw3 = [0  sctInput.OffshoreHoriz xRaw2+xOffset];
                        zRaw3 = [sctInput.OffshoreZ sctInput.OffshoreZ zRaw2];
                    else
                        xRaw3 = [0 sctInput.OffshoreHoriz+xRaw2-xRaw2(1)]
                        zRaw3 = [zRaw2(1) zRaw2];
                        xOffset = sctInput.OffshoreHoriz;
                    end
                    xOffset = xOffset-xOffset0;
                    %Make last point divisible by dx
                    xRaw3(end) = sctInput.dx * ceil(xRaw3(end)/sctInput.dx);
                    
                    %Remove duplicates
                    [xRaw3,zRaw3] = Interpolate.preprocess(xRaw3,zRaw3);
                    % Interpolate to correct grid resolution;
                    xSwash = ([0:sctInput.dx:xRaw3(end)]);
                    zSwash = interp1(xRaw3,zRaw3,xSwash);
                case 'overtopDyke' %Replace dyke with an overtopping measurement point and basin
                    % Find toe of dyke
                    %                     xTop = sctInput.DykeTopX;
                    [~,xTopI] = min(abs(xRaw-sctInput.DykeTopX));
                    xTop = xRaw(xTopI);
                    zTop = interp1(xRaw,zRaw,xTop,'nearest');
                    
                    % Clip at top of dyke
                    xRaw2 = [xRaw(xRaw<xTop) xTop ];
                    zRaw2 = [zRaw(xRaw<xTop) zTop ];
                    
                    
                     % Remove stuff seaward of -5m TAW or a defined X value 
                    if sctInput.clipWithDepth == 1                   % If clipping is done based on Z
                        i1 = find(zRaw2>sctInput.offshoreClipZ,1);
                        xRaw2(1:i1-1)=[];
                        zRaw2(1:i1-1)=[];
                        xOffset0 = xRaw2(1);
                        xRaw2 = xRaw2-xOffset0;
                    else                                             % If not, it is done based on X
                        i1 = find(xRaw2<sctInput.offshoreClipX);
                        xRaw2(1:i1(end))=[];
                        zRaw2(1:i1(end))=[];
                        xOffset0 = xRaw2(1);
                        xRaw2 = xRaw2-xOffset0;
                    end
                                 
                    % Add 1:35 slope at the seaward edge
                    if zRaw2(1)>sctInput.OffshoreZ;
                        
                        xOffset = sctInput.OffshoreHoriz + ...
                            (zRaw2(1)-sctInput.OffshoreZ)/sctInput.OffshoreSlope;
                        xRaw3 = [0  sctInput.OffshoreHoriz xRaw2+xOffset];
                        zRaw3 = [sctInput.OffshoreZ sctInput.OffshoreZ zRaw2];
                    else
                        xRaw3 = [0 sctInput.OffshoreHoriz+xRaw2-xRaw2(1)]
                        zRaw3 = [zRaw2(1) zRaw2];
                        xOffset = sctInput.OffshoreHoriz;
                    end
                    xOffset = xOffset-xOffset0;
                    
                    % Extra points near dyke edge for nice discretization
                    [~,Imin] = min(abs(xRaw3-(xRaw3(end)-0.5)));
                    if abs(zRaw3(end) - zRaw3(Imin))>0.05
                        xEdge = sctInput.dx .* (ceil(xRaw3(end)/sctInput.dx));
                        xEdge = [xEdge-sctInput.dx xEdge];

                        [xRaw3,zRaw3] = Interpolate.preprocess(xRaw3,zRaw3);

                        zEdge = [interp1(xRaw3,zRaw3,xEdge(1)) zTop];

                        xRaw4 = [xRaw3(1:end-1) xEdge];
                        zRaw4 = [zRaw3(1:end-1) zEdge];
                    else
                        xRaw4 = xRaw3;
                        zRaw4 = zRaw3;
                    end

                    
                    % Interpolate to correct grid resolution;
                    [xRaw4,zRaw4] = Interpolate.preprocess(xRaw4,zRaw4);
                    
                    xSwash1 = ([0:sctInput.dx:xRaw4(end)]);
                    zSwash1 = interp1(xRaw4,zRaw4,xSwash1);
                    
                    % Add 2 grid cells at the top of the dyke
                    xDykeTopGauge = xSwash1(end)+sctInput.dx;
                    xSwash2 = [xSwash1 xSwash1(end)+sctInput.dx*[1 2]];
                    zSwash2 = [zSwash1 zSwash1(end).*[1 1]];
                    
                    % Add back slope
                    xSwash = [xSwash2 xSwash2(end)+(sctInput.dx:sctInput.dx:sctInput.DykeBackslopeHoriz)];
                    zSwash = [zSwash2 zSwash2(end)-(sctInput.dx:sctInput.dx:sctInput.DykeBackslopeHoriz)*sctInput.DykeBackslope];
            end
            
            
            
            
            
            fprintf('nx = %u . Lx = %.1f.\n',numel(xSwash)-1,xSwash(end)-xSwash(1));
            
            % Write bathy to file
            outFile = fullfile(sctInput.SwashRootRunFolder,...
                sctInput.RunName,sctInput.bottomFile);
            fprintf('Writing bathy to %s.\n',outFile);
            outFolder = fileparts(outFile);
            if ~(exist(outFolder,'dir')>0);
                mkdir(outFolder);
            end
            [fid,errMsg]=fopen(outFile,'w+');
            for i = 1:sctInput.ny+1;
                fprintf(fid,'%6.4f ',zSwash);
                fprintf(fid,'\n');
            end
            fclose(fid);
            
            % Wave gauge locations
            % 1. Wave gauges at -5 m TAW or at the clipping offshore point
            if sctInput.clipWithDepth == 1 
                mask = zSwash>(sctInput.offshoreClipZ-1) & (zSwash<sctInput.offshoreClipZ+1) & xSwash<sctInput.DykeToeX+xOffset; %Find points between -4 and -6 m TAW
                xGauge5 = (interp1(zSwash(mask),xSwash(mask),-5,'linear')); %Find x position of -5 m TAW by interpolation
            else
                xGauge5 = sctInput.offshoreClipX + xOffset;                           % If it is defined by an offshore clipping X value, take that one
            end
            
            gauge5TawFile =  fullfile(sctInput.SwashRootRunFolder,...
            sctInput.RunName,sprintf('%s',sctInput.offshoreWGInputfile));
            [fid,errMsg]=fopen(gauge5TawFile,'w+');
            for i = 1:numel(sctInput.yWG);
                fprintf(fid,'%6.4f %6.4f\n',xGauge5,sctInput.yWG(i));% -5 m TAW gauge
            end
            fclose(fid);
            
           
            
            % 2. Wave gauges at dyke Toe
            
            gaugeDykeToeFile =  fullfile(sctInput.SwashRootRunFolder,...
                sctInput.RunName,sprintf('%s',sctInput.dykeToeWGInputfile));
            [fid,errMsg]=fopen(gaugeDykeToeFile,'w+');
            for i = 1:numel(sctInput.yWG);
                fprintf(fid,'%6.4f %6.4f\n',sctInput.DykeToeX+xOffset,sctInput.yWG(i));
            end
            fclose(fid);
            
            
            % 3. Wave gauges at dyke Top
            if strcmp(sctInput.dykeProfile,'overtopDyke')
                gaugeDykeTopFile =  fullfile(sctInput.SwashRootRunFolder,...
                    sctInput.RunName,sprintf('%s',sctInput.dykeTopWGInputfile));
                [fid,errMsg]=fopen(gaugeDykeTopFile,'w+');
                for i = 1:numel(sctInput.yWG);
                    fprintf(fid,'%6.4f %6.4f\n',xDykeTopGauge,sctInput.yWG(i));
                end
                fclose(fid);
                
                xGaugePlot = [xGauge5,sctInput.DykeToeX+xOffset,xDykeTopGauge];
                nameGaugePlot = {'5 m TAW','Dyke Toe','Dyke top'};
            else
                xGaugePlot = [xGauge5,sctInput.DykeToeX+xOffset];
                nameGaugePlot = {'5 m TAW','Dyke Toe'};
            end
            
            
            % Make control plot
            CosaTool.plotSwashBathy(xRaw,zRaw,xSwash,zSwash,xOffset,...
                xGaugePlot,nameGaugePlot,sctInput.RunName);
            figFilename = ['bathyProfile'];
            
            print(fullfile(sctInput.SwashRootRunFolder,...
                sctInput.RunName,figFilename),'-dpng','-r220');
            savefig(fullfile(sctInput.SwashRootRunFolder,...
                sctInput.RunName,figFilename));
            
            % Give back some output
            bathyOut.nx = numel(xSwash)-1;
            bathyOut.lenx = max(xSwash)-min(xSwash);
            bathyOut.xOffset = xOffset;
        end
        
        function prof = superSampleProfile(profCoarse)
            dx = 0.01;
            
            %Hi-res version
            prof = table;
            prof.dist = (profCoarse.dist(1):dx:profCoarse.dist(end))';
            prof.bathInit = interp1(profCoarse.dist,profCoarse.bathInit,...
                prof.dist);
            prof.bath = interp1(profCoarse.dist,profCoarse.bath,...
                prof.dist);
        end
            
        function [] = Swash2DPreprocess(opt)
            % [] = Swash2DPreprocess(opt)
            %
            % Swash 2D overtopping run preparation
            %
            %
            % Inputs: opt structure, containing:
            %     opt.outputFolder Results folder (where the table will be saved);
            %     opt.maxIter Maximum iterations. Default = 10;
            % Outputs:
            % output %Structure with relevant outputs
            %
            opt = Util.setDefault(opt,'offshoreWGInputfile','gauge5mTAW.wvg');
            opt = Util.setDefault(opt,'dykeToeWGInputfile','gaugeDykeToe.wvg');
            opt = Util.setDefault(opt,'dykeTopWGInputfile','gaugeDykeTop.wvg');
            opt = Util.setDefault(opt,'bottomFile','swash.bot');
            
            filesToCopy = {
                'bottomFile'
                'offshoreWGInputfile'
                'dykeToeWGInputfile'
                };
            
            fprintf('SWASH 2D run preprocessing of profile %s.\n',opt.RunName);
            
            
            runOpt.directory = fullfile(opt.Swash2DRootRunFolder,...
                sprintf('%s',opt.RunName));
            runOpt.filename = 'swash2D.sws';
            runOpt.nx = opt.nxCalib;
            runOpt.lenx = opt.lenxCalib;
            runOpt.swl = opt.swl2D;
            runOpt.Hm0 = 1.07*opt.offshoreHm02D; % Changed from 1.01 to 1.07 on 25/07/19
            runOpt.Tp = opt.offshoreTp2D;
            
            
            % Write Swash input file
            Swash.writeInput(opt.protorun2D,runOpt);
            
            
            % Copy bathy and wave gauge files
            for iF = 1:numel(filesToCopy)
                copyfile(fullfile(opt.bathyRunFolder,opt.RunName,opt.(filesToCopy{iF})),...
                    fullfile(runOpt.directory,opt.(filesToCopy{iF})));
            end
            
            
            % Copy sub file
            copyfile(opt.protosub2D,fullfile(runOpt.directory,'run_swash.sub'));
            
        end
        
        
        
        
        function [opt] = swashStandardPostprocess(opt)
            % [] = CosaTool.swashStandardPostprocess(opt);
            %
            % POSTPROCESS CALIBRATION SWASH RUN
            % Loads swash 2D output and plots a spectrum figure, cross-shore profile of
            % wave height and period, and spatial views of wave height and setup
            % Inputs: opt structure, containing:
            %     opt.runFolder Run folder
            %     opt.blockFile Name of block file
            %     opt.steeringFile Name of steering file
            %     opt.analysisDur Analysis duration for spectrum
            %     opt.nSamp Number of samples in window for spectrum (Welch's method)
            %     opt.smooth Smoothing window for spectrum
            %     opt.fCutoff Cut-off frequency for Tm-1,0
            %     opt.plotResults Whether to generate some standard output plots
            % Outputs:
            % output %Structure with relevant outputs
            %
            
            if exist('xb_read_output','file')==0
                addOpenEarth
            end
            
            opt = Util.setDefault(opt,'steeringFile','swash.sws');
            opt = Util.setDefault(opt,'analysisDur',40*60);
            opt = Util.setDefault(opt,'analysisDurOvertop',100*60);
            opt = Util.setDefault(opt,'nSamp',300);
            opt = Util.setDefault(opt,'smooth',1);
            opt = Util.setDefault(opt,'fCutoff',[0.005 0.5]);
            opt = Util.setDefault(opt,'plotResults',true);
            
            
            %% Read data from steering file
            % Read water level from steering file
            steeringString = readfile(fullfile(opt.runFolder,opt.steeringFile));
            refLevel = regexpi(steeringString','SET LEVEL\s*[\d.]*','match');
            refLevel = textscan(refLevel{1},'SET LEVEL %f');
            opt.refLevel = refLevel{1};
            
            targetSpecStr = regexpi(steeringString','SPECT \s*[\d.]* \s*[\d.]*','match');
            targetSpecVals = textscan(targetSpecStr{1},'SPECT %f %f');
            opt.targetHm0 = targetSpecVals{1};
            opt.targetTp = targetSpecVals{2};
            
            % Process offshore (5m TAW) wave gauge data
            if isfield(opt,'offshoreWGResultfile')
                wgOpt = opt;
                wgOpt.wgFile = opt.offshoreWGResultfile;
                opt.offGauge = CosaTool.swashWgStandardProcess(wgOpt);
            end
            
            % Process dyke toe wave gauge data
            if isfield(opt,'dykeToeWGResultfile')
                wgOpt = opt;
                wgOpt.wgFile = opt.dykeToeWGResultfile;
                opt.toeGauge = CosaTool.swashWgStandardProcess(wgOpt);
            end
            
            % Process dyke top wave gauge data (for overtopping)
            if isfield(opt,'dykeTopWGResultfile')
                wgOpt = opt;
                wgOpt.wgFile = opt.dykeTopWGResultfile;
                [opt.topGauge,opt.topGaugeTS] = CosaTool.swashWgStandardProcess(wgOpt);
                
                % Set velocity and water level to zero for very thin layers
                
                if max(opt.topGaugeTS.Botlev.data) < 0 % If the overtopping point is dry
                    mask = opt.topGaugeTS.Depth.data <= 5e-3; % If the overtopping point is a dry point
                else
                    error('The overtopping point is a wet point')
                end    
                
                opt.topGaugeTS.Qksi.data(mask)=0;
                opt.topGaugeTS.Vksi.data(mask)=0;
                %
                mask = opt.topGaugeTS.Time.data > opt.topGaugeTS.Time.data(end) - opt.analysisDurOvertop;
                
                opt.overtopVol = trapz(opt.topGaugeTS.Time.data(mask),...
                    opt.topGaugeTS.Qksi.data(mask))/opt.analysisDurOvertop;

                opt.overtopVol2 = trapz(opt.topGaugeTS.Time.data(mask),...
                    opt.topGaugeTS.Depth.data(mask).*opt.topGaugeTS.Vksi.data(mask))/...
                    opt.analysisDurOvertop;

                
                fprintf('Overtopping volume %s : %.3f m^3/(m s) = %.3f l/(m s).\n',...
                    opt.RunName,opt.overtopVol,opt.overtopVol*1000)
            end
            
            % Load Block file
            if isfield(opt,'blockResultfile');
                opt.block = load(fullfile(opt.runFolder,opt.blockResultfile));
            end
            
            % Plot results
            if opt.plotResults
                opt = Util.setDefault(opt,'outputFolder',fullfile(opt.resultsRootFolder,opt.RunName));
                
                if ~exist(opt.outputFolder,'dir')
                    mkdir(opt.outputFolder);
                end
                CosaTool.plotSwashOutput(opt);
            end
            
            
        end
        
        function [gauge,wgData] = swashWgStandardProcess(opt)
            % Do standard processing of Swash WG within Coastal Safety
            % Framework
            %
            % [gauge,wgData] = swashWgStandardProcess(opt);
            
            % Process data file
            % If the table file has not yet been converted to Matlab, convert it now.
            % If it has been converted, load the mat file
            [~,tabFile1,~]=fileparts(char(opt.wgFile));
            
            if ~exist(fullfile(char(opt.runFolder),[tabFile1 '_table.mat']),'file');
                
                
                wgData = Swash.readTableData(fullfile(char(opt.runFolder),char(opt.wgFile)));
                Dataset.saveData(wgData,fullfile(char(opt.runFolder),[tabFile1 '_table.mat']));
            else
                matFile= dir(fullfile(char(opt.runFolder),[tabFile1,'_table.mat']));
                txtFile = dir(fullfile(char(opt.runFolder),char(opt.wgFile)));
                if matFile.datenum > txtFile.datenum %If Matfile is newer than txt file
                    wgData = Dataset.loadData(fullfile(char(opt.runFolder),[tabFile1 '_table.mat']));
                else
                    
                    wgData = Swash.readTableData(fullfile(char(opt.runFolder),char(opt.wgFile)));
                    Dataset.saveData(wgData,fullfile(char(opt.runFolder),[tabFile1 '_table.mat']));
                end
            end
            
            for i = 1:size(wgData.Watlev.data,2);
                dry = wgData.Watlev.data(:,i)<-98;
                wgData.Watlev.data(dry,i) = -1*wgData.Botlev.data(1,i);
            end
            
            wgData.Watlev.data = wgData.Watlev.data + opt.refLevel;
            
            % Process timeseries into spectra and sig wave heigth
            
            wgSpec = Swash.gaugeSpectral(wgData,opt);
            
            % If there are multiple wave gauges at 1 cross-shore position
            % -> average
            
            if numel([wgSpec.x])>1 && isequal(wgSpec.x)
                
                gauge.x = wgSpec(1).x;
                gauge.f = wgSpec(1).f;
                gauge.Sf = mean([wgSpec.Sf],2);
                gauge.Hm0 = mean([wgSpec.Hm0],2);
                gauge.Tmm10 = mean([wgSpec.Tmm10],2);
                gauge.setup = mean([wgSpec.setup],2);
                gauge.Hm0_max = max([wgSpec.Hm0]);
                gauge.Hm0_min = min([wgSpec.Hm0]);
                gauge.Tmm10_max = max([wgSpec.Tmm10]);
                gauge.Tmm10_min = min([wgSpec.Tmm10]);
            else
                gauge = wgSpec;
            end
            %% Write some reporting tables
            fprintf('%-20s\t%-8s\t%-8s\t%-8s\t%-8s\n',...
                'Name','x','Hm0','Tmm10','MWL')
            fprintf('%-20s\t%-8.2f\t%-8.2f\t%-8.2f\t%-8.2f\n',...
                opt.wgFile,...
                gauge.x,...
                gauge.Hm0,...
                gauge.Tmm10,...
                gauge.setup ...
                );
            
        end
        
        function  watlevTide = interpTide(tTide,wl,tWlInp,stormDuration)
            % watlevTide = interpTide(tTide,wl,tWlInp,stormDuration)
            %
            % Interpolates and shifts the tidal curve
            %
            % INPUT:
            %
            % - tTide: input time (with respect to HW) [days]
            % - wl: input water levels.
            % - tWlInp:  [Nx1] times that the timeseries need to be made [days].
            %
            % Note that the peak of the storm is supposed to be at time 0.
            %
            % - stormDuration: [1x1] duration of the simulation period [days]
            %
            % OUTPUT:
            % - WatlevTide
            
            
            % make column vector
            wl = Util.makeColVec(wl);
            tTide = Util.makeColVec(tTide);
            
            % copy input tides
            tWl = tWlInp - 0.5.*stormDuration;
            tideDuration = max(tTide)-min(tTide);
            nrTides = ceil(stormDuration/tideDuration);
            startTide = -ceil(nrTides/2);
            endTide   = -startTide;
            tTideTmp  = [];
            for i  = startTide:endTide
                tTideTmp = [tTideTmp;tTide+i*tideDuration];
            end
            wlTmp    = repmat(wl,endTide-startTide+1,1);
            
            % interpolate
            [tTideTmp,wlTmp] = Interpolate.preprocess(tTideTmp,wlTmp);
            watlevTide = interp1(tTideTmp,wlTmp,tWl);
            
        end
        
        function [] = writeProfile()
            % [] = writeProfile()
            % write profile data in Swash format
            
        end
        
        
        function writeStormTs(fileName,time,data)
            % writeStormTs(fileName,time,data)
            %
            % write design storm time series to XBeach input files
            %
            % INPUT:
            %
            % - fileName: file to be written
            % - time: Nx1 vector with the time (in matlab format)
            % - data: NxM matrix with data for m different variables
            %
            
            
            % open file
            fid = fopen(fileName,'w');
            if fid<0
                error([fileName, 'cannot be opened for writing']);
            end
            
            % convert time to matlab format
            if ~isempty(time)
                time = (time-time(1))*86400;
                %write data
                format = [repmat('%f ',1,size(data,2)+1),'\n'];
                fprintf(fid,format,[time,data]');
            else
                format = [repmat('%f ',1,size(data,2)),'\n'];
                fprintf(fid,format,data');
            end
            
            fclose(fid);
        end
        
        
        function [] = xbeachStandardPostprocess(opt)
            % Standard XBeach postprocess (obsolete and replaced by
            % XBeach.standardPostProcess)
            
            warning('CosaTool.xbeachStandardPostprocess is now XBeach.standardPostProcess. Please update your links.');
            XBeach.standardPostprocess(opt);
        end
        
            
       function [opt] = adjustBathy(opt,labels)
            
            % HCA - 05/2019
            
            % Adjust bathymetry to be further adapted with the different
            % building blocks by the functions dunePreproc, dikePreproc, stormWallPreproc, nourishPreproc. 
            % This function:
            %
            % 1. Removes Nan's at the begining and at the end of the
            % bathymetry vector, if any.
            % 2. Adapts the cross-shore resolution
            % 3. Removes values landward of the safety line
            % 4. Removes values seaward of the offshore clipping point
            % 5. Flips the vector if elevation decreases.
            %
            % INPUT:
            %
            % opt.bathyData: Bathymetry vector given by the X and Z
            % coordinates (sctInput.bathyData.X, sctInput.bathyData.Z)
            % labels: labels for the figures
            % opt.crossResol: new profile resolution
            % opt.xSafLine or opt.zSafLine: indicates the points from which
            % landward points will be removed
            % opt.xOffClip or opt.zOffClip: indicates the points from which
            % seaward points will be removed
                

            
            % OUTPUT:
            %
            % opt.bathyData: Adjusted bathymetry
            
            opt = Util.setDefault(opt,'zOffClip',-5);
            opt = Util.setDefault(opt,'crossResol',0.1);
            opt = Util.setDefault(opt,'language',1);

                                                
            
            % Check length of X and Z vectors
            
            if length(opt.bathyData.X) ~= length(opt.bathyData.Z)
                error('X and Z vectors must have the same length')
            end
            
            %Figure check
            
            figure
            hold on; box on; grid on;
            plot(opt.bathyData.X, opt.bathyData.Z, '-','LineWidth',1.5,'displayname',labels.InputBathyDisplay{opt.language})
            lgd = legend;
            ylim([min(opt.bathyData.Z),max(opt.bathyData.Z)+1])
            xlabel('x [m]')
            ylabel('z [m TAW]')
            
            % 1. Remove points if there are NaN's at the beginning or at the end of the Z vector 
           
            checkNan = isnan(opt.bathyData.Z);       
            
            maskNan = [min(find(checkNan == 0)):max(find(checkNan == 0))];
            
            plot([opt.bathyData.X(maskNan(1)),opt.bathyData.X(maskNan(1))], [min(opt.bathyData.Z),max(opt.bathyData.Z )],'k--','LineWidth',1.2,'displayname',labels.NaNThreshDisplay{opt.language})
            plot([opt.bathyData.X(maskNan(end)),opt.bathyData.X(maskNan(end))], [min(opt.bathyData.Z),max(opt.bathyData.Z )],'k--','LineWidth',1.2,'handlevisibility','off')
            
            opt.bathyData.X = opt.bathyData.X (maskNan);
            opt.bathyData.Z = opt.bathyData.Z (maskNan);
            
            
           %. 2. Check if the point resolution is the required. If not, interpolate.

                                         
            if any(abs(diff(opt.bathyData.X))~=opt.crossResol)
                bathyXOld = opt.bathyData.X;
                opt.bathyData.X = transpose([opt.bathyData.X(1):opt.crossResol:floor(opt.bathyData.X(end)*10)/10]);
                opt.bathyData.Z = interp1(bathyXOld, opt.bathyData.Z, opt.bathyData.X);
                clear bathyXOld
            end
            
            % 3. Remove points landward of the safety line (defined by x (opt.xSafLine) or
            % z coordinate (opt.zSafLine)) 
            
            %Check if bed elevation (Z) is decreasing or increasing
            
            if mean(opt.bathyData.Z(1:floor(length(opt.bathyData.Z)/2))) ...             
                    > mean(opt.bathyData.Z(end-(floor(length(opt.bathyData.Z)/2)):end))
                decreas = 1;                
            else
                decreas = 0;                
            end
            
            % Clip values landward of the safety line
                            
            if decreas == 1
                if isfield(opt,'xSafLine')
                    maskSaf = find(opt.bathyData.X >= opt.xSafLine);
                elseif isfield(opt,'zSafLine')
                    maskSaf = [max(find(opt.zSafLine < opt.bathyData.Z)) + 1:length(opt.bathyData.Z)];
                end
            elseif decreas == 0
                if isfield(opt,'xSafLine')
                     maskSaf = find(opt.bathyData.X <= opt.xSafLine);
                elseif isfield(opt,'zSafLine')  
                     maskSaf = [1:min(find(opt.zSafLine<opt.bathyData.Z))-1];
                end 
            end
            
            if ~exist('maskSaf')
                maskSaf = [1:length(opt.bathyData.Z)];              
            end
            
            if decreas == 1
                plot([opt.bathyData.X(maskSaf(1)),opt.bathyData.X(maskSaf(1))], [min(opt.bathyData.Z),max(opt.bathyData.Z)],'-','LineWidth',1.2,'displayname',labels.SafLineDisplay{opt.language})
            else decreas == 0
                plot([opt.bathyData.X(maskSaf(end)),opt.bathyData.X(maskSaf(end))], [min(opt.bathyData.Z),max(opt.bathyData.Z)],'-','LineWidth',1.2,'displayname',labels.SafLineDisplay{opt.language})
            end
         
            opt.bathyData.X = opt.bathyData.X(maskSaf);
            opt.bathyData.Z = opt.bathyData.Z(maskSaf);
                        
            
            %  4. Remove points seaward of a certain offshore clipping value (defined by x (opt.xOffClip) or
            % z coordinate (opt.zOffClip))
            
            if isfield(opt,'xOffClip')
                    [~,posOffClip] = min(abs(opt.bathyData.X - opt.xOffClip));
                
            elseif isfield(opt,'zOffClip')
                    [~,posOffClip] = min(abs(opt.bathyData.Z - opt.zOffClip));
            end
                
            

            if decreas == 1
               maskOffClip = [1:posOffClip];  
               plot([opt.bathyData.X(maskOffClip(end)),opt.bathyData.X(maskOffClip(end))], [min(opt.bathyData.Z),max(opt.bathyData.Z)],'-','LineWidth',1.2,'displayname',labels.OffshClipDisplay{opt.language})
            elseif decreas == 0
               maskOffClip = [posOffClip:length(opt.bathyData.X)];  
               plot([opt.bathyData.X(maskOffClip(1)),opt.bathyData.X(maskOffClip(1))], [min(opt.bathyData.Z),max(opt.bathyData.Z )],'-','LineWidth',1.2,'displayname',labels.OffshClipDisplay{opt.language})
            end


            
            opt.bathyData.X = opt.bathyData.X(maskOffClip);
            opt.bathyData.Z = opt.bathyData.Z(maskOffClip);


            % 5. Flip vector if sea bed elevation is decreasing
             
            if decreas == 1
               opt.bathyData.Z = flipud(opt.bathyData.Z);
            end
            
            opt.bathyData.X = opt.bathyData.X - opt.bathyData.X(1);
            
        end
        
        function [opt] = defineDikePos(opt,labels)
            
            % HCA - 05/2019
            
            % Define the position of the dike, both the crest and the toe
            % INPUT:
            %
            % For the dike toe:
            % opt.xDikeToe or opt.zDikeToe : X, Z dike toe positions
            %
            % For the dike crest:
            % opt.xDikeCrest or opt.zDikeCrest : X, Z dike crest positions
            %
            % labels: labels for the figures
            % OUTPUT:
            %
            % opt.zDikeToe, opt.xDikeToe, opt.xDikeCrest, opt.zDikeCrest:  The remaining x or z values 
            
            figure
            hold on; box on; grid on;
            plot(opt.bathyData.X, opt.bathyData.Z, '-','LineWidth',1.5,'displayname',labels.InitialProfDisplay{opt.language})
            lgd = legend;
            set(lgd,'location','northwest')
            xlabel('x [m]')
            ylabel('z [m TAW]')
            
            % First, find values for dike toe
            
            if isfield(opt,'xDikeToe')
                [~,locXToe] = min(abs(opt.bathyData.X - opt.xDikeToe));
                opt.zDikeToe = opt.bathyData.Z(locXToe);
            elseif isfield(opt,'zDikeToe')
                [~,locZToe] = min(abs(opt.bathyData.Z - opt.zDikeToe));
                opt.xDikeToe = opt.bathyData.X(locZToe);
            end
            set(gca,'ColorOrderIndex',2)
            plot([opt.xDikeToe,opt.xDikeToe], [min(opt.bathyData.Z),max(opt.bathyData.Z )],'-','LineWidth',1.2,'displayname',labels.DikeToeDisplay{opt.language})
            set(gca,'ColorOrderIndex',2)
            plot([min(opt.bathyData.X),max(opt.bathyData.X)], [opt.zDikeToe,opt.zDikeToe],'-','LineWidth',1.2,'handlevisibility','off')

                   
            % Now, do the same for the dike crest
            
             if isfield(opt,'xDikeCrest')
                [~,locXCrest] = min(abs(opt.bathyData.X - opt.xDikeCrest));
                opt.zDikeCrest = opt.bathyData.Z(locXCrest);
             elseif isfield(opt,'zDikeCrest')
                [~,locZCrest] = min(abs(opt.bathyData.Z - opt.zDikeCrest));
                opt.xDikeCrest = opt.bathyData.X(locZCrest);
             end
            set(gca,'ColorOrderIndex',3)
            plot([opt.xDikeCrest,opt.xDikeCrest], [min(opt.bathyData.Z),max(opt.bathyData.Z )],'-','LineWidth',1.2,'displayname',labels.DikeCrestDisplay{opt.language})
            set(gca,'ColorOrderIndex',3)
            plot([min(opt.bathyData.X),max(opt.bathyData.X)], [opt.zDikeCrest,opt.zDikeCrest],'-','LineWidth',1.2,'handlevisibility','off')
            
            xlim([opt.xDikeToe - 25,max(opt.bathyData.X)])
            ylim([opt.zDikeToe - 0.5,max(opt.bathyData.Z)+1])
        end
        function [opt] = defineDunePos(opt,labels)
            
            % HCA - 05/2019
            
            % Define the position of the dune toe
            % INPUT:
            %
            % For the dike toe:
            % opt.xDuneToe or opt.zDuneToe : X, Z dike toe positions
            % labels: labels for the figures
            %
            % OUTPUT:
            %
            % opt.zDuneToe, opt.xDuneToe:  The remaining x or z values 
            
            figure
            hold on; box on; grid on;
            plot(opt.bathyData.X, opt.bathyData.Z, '-','LineWidth',1.5,'displayname',labels.InitialProfDisplay{opt.language})
            lgd = legend;
            set(lgd,'location','northwest')
            xlabel('x [m]')
            ylabel('z [m TAW]')
            
            % First, find values for dike toe
            
            if isfield(opt,'xDuneToe')
                [~,locXToe] = min(abs(opt.bathyData.X - opt.xDuneToe));
                opt.zDuneToe = opt.bathyData.Z(locXToe);
            elseif isfield(opt,'zDuneToe')
                [~,locZToe] = min(abs(opt.bathyData.Z - opt.zDuneToe));
                opt.xDuneToe = opt.bathyData.X(locZToe);
            end
            set(gca,'ColorOrderIndex',2)
            plot([opt.xDuneToe,opt.xDuneToe], [min(opt.bathyData.Z),max(opt.bathyData.Z )],'-','LineWidth',1.2,'displayname',labels.DuneToeDisplay{opt.language})
            set(gca,'ColorOrderIndex',2)
            plot([min(opt.bathyData.X),max(opt.bathyData.X)], [opt.zDuneToe,opt.zDuneToe],'-','LineWidth',1.2,'handlevisibility','off')

            
            xlim([opt.xDuneToe - 25,max(opt.bathyData.X)])
            ylim([opt.zDuneToe - 0.5,max(opt.bathyData.Z)+1])
        end
        function opt = createInitialPatches(opt,labels)
            
            % HCA - 05/2019
            
            % Create and plot different patches. For visualization purposes.
           
            % INPUT:
            % opt.bathyData : Bathymetry data with X and Z coordinates
            % (opt.bathyData.X and opt.bathyData.Z)
            % opt.swl: Sea water level
            % opt.slr: Sea level Rise]
            % opt.dikeLog: Logical value. If 1, there is dike on the profile
            % opt.xDikeToe: X location of the dike, if existing
            % opt.language: 1. English. 2. Dutch
            % labels: labels for the figures
            %
            % OUTPUT
            %
            % opt.patches: X and Z coordinates for the different patches:
            % Beach, current level, current dike, and sea level rise
            % Plots with the current profile and the patches
            
            
             opt = Util.setDefault(opt,'language',1);
             opt = Util.setDefault(opt,'prestorm',1);
               
            % Patch Beach
            
            opt.patches.beachX = [transpose(opt.bathyData.X), opt.bathyData.X(end), opt.bathyData.X(1),opt.bathyData.X(1)];
            opt.patches.beachZ = [transpose(opt.bathyData.Z), min(opt.bathyData.Z), min(opt.bathyData.Z), opt.bathyData.Z(1)];
            
            % Patch SWL
            
            finalSwlPoint = min(find(opt.bathyData.Z > opt.swlXB))-1;
            
            if isempty(finalSwlPoint)
               finalSwlPoint = length(opt.bathyData.Z);
            end
            
            opt.patches.swlX = [opt.bathyData.X(1), opt.bathyData.X(finalSwlPoint), fliplr(transpose(opt.bathyData.X(1:finalSwlPoint-1)))];
            opt.patches.swlZ = [opt.swlXB, opt.swlXB, fliplr(transpose(opt.bathyData.Z(1:finalSwlPoint-1)))];
            
            % Patch SLR
            
            finalSlrPoint = min(find(opt.bathyData.Z > opt.swlXBslr))-1;     
            
            if isempty(finalSlrPoint)
                 finalSlrPoint = length(opt.bathyData.Z);
            end

            opt.patches.slrX = [opt.bathyData.X(1), opt.bathyData.X(finalSlrPoint), fliplr(transpose(opt.bathyData.X(finalSwlPoint+1:finalSlrPoint-1))),opt.bathyData.X(finalSwlPoint),opt.bathyData.X(1)];
            opt.patches.slrZ = [opt.swlXBslr, opt.swlXBslr, fliplr(transpose(opt.bathyData.Z(finalSwlPoint+1:finalSlrPoint-1))),opt.swlXB,opt.swlXB];
            
            % Patch dike
            
            if opt.dikeLog == 1 & isfield(opt,'xDikeToe')
                
               opt.patches.initialDikeX = [opt.xDikeToe, transpose(opt.bathyData.X(opt.bathyData.X > opt.xDikeToe)),opt.bathyData.X(end),opt.xDikeToe];
               opt.patches.initialDikeZ = [opt.zDikeToe, transpose(opt.bathyData.Z(opt.bathyData.X > opt.xDikeToe)), opt.zDikeToe,opt.zDikeToe];

            end
                
            % Patch dune
            
            if opt.duneLog == 1 & isfield(opt,'xDuneToe')
               opt.patches.initialDuneX = [opt.xDuneToe, transpose(opt.bathyData.X(opt.bathyData.X > opt.xDuneToe)),opt.bathyData.X(end),opt.xDuneToe];
               opt.patches.initialDuneZ = [opt.zDuneToe, transpose(opt.bathyData.Z(opt.bathyData.X > opt.xDuneToe)), opt.zDuneToe,opt.zDuneToe];
            end
            
            UtilPlot.reportFigureTemplate(15,5);
            hold on; box on;
            title(opt.RunName,'interpreter','none')
            if opt.prestorm == 1
                patch(opt.patches.beachX, opt.patches.beachZ,[242/255,209/255,107/255], 'EdgeColor', [242/255,209/255,107/255],'displayname',labels.InitialProfDisplay{opt.language})
            else
                patch(opt.patches.beachX, opt.patches.beachZ,[242/255,209/255,107/255], 'EdgeColor', [242/255,209/255,107/255],'displayname',labels.FinalProfDisplay{opt.language})
            end
            
            patch(opt.patches.swlX, opt.patches.swlZ,[0/255,119/255,190/255], 'EdgeColor', [0/255,119/255,190/255],'displayname',labels.SWLDisplay{opt.language})
           
            patch(opt.patches.slrX, opt.patches.slrZ, [21/255, 178/255, 209/255] , 'EdgeColor', [21/255, 178/255, 209/255],'displayname',labels.SWLSLRDisplay{opt.language})
            
            if isfield(opt.patches,'initialDikeX')
                 patch(opt.patches.initialDikeX, opt.patches.initialDikeZ, [105/255,105/255,105/255], 'EdgeColor', [105/255,105/255,105/255],'displayname',labels.OriginalDikeDisplay{opt.language})
            end
            if isfield(opt.patches,'initialDuneX') & opt.prestorm == 1 
                patch(opt.patches.initialDuneX, opt.patches.initialDuneZ, [212/255,197/255,173/255], 'EdgeColor',[212/255,197/255,173/255],'displayname',labels.OriginalDuneDisplay{opt.language})
            end
            lgd = legend;
            set(lgd,'location','northwest')
            xlabel('x [m]')
            ylabel('z [m TAW]')
            
        end
        
        function [opt,dike] = dikePreproc(opt,dike,labInput)
            
            % Function to place a higher dike on top of the given cross-shore profile
            % HCA - 05/19
            %
            % INPUT:
            %
            % opt.bathyData: Current profile (opt.bathyData.X and opt.bathyData.Z) and and latest modified profile (opt.bathyData.zLat) data
            % opt.bathyData.ne: non erodible layer
            % labInput: labels for plot
            %
            % Case 1: There is an existing dike (opt.dikeLog = 1)
            % dike.currentSlope: Logical value. 1 if the current dike slope is to be kept. 0 if not. If not, it needs to be defined by dike.dikeSlope
            % dike.dikeSlope: New dike slope if it is not to be kept
            % dike.heightInc: Height increment from the original dike crest
            %
            % Case 2: There is no existing dike (opt.dikeLog = 0)
            % dike.xDikeToe or dike.zDike.Toe: defines the new dike toe location
            % dike.dikeSlope: new dike slope
            % dike.heightInc: dike height from the dike toe
            
            
            % OUTPUT:
            % dike.xDikeCrest and zDikeCrest: Location of the new dike crest [X,Z]
            % dike.xDikeToe and zDikeToe: Location of the new dike toe [X,Z]
            % dike.extraArea: Area of the added dike [m^3/m]dune
            % opt.patches.dikeX, opt.patches.dikeZ: patches coordinates for plotting [X,Z] 
            % opt.bathyData.ne: adapted non erodible layer
            
            if opt.dikeLog == 1 & (isfield(opt,'xDikeToe') | isfield(opt,'zDikeToe'))    
                if dike.currentSlope == 1                
                    dike.dikeSlope = (opt.xDikeCrest - opt.xDikeToe)/(opt.zDikeCrest - opt.zDikeToe);
                end  

                dike.xDikeCrest = opt.xDikeCrest;
                dike.zDikeCrest = opt.zDikeCrest + dike.heightInc;

                % Seaward slope until it intersects the original profile

                [~,i] = min(abs(opt.bathyData.X - dike.xDikeCrest));                                                                       

                zIter = dike.zDikeCrest;
                while opt.bathyData.Z(i) < zIter
                     zIter = zIter - (opt.bathyData.X(i)-opt.bathyData.X(i-1))/dike.dikeSlope;
                     i = i-1;
                end

                dike.xDikeToe = opt.bathyData.X(i);                                                                                % X coordinate of the new dike toe (intersection with original profile)
                dike.zDikeToe = opt.bathyData.Z(opt.bathyData.X == dike.xDikeToe);                                                 % Z coordinate of the new dike toe (intersection with original profile)  


                % Add the new to the z profile

                maskDikeTop = find(opt.bathyData.X>= dike.xDikeCrest);
                opt.bathyData.Z (maskDikeTop) = opt.bathyData.Z(maskDikeTop) + dike.heightInc;

                maskDikeSlope = find(opt.bathyData.X>= dike.xDikeToe & opt.bathyData.X < dike.xDikeCrest);
                opt.bathyData.Z (maskDikeSlope) = interp1([dike.xDikeToe,dike.xDikeCrest],[dike.zDikeToe,dike.zDikeCrest],opt.bathyData.X(maskDikeSlope));

 
            else
                if isfield(dike,'xDikeToe')
                    [~,idikeToe] = min(abs(opt.bathyData.X - dike.xDikeToe)); 
                    dike.zDikeToe = opt.bathyData.Z(idikeToe);
                else
                    [~,idikeToe] = min(abs(opt.bathyData.Z - dike.zDikeToe)); 
                    dike.xDikeToe = opt.bathyData.X(idikeToe);
                end
                
                dike.xDikeCrest = dike.xDikeToe + dike.heightInc*dike.dikeSlope;
                dike.zDikeCrest = dike.zDikeToe + dike.heightInc;
                
                maskDikeSlope = find(opt.bathyData.X >= dike.xDikeToe & opt.bathyData.X<= dike.xDikeCrest);
                originalDikeSlopeZ = opt.bathyData.Z(maskDikeSlope);
                
                incCrest = dike.zDikeCrest - originalDikeSlopeZ(end);
                
                opt.bathyData.Z(maskDikeSlope) = interp1([dike.xDikeToe, dike.xDikeCrest],[dike.zDikeToe, dike.zDikeCrest],opt.bathyData.X(maskDikeSlope));
                
                
                maskDikeTop = find(opt.bathyData.X > dike.xDikeCrest);
                opt.bathyData.Z(maskDikeTop) = opt.bathyData.Z(maskDikeTop) + incCrest;
            end
            
               
            maskDike = [maskDikeSlope;maskDikeTop];
            
            % Adjust non erodible layer
            
            opt.bathyData.ne(maskDike) = 0;
            
            % Calculate area
            
            dike.extraArea = trapz(opt.bathyData.X (maskDike), opt.bathyData.Z(maskDike)) - trapz(opt.bathyData.X(maskDike), opt.bathyData.zLat(maskDike));

             
            % Create patches
            
            opt.patches.dikeX = [opt.bathyData.X(maskDike); flipud(opt.bathyData.X(maskDike))];
            opt.patches.dikeZ = [opt.bathyData.Z(maskDike); flipud(opt.bathyData.zLat(maskDike))];
            
            dike.extraAreaPatch = polyarea(opt.patches.dikeX, opt.patches.dikeZ);
            
            
           if abs(dike.extraArea - dike.extraAreaPatch ) > 0.5
                  error('The two dune calculated areas do not match')
           end
           
           dike = rmfield(dike, 'extraAreaPatch');

           % Control Plot - Dike

           UtilPlot.reportFigureTemplate(15,5);
           hold on; box on;
           plot(opt.bathyData.X, opt.bathyData.zInit,'-','LineWidth',3,'displayname',labInput.InitialProfDisplay{opt.language})
           set(gca,'ColorOrderIndex',4)
           plot([dike.xDikeToe,dike.xDikeCrest],[dike.zDikeToe,dike.zDikeCrest],'-','LineWidth',3,'displayname',labInput.SeawSlopeDisplay{opt.language})
           plot(opt.bathyData.X(opt.bathyData.X>dike.xDikeCrest),opt.bathyData.Z(opt.bathyData.X>dike.xDikeCrest),'-','LineWidth',3,'displayname',labInput.CrestDisplay{opt.language})
           set(gca,'ColorOrderIndex',5)
           plot(opt.bathyData.X, opt.bathyData.Z,'--','LineWidth',3,'displayname','FinalProfile')
           patch(opt.patches.dikeX, opt.patches.dikeZ, [200/255,200/255,200/255], 'EdgeColor', [200/255,200/255,200/255],'displayname',  labInput.HigherDikeDisplay{opt.language})
           lgd = legend;
           set(lgd,'location','northwest') 
           xlabel('x [m]')
           ylabel('z [m TAW]')
           
       end
            
        
            
        
        function [opt,dune] = dunePreproc(opt,dune,labInput,dike)
          
            % Function to place a dune on top of the given cross-shore profile
            % HCA - 05/19
            %
            % INPUT:
            % dune.seawardSlope: Dune seaward slope [cotg alpha]
            % dune.shorewardSlope: Dune shoreward slope [cotg alpha]
            % dune.duneHeight: Dune heigth [m]
            % dune.duneWidth: Dune width [m]
            % dune.duneFromDikeToe: Logical value. 1. Dune starts at the dike toe (then it needs both opt.xDikeToe and opt.zDikeToe, or the ones from a new dike: dike.xDikeToe,dike.zDikeToe)
            % dune.duneFromDikeCrest: Logical value. 1. Dune starts at the dike crest (then it needs both opt.xDikeCrest and opt.zDikeCrest, or the ones from a new dike: dike.xDikeCrest,dike.zDikeCrest)
            % dune.finalPointX or dune.finalPointZ: if the dune does not start from the dike toe or crest, the final (most landward point) needs to be specified
            % opt.bathyData: Current profile (opt.bathyData.X and opt.bathyData.Z) and latest modified profile (opt.bathyData.zLat) data
            % labInput: labels for plot
            %
            % OUTPUT:
            % dune.finalPointX and dune.finalPointZ: Most landward dune point [X,Z]
            % dune.xShoreSlope and dune.xShoreSlope: shoreward slope dune point [X,Z]
            % dune.xSeaSlope and dune.xSeaSlope: seaward slope dune point [X,Z]
            % dune.xDuneToe and dune.zDuneToe: most seaward (toe) dune point [X,Z]
            % dune.duneArea and dune.duneAreaPatch: dune area calculated in two different ways [m^3/m]
            % dune.totalWidth: Total dune width from the most landward to the most seaward point [m]
            % dune.maxHeight: Maximum heigth [m] 
            % opt.patches.duneX, opt.patches.duneZ: patches coordinates for plotting [X,Z] 
            % opt.bathyData.Z: Modify bed elevation including the dune
            
            % Calcute most landward point of the dune

                if dune.duneFromDikeToe == 1                        % If dune starts at the dike toe, that would be the dune most landward point
                    if exist('dike')
                        dune.finalPointX = dike.xDikeToe;
                        dune.finalPointZ = dike.zDikeToe;
                    elseif opt.dikeLog == 1
                        dune.finalPointX = opt.xDikeToe;
                        dune.finalPointZ = opt.zDikeToe; 
                    else
                        error('There is currently no dike');
                    end
                elseif dune.duneFromDikeCrest == 1 
                    if exist('dike')
                        dune.finalPointX = dike.xDikeCrest;
                        dune.finalPointZ = dike.zDikeCrest;
                    elseif opt.dikeLog == 1
                        dune.finalPointX = opt.xDikeCrest;
                        dune.finalPointZ = opt.zDikeCrest; 
                    else
                        error('There is currently no dike');
                    end
                else                                             % If not, dune most landward point given by either dune.finalPointX or dune.finalPointZ 
                    if isfield(dune,'finalPointX')     
                        [~,posDuneFinal] = min(abs(opt.bathyData.X-dune.finalPointX));
                        dune.finalPointZ = opt.bathyData.Z(posDuneFinal);

                    elseif isfield(dune,'finalPointZ')
                        [~,posDuneFinal] = min(abs(opt.bathyData.Z -dune.finalPointZ));
                        dune.finalPointX = opt.bathyData.X(posDuneFinal);
                    else
                        error('The dune most landward point must be given either by finalPointX or finalPointZ')
                    end
                end

                dune.xShoreSlope = dune.finalPointX - dune.duneHeight*dune.shorewardSlope;                                                % X coordinate of the shoreward dune crest point
                dune.zShoreSlope = dune.finalPointZ + dune.duneHeight;                                                                    % Z coordinate of the shoreward dune crest point 

                dune.xSeaSlope = dune.finalPointX - dune.duneHeight*dune.shorewardSlope-dune.duneWidth;                                  % X coordinate of the seaward dune crest point
                dune.zSeaSlope = dune.finalPointZ + dune.duneHeight;                                                                      % Z coordinate of the seaward dune crest point

                % Seaward slope until it intersects the original profile

                [~,i] = min(abs(opt.bathyData.X - dune.xSeaSlope));

                zIter = dune.zSeaSlope;
                while opt.bathyData.Z(i) < zIter
                     zIter = zIter - (opt.bathyData.X(i)-opt.bathyData.X(i-1))/dune.seawardSlope;
                     i = i-1;
                end

                dune.xDuneToe = opt.bathyData.X(i);                                                                                    % X coordinate of the dune toe (intersection with original profile)
                dune.zDuneToe = opt.bathyData.Z(opt.bathyData.X == dune.xDuneToe);                                                       % Z coordinate of the dune toe (intersection with original profile)  


                % Add the dune to the z profile

                maskDune = opt.bathyData.X >= dune.xDuneToe & opt.bathyData.X <= dune.finalPointX;

                
                if dune.xShoreSlope == dune.xSeaSlope 
                    opt.bathyData.Z(maskDune) = interp1([dune.xDuneToe, dune.xSeaSlope, dune.finalPointX],[dune.zDuneToe, dune.zSeaSlope, ...
                    dune.finalPointZ],opt.bathyData.X(maskDune));
                else
                    opt.bathyData.Z(maskDune) = interp1([dune.xDuneToe, dune.xSeaSlope, dune.xShoreSlope, dune.finalPointX],[dune.zDuneToe, dune.zSeaSlope, ...
                        dune.zShoreSlope, dune.finalPointZ],opt.bathyData.X(maskDune));
                end
                
                % Adjust non erodible layer

                opt.bathyData.ne(maskDune) = opt.bathyData.ne(maskDune) + (opt.bathyData.Z(maskDune) - opt.bathyData.zLat(maskDune));

                
                % Adjust maskDune given 0 where zInit > Z
                
                                
                if length(find(opt.bathyData.Z(maskDune) < opt.bathyData.zInit(maskDune))) > 0
                    maskDune(opt.bathyData.Z < opt.bathyData.zInit) = 0;
                end
                
                % Calculate dune area

                
                dune.duneArea = trapz(opt.bathyData.X(maskDune), opt.bathyData.Z(maskDune))-...                                         % Dune Area
                            trapz(opt.bathyData.X(maskDune), opt.bathyData.zLat(maskDune));

                % Calculate dune patches
                
                
                opt.patches.duneX = [opt.bathyData.X(maskDune); flipud(opt.bathyData.X(maskDune))];                                     % Calculate Patches
                opt.patches.duneZ = [opt.bathyData.Z(maskDune); flipud(opt.bathyData.zLat(maskDune))];

                if length(find(isnan(opt.patches.duneZ)))>0
                    opt.patches.duneX = opt.patches.duneX(~isnan(opt.patches.duneZ));
                    opt.patches.duneZ = opt.patches.duneZ(~isnan(opt.patches.duneZ));
                end
                dune.AreaPatch = polyarea(opt.patches.duneX ,opt.patches.duneZ);

                if abs(dune.duneArea - dune.AreaPatch) > 0.5
                    error('The two dune calculated areas do not match')
                end

                dune = rmfield(dune, 'AreaPatch');

                dune.totalWidth = dune.finalPointX - dune.xDuneToe;                                                                     % Total dune width 

                if dune.finalPointZ > dune.zDuneToe                                                                                     % Maximum dune heigth
                    dune.maxHeigth = dune.zSeaSlope - dune.zDuneToe;
                else
                    dune.maxHeigth = dune.zSeaSlope - dune.finalPointZ;
                end

                % Control Plot - Dune


                UtilPlot.reportFigureTemplate(15,5);
                hold on; box on;
                plot(opt.bathyData.X, opt.bathyData.zInit,'-','LineWidth',3,'displayname',labInput.InitialProfDisplay{opt.language})
                plot([dune.xShoreSlope,dune.finalPointX],[dune.zShoreSlope,dune.finalPointZ],'-','LineWidth',3,'displayname',labInput.ShorewSlopeDisplay{opt.language})
                plot([dune.xSeaSlope,dune.xShoreSlope],[dune.zSeaSlope,dune.zShoreSlope],'-','LineWidth',3,'displayname',labInput.CrestDisplay{opt.language})
                plot([dune.xDuneToe,dune.xSeaSlope], [dune.zDuneToe,dune.zSeaSlope],'-','LineWidth',3,'displayname',labInput.SeawSlopeDisplay{opt.language})
                plot(opt.bathyData.X, opt.bathyData.Z,'--','LineWidth',3,'displayname',labInput.FinalProfDisplay{opt.language})
                patch(opt.patches.duneX, opt.patches.duneZ, [212/255,197/255,173/255] , 'EdgeColor', [212/255,197/255,173/255],'displayname', labInput.DuneDisplay{opt.language})
                lgd = legend;
                set(lgd,'location','northwest') 
                xlabel('x [m]')
                ylabel('z [m TAW]')
     
        end
        
        function [opt,stormWall] = stormWallPreproc(opt,stormWall,labInput,dike)
            
            % Function to place a storm wall on top of the given cross-shore profile
            % HCA - 05/19
            %
            % INPUT: 
            % Location of the dike crest:
            % dike.xDikeCrest, dike.zDikeCrest: If a new (dike) has been already set on the profile
            % opt.xDikeCrest, opt.zDikeCrest: If the original profile dike is used
            % opt.bathyData: Current profile (opt.bathyData.X and opt.bathyData.Z) and latest modified profile (opt.bathyData.zLat) data
            % labInput: labels for plot
            %
            % OUTPUT:
            %
            % stormWall.wallToeX, stormWall.wallToeZ: wall toe, most seaward storm wall point
            % stormWall.seawardX, stormWall.seawardZ: storm wall seaward crest point
            % stormWall.shorewardX, stormWall.shorewardZ: storm wall shoreward crest point
            % stormWall.finalPointX, stormWall.finalPointX: most landward storm wall point
            % stormWall.Area: storm wall area
            % opt.patches.stormWallX, opt.patches.stormWallZ: patches for storm wall visualization
            % opt.bathyData.Z: Modify bed elevation including the dune
            
            if exist('dike','var')                                 % If there was a dike modification already take new dike crest as reference
                refxDikeCrest = dike.xDikeCrest;
                refzDikeCrest = dike.zDikeCrest;
            elseif opt.dikeLog == 1
                refxDikeCrest = opt.xDikeCrest;              % If not, take the original dike
                refzDikeCrest = opt.zDikeCrest;
            else
                error('There needs to be a dike to place the storm wall on top')              
            end
                
            if stormWall.initPoint == 1                      % Define the storm wall starting from the dike crest (With a bit of an offset for a smooth interpolation in XBeach)
                  
                [~,posSea] = min(abs(opt.bathyData.X - (refxDikeCrest)));
                [~,posShore] = min(abs(opt.bathyData.X - (opt.bathyData.X(posSea) + stormWall.width)));
                
            elseif stormWall.initPoint == 2                  % Define the storm wall in the middle of the dike promenade
                
                halfDist = (opt.bathyData.X(end) - refxDikeCrest)/2;
                
                [~,posSea] = min(abs(opt.bathyData.X - (refxDikeCrest + halfDist - stormWall.width/2)));
                [~,posShore] = min(abs(opt.bathyData.X - (refxDikeCrest + halfDist + stormWall.width/2)));

            elseif stormWall.initPoint == 3                  % Define the storm wall at the end of the dike promenade (With a bit of an offset for a smooth interpolation in XBeach)
                
                [~,posShore] = min(abs(opt.bathyData.X - (opt.bathyData.X(end)-4)));
                [~,posSea] = min(abs(opt.bathyData.X - (opt.bathyData.X(posShore) - stormWall.width)));

            else
                error('initPoint must be 1, 2 or 3')
            end
            
            
            % Wall toe point
            stormWall.wallToeX = opt.bathyData.X(posSea-1);
            stormWall.wallToeZ = opt.bathyData.Z(posSea-1);
            
            % Seaward crest wall point
            stormWall.seawardX = opt.bathyData.X(posSea);
            stormWall.seawardZ = opt.bathyData.Z(posSea) + stormWall.height;
            
            % Shoreward crest wall point
            stormWall.shorewardX = opt.bathyData.X(posShore);
            stormWall.shorewardZ = opt.bathyData.Z(posSea) + stormWall.height;
            
            % final wall point
            stormWall.finalPointX = opt.bathyData.X(posShore+1);
            stormWall.finalPointZ = opt.bathyData.Z(posShore+1);
            
            % Check on the wall width
            if (stormWall.shorewardX - stormWall.seawardX) ~= stormWall.width
                    error('The storm wall width does not match')
            end
            
            maskStormWall = [posSea-1, posSea:posShore, posShore+1];
            
            
            
            opt.bathyData.Z(maskStormWall) = interp1([stormWall.wallToeX ,stormWall.seawardX, stormWall.shorewardX,stormWall.finalPointX]...
                ,[stormWall.wallToeZ,stormWall.seawardZ, stormWall.shorewardZ,stormWall.finalPointZ]...
                , opt.bathyData.X(maskStormWall));
            
            stormWall.Area = trapz(opt.bathyData.X ,opt.bathyData.Z) -  trapz(opt.bathyData.X,opt.bathyData.zLat);
            
            opt.patches.stormWallX = [opt.bathyData.X(maskStormWall),flipud(opt.bathyData.X(maskStormWall))];
            opt.patches.stormWallZ = [opt.bathyData.Z(maskStormWall),flipud(opt.bathyData.zLat(maskStormWall))];
            
                        
            stormWall.AreaPatch = polyarea(opt.patches.stormWallX ,opt.patches.stormWallZ);
            
           if abs(stormWall.Area - stormWall.AreaPatch ) > 0.5
               error('The two storm wall calculated areas do not match')
           end
           
           stormWall = rmfield(stormWall, 'AreaPatch');
           
           % Control Plot - Storm wall

           UtilPlot.reportFigureTemplate(15,5);
           hold on; box on; grid on
           plot(opt.bathyData.X, opt.bathyData.zInit,'-','LineWidth',3,'displayname',labInput.InitialProfDisplay{opt.language})
           plot([stormWall.shorewardX,stormWall.finalPointX],[stormWall.shorewardZ, stormWall.finalPointZ],'-','LineWidth',3,'displayname',labInput.ShorewSlopeDisplay{opt.language})
           plot([stormWall.seawardX,stormWall.shorewardX],[stormWall.seawardZ,stormWall.shorewardZ],'-','LineWidth',3,'displayname',labInput.CrestDisplay{opt.language})
           plot([stormWall.wallToeX,stormWall.seawardX], [stormWall.wallToeZ,stormWall.seawardZ],'-','LineWidth',3,'displayname',labInput.SeawSlopeDisplay{opt.language})
           plot(opt.bathyData.X, opt.bathyData.Z,'--','LineWidth',3,'displayname',labInput.FinalProfDisplay{opt.language})
           patch(opt.patches.stormWallX, opt.patches.stormWallZ, [5/255,5/255,5/255] , 'EdgeColor', [5/255,5/255,5/255],'displayname', labInput.StormWallDisplay{opt.language})
           lgd = legend;
           set(lgd,'location','northwest') 
           xlabel('x [m]')
           ylabel('z [m TAW]')
            
        end
        
        
        function [opt,nourish] = nourishPreproc(opt,nourish,labInput)
        
            % Function to place a nourishment on top of the given cross-shore profile. There are four nourishment options:
            
                    %   1. Nourishment using linear interpolation
                    %   2. Horizonal beach shift
                    %   3. Vertical beach shift
                    %   4. Berm-like nourishment
                    
            % HCA - 05/19
            %
            % GENERAL INPUT: 
            %
            % nourish.finalPointZ, nourish.finalPointX: the most landward nourishment point needs to be defined by either of these two variables
            % nourish.initialPointZ, nourish.initialPointX: most seaward nourishment point
            % nourish.nourishWidth. If the initial point is not given, it can also be calculated nourish.nourishWidth m seaward from nourish.finalPointZ
            %
            % Note: the initial and final point represent the points to between which interpolation is performed in nourishment type 1.
            %       In the case of vertical and horizontal shift (nourishment type 2 and 3), they define the initial and final point of the ORIGINAL beach to be shifted. The final
            %       nourishment extension will be wider as the modified profile should be linked with the original profile (nourish.seawardSlope)
            %
            % opt.bathyData: Current profile (opt.bathyData.X and opt.bathyData.Z) and latest modified profile (opt.bathyData.zLat) data
            % labInput: labels for plot
            %
            % NOURISHMENT TYPE-SPECIFIC INPUT: 
            %
            % 2. HORIZONTAL BEACH SHIFT
            % nourish.horizShiftDist: Distance for the profile to be shifted seaward
            % nourish.seawardSlope: seaward slope to link the shifted profile with the original profile (default:1.30) 
            % nourish. 
            %
            % 3. VERTICAL BEACH SHIFT
            % nourish.vertShiftDist: Distance for the profile to be shifted upward
            % nourish.seawardSlope: seaward slope to link the shifted profile with the original profile (default:1.30) 
            %
            % 4. BERM - LIKE NOURISHMENT
            % nourish.bermWidth: berm-like nourishment crest width
            % nourish.seawardSlope : berm-like nourishment seaward Slope
            %
            % 5. DEFINED BY POINTS
            % nourish.selectedPointsX: selected points X
            % nourish.selectedPointsZ : selected points Z
            %
            % OUTPUT:
            %
            % opt.patches.nourishX, opt.patches.nourishZ: patches for nourishment visualization
            % opt.bathyData.Z: Modify bed elevation including the dune
            % nourish.Area: Area of the added nourishment
            % nourish.xIntersec, nourish.zIntersec: Seaward point of intersection between the original script and the modified one
            
            nourish = Util.setDefault(nourish,'seawardSlope',30);
            
            % Define nourishment final point

            if abs(nourish.finalPointX) >= 0
                [ ~ ,posFinalPoint] = min(abs(opt.bathyData.X - nourish.finalPointX));
                nourish.finalPointZ = opt.bathyData.Z(posFinalPoint);
            else abs(nourish.finalPointZ) >= 0
                [ ~ ,posFinalPoint] = min(abs(opt.bathyData.Z - nourish.finalPointZ));
                nourish.finalPointX = opt.bathyData.X(posFinalPoint);
            end

            
           
            % Define initial point
            
             if abs(nourish.initialPointZ) >= 0                                                     % If already given by initialPointZ
                   
                    [ ~ ,posInitialPoint] = min(abs(opt.bathyData.Z - nourish.initialPointZ));
                    nourish.initialPointX = opt.bathyData.X(posInitialPoint);
                    
             elseif abs(nourish.initialPointX) >= 0                                                 % If given by initialPointX
                    
                    [ ~ ,posInitialPoint] = min(abs(opt.bathyData.X - nourish.initialPointX));
                    nourish.initialPointZ = opt.bathyData.Z(posInitialPoint);
                    
             elseif nourish.nourishWidth > 0
                   
                    [ ~ ,posInitialPoint] = min(abs(opt.bathyData.X - (nourish.finalPointX - nourish.nourishWidth)));   
                    nourish.initialPointX =  opt.bathyData.X(posInitialPoint);
                    nourish.initialPointZ =  opt.bathyData.Z(posInitialPoint);
             end
            
  
             
             % Modify profile for each nourishment
             
             % 1. Nourishment using linear interpolation
             if length(opt.nourishmentType) == 1
                 if opt.nourishmentType == 1

                     maskNourish = [posInitialPoint:posFinalPoint];
                     xIterpVect = [opt.bathyData.X(posInitialPoint), opt.bathyData.X(posFinalPoint)];
                     zIterpVect = [opt.bathyData.Z(posInitialPoint), opt.bathyData.Z(posFinalPoint)];

                 % 2. Horizonal beach shift

                 elseif opt.nourishmentType == 2 

                     % Seaward slope until it intersects the original profile

                     [ ~ ,posNewInit] = min(abs(opt.bathyData.X - (nourish.initialPointX - nourish.horizShiftDist)));   

                     pointsShift = posInitialPoint - posNewInit;

                     intersec = posNewInit;
                     zIter = nourish.initialPointZ;

                     while opt.bathyData.Z(intersec) < zIter
                          if intersec > 2
                             zIter = zIter - (opt.bathyData.X(intersec)-opt.bathyData.X(intersec-1))/nourish.seawardSlope;
                             intersec = intersec-1;
                          else
                              break
                          end
                     end

                     nourish.xIntersec = opt.bathyData.X(intersec-1);                                                                                    % X coordinate of the nourishment toe (intersection with original profile)
                     nourish.zIntersec = opt.bathyData.Z(intersec-1);            

                     maskNourish = [intersec:posFinalPoint];
                     xIterpVect = [nourish.xIntersec; opt.bathyData.X((posInitialPoint:posFinalPoint) - pointsShift); nourish.finalPointX];
                     zIterpVect = [nourish.zIntersec; opt.bathyData.Z(posInitialPoint:posFinalPoint); nourish.finalPointZ];

                 % 3. Vertical beach shift    

                 elseif opt.nourishmentType == 3

                      intersec = posInitialPoint;
                      zIter = opt.bathyData.Z(posInitialPoint) + nourish.vertShiftDist;

                      while opt.bathyData.Z(intersec) < zIter
                          if intersec > 2
                             zIter = zIter - (opt.bathyData.X(intersec)-opt.bathyData.X(intersec-1))/nourish.seawardSlope;
                             intersec = intersec-1;
                          else
                              break
                          end
                     end

                     [~ ,posNewFinalPoint] = min(abs(opt.bathyData.Z - (opt.bathyData.Z(posFinalPoint) + nourish.vertShiftDist)));

                     nourish.xIntersec = opt.bathyData.X(intersec-1);                                                                                    % X coordinate of the nourishment toe (intersection with original profile)
                     nourish.zIntersec = opt.bathyData.Z(intersec-1);       


                     if  posNewFinalPoint > posFinalPoint
                         xIterpVect = [nourish.xIntersec; opt.bathyData.X(posInitialPoint:posFinalPoint); opt.bathyData.X(posNewFinalPoint)];
                         zIterpVect = [nourish.zIntersec; opt.bathyData.Z(posInitialPoint:posFinalPoint) + nourish.vertShiftDist; opt.bathyData.Z(posNewFinalPoint)];
                         maskNourish = [intersec:posNewFinalPoint];
                     else
                         xIterpVect = [nourish.xIntersec; opt.bathyData.X(posInitialPoint:posFinalPoint)];
                         zIterpVect = [nourish.zIntersec; opt.bathyData.Z(posInitialPoint:posFinalPoint) + nourish.vertShiftDist];
                         maskNourish = [intersec:posFinalPoint];
                     end




                 % 4. Berm-Like nourish  

                 elseif opt.nourishmentType == 4

                     [ ~ ,posNewInit] = min(abs(opt.bathyData.X - (nourish.finalPointX - nourish.bermWidth)));   

                     pointsShift = posFinalPoint - posNewInit;

                     intersec = posNewInit;
                     zIter = nourish.finalPointZ;

                     while opt.bathyData.Z(intersec) < zIter
                          if intersec > 2
                             zIter = zIter - (opt.bathyData.X(intersec)-opt.bathyData.X(intersec-1))/nourish.seawardSlope;
                             intersec = intersec-1;
                          else
                              break
                          end
                     end

                     nourish.xIntersec = opt.bathyData.X(intersec-1);                                                                                    % X coordinate of the nourishment toe (intersection with original profile)
                     nourish.zIntersec = opt.bathyData.Z(intersec-1);   

                     maskNourish = [intersec:posFinalPoint];
                     xIterpVect = [nourish.xIntersec; opt.bathyData.X(posNewInit); nourish.finalPointX];
                     zIterpVect = [nourish.zIntersec; nourish.finalPointZ; nourish.finalPointZ];

                 % 5. Nourishment defined by points 

                 elseif opt.nourishmentType == 5

                     nourish.selectedPointsX = str2num(nourish.selectedPointsX);
                     nourish.selectedPointsZ = str2num(nourish.selectedPointsZ);

                     [~ ,posNewFinalPoint] = min(abs(nourish.selectedPointsX(end)-opt.bathyData.X));

    %                  if posNewFinalPoint ~= length(opt.bathyData.X)  %Commented on 29/04/20 due to missing patch (extra point was causing interpolation to go out of range in line 3437). If neccessary, it should be uncommented
    %                  
    %                     posNewFinalPoint = posNewFinalPoint +1;
    %                  end


                     [~ ,intersec] = min(abs(nourish.selectedPointsX(1)-opt.bathyData.X));
                     zIter = nourish.selectedPointsZ(1);

                     while opt.bathyData.Z(intersec) < zIter
                          if intersec > 2
                             zIter = zIter - (opt.bathyData.X(intersec)-opt.bathyData.X(intersec-1))/nourish.seawardSlope;
                             intersec = intersec-1;
                          else
                              break
                          end
                     end

                     nourish.xIntersec = opt.bathyData.X(intersec-1);                                                                                    % X coordinate of the nourishment toe (intersection with original profile)
                     nourish.zIntersec = opt.bathyData.Z(intersec-1); 

                     xIterpVect = [nourish.xIntersec; transpose(nourish.selectedPointsX)];
                     zIterpVect = [nourish.zIntersec; transpose(nourish.selectedPointsZ)];

                     maskNourish = [intersec:posNewFinalPoint];

                     if length(nourish.selectedPointsX)>1
                         nourish.selectedPointsX = strcat('[',num2str(nourish.selectedPointsX),']');    
                         nourish.selectedPointsZ = strcat('[',num2str(nourish.selectedPointsZ),']');    
                     end

                 else
                     error('The NourishmentType variable must be from 1 to 5')
                 end
             else 
                 
                 % 6. Combined case of horizontal and vertical nourishment
                 if ~isempty(find(opt.nourishmentType == 2)) & ~isempty(find(opt.nourishmentType == 3))
                 
                     [ ~ ,posNewInit] = min(abs(opt.bathyData.X - (nourish.initialPointX - nourish.horizShiftDist))); 

                     pointsShift = posInitialPoint - posNewInit;
                     
                     intersec = posNewInit;
                     zIter = nourish.initialPointZ + nourish.vertShiftDist;

                     while opt.bathyData.Z(intersec) < zIter
                          if intersec > 2
                             zIter = zIter - (opt.bathyData.X(intersec)-opt.bathyData.X(intersec-1))/nourish.seawardSlope;
                             intersec = intersec-1;
                          else
                              break
                          end
                     end
                     
                     nourish.xIntersec = opt.bathyData.X(intersec-1);                                                                                    % X coordinate of the nourishment toe (intersection with original profile)
                     nourish.zIntersec = opt.bathyData.Z(intersec-1);            

                     maskNourish = [intersec:posFinalPoint];
                     
                     xIterpVect = [nourish.xIntersec; opt.bathyData.X((posInitialPoint:posFinalPoint) - pointsShift); nourish.finalPointX];
                     zIterpVect = [nourish.zIntersec; opt.bathyData.Z(posInitialPoint:posFinalPoint) + nourish.vertShiftDist; nourish.finalPointZ+ nourish.vertShiftDist];

                 end
             end
             
            % Modify bathymetry
            
            opt.bathyData.Z(maskNourish) = interp1(xIterpVect, zIterpVect, opt.bathyData.X(maskNourish));
            
            % Adjust non erodible layer
            
            opt.bathyData.ne(maskNourish) = opt.bathyData.ne(maskNourish) + (opt.bathyData.Z(maskNourish) - opt.bathyData.zLat(maskNourish));
                    
            % Calculate Area
            nourish.Area = trapz(opt.bathyData.X ,opt.bathyData.Z) -  trapz(opt.bathyData.X,opt.bathyData.zLat);
            
            % Calcule Patches
            opt.patches.nourishX = [opt.bathyData.X(maskNourish);flipud(opt.bathyData.X(maskNourish))];
            opt.patches.nourishZ = [opt.bathyData.Z(maskNourish);flipud(opt.bathyData.zLat(maskNourish))];
            
            % Remove NaN value from patches if there are any
            
            if length(find(isnan(opt.patches.nourishZ)))>0
                opt.patches.nourishX = opt.patches.nourishX(~isnan(opt.patches.nourishZ));
                opt.patches.nourishZ = opt.patches.nourishZ(~isnan(opt.patches.nourishZ));
            end
            
            nourish.AreaPatch = polyarea(opt.patches.nourishX ,opt.patches.nourishZ);
            
           if abs(nourish.Area - nourish.AreaPatch) > 0.5
               error('The two nourishment calculated areas do not match')
           end
                      
%            nourish = rmfield(nourish, 'AreaPatch');
                      
           % Control Plot - Nourishment

           UtilPlot.reportFigureTemplate(15,5);
           hold on; box on; grid on
           plot(opt.bathyData.X, opt.bathyData.zInit,'-','LineWidth',3,'displayname',labInput.InitialProfDisplay{opt.language})
           set(gca,'ColorOrderIndex',5)
           plot(opt.bathyData.X, opt.bathyData.Z,'--','LineWidth',3,'displayname',labInput.FinalProfDisplay{opt.language})
           patch(opt.patches.nourishX, opt.patches.nourishZ, [194/255,134/255,110/255], 'EdgeColor', [194/255,134/255,110/255],'displayname', labInput.NourishmentDisplay{opt.language})
           lgd = legend;
           set(lgd,'location','northwest') 
           xlabel('x [m]')
           ylabel('z [m TAW]')
           
        end
        
        function [] = standardPostprocessXBeach(opt)
            
            % [] = CosaTool.standardPostprocessXBeach(sctInput)
            %
            % Make set of standard postprocessing figures of XBeach run for
            % the Coastal Safety layout
            %
            % Adapted from XBeach.standardPostprocess(sctInput)
            % HCA - 05/19
            %
            %
            % INPUT:
            % - opt: Structure with the following fields:
            %   - XBeachRootRunFolder: Model run directory
            %   - outputFolder: Output folder where standard figures are saved
            %
            % OUTPUT:
            %
            % 
            
            if ~exist(opt.outputFolder,'dir')
                mkdir(opt.outputFolder);
            end
            
            opt.vars = {'zs_mean','H','H_mean','thetamean','sedero','zb','zb0'};
            
            ds = XBeach.readData(opt.XBeachRootRunFolder,opt);
            dsi = XBeach.loadInitBathy(opt);
            
            
       
            
            [m,n] = size(ds.X.data);
            % Plot some timeseries
            UtilPlot.reportFigureTemplate(15,9);
            it = round(m/2);
            jt = 10;
            
            tsVars = {'WatLevMean','WaveHeightRMSMean','WaveDir'};
            nVars = numel(tsVars);
            
            for ia = 1:nVars
                ax(ia) = subaxis(nVars,1,ia,'mb',0.12,'mr',0.08,'ml',0.12);
                if strcmp(tsVars{ia},'WaveDir')
                    plot(ds.GlobalTime.data/3600,ds.(tsVars{ia}).data(:,it,jt));
                else
                    plot(ds.Time.data/3600,ds.(tsVars{ia}).data(:,it,jt));
                end
                ylabel({tsVars{ia};sprintf('[%s]',ds.(tsVars{ia}).unit)});
                
                grid on;
                box on;
                
                if ia == nVars
                    xlabel('Time [hours]');
                else
                    set(gca,'xticklabel',[]);
                end
                
            end
            figFilename = 'Timeseries offshore';
            print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220');
            savefig([fullfile(opt.outputFolder,figFilename)]);
            
            
            % Plot some profiles
            if m>1
                opt = Util.setDefault(opt,'iprof',repmat(round(m*[1/3 1/2 2/3])',1,2)); %Default locations for
                opt = Util.setDefault(opt,'jprof',repmat([1 n],3,1)); %Default locations for
            else
                opt = Util.setDefault(opt,'iprof',[1 1]);
                opt = Util.setDefault(opt,'jprof',[1 n]);
            end
            opt.writeTextOutput = false;
            opt.interp = false;
            for i = 1:size(opt.iprof,1);
                opt.profileName{i} = ['Dummy profile ',num2str(i,'%02.0f')];
            end
            
            CosaTool.extractProfiles(opt);
            
            % Now do some mapplots
            %First, at peak time of mean variables
            nT = size(ds.MeanTime.data,1);
            mpOpt.variables = {'WaveHeightRMSMean','WatLevMean'};
            mpOpt.timeInd = round(nT/2);
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
            %First, at peak time of global variables
            nT = size(ds.GlobalTime.data,1);
            mpOpt.variables = {'WaveDir'};
            mpOpt.timeInd = round(nT/2);
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
            
            %Then, at end time
            nT = size(ds.GlobalTime.data,1);
            if ~isfield(ds,'Sedero')
                ds.Sedero.data = ds.BotDep.data - ds.BotDep.data(1,:,:);
                ds.Sedero.unit = ds.BotDep.unit;
            end
            mpOpt.variables = {'Sedero'};
            mpOpt.timeInd = nT;
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
        end
        
         function [] = XBeachstandardPostprocess(opt)
             
            % [] = XBeach.standardPostprocess(sctInput)
            %
            % Adapted for the Coastal Safety tool from XBeach.standardPostprocess (THL)
            % Make set of standard postprocessing figures of XBeach run
  
                        
            opt.vars = {'zs_mean','H','H_mean','thetamean','sedero','zb','zb0'};
            ds = XBeach.readData(opt.modelDir,opt);
            dsi = XBeach.loadInitBathy(opt);
            
            [m,n] = size(ds.X.data);
            
            % Plot some timeseries
            
            UtilPlot.reportFigureTemplate(15,9);
            it = round(m/2);
            jt = 10;
            
            tsVars = {'WatLevMean','WaveHeightRMSMean','WaveDir'};
            nVars = numel(tsVars);
            
            for ia = 1:nVars
                ax(ia) = subaxis(nVars,1,ia,'mb',0.12,'mr',0.08,'ml',0.12);
                if strcmp(tsVars{ia},'WaveDir')
                    plot(ds.GlobalTime.data/3600,ds.(tsVars{ia}).data(:,it,jt));
                else
                    plot(ds.Time.data/3600,ds.(tsVars{ia}).data(:,it,jt));
                end
                ylabel({tsVars{ia};sprintf('[%s]',ds.(tsVars{ia}).unit)});
                
                grid on;
                box on;
                
                if ia == nVars
                    xlabel('Time [hours]');
                else
                    set(gca,'xticklabel',[]);
                end
                
            end
            figFilename = 'Timeseries offshore';
            print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220');
            savefig([fullfile(opt.outputFolder,figFilename)]);
            
            
            % Plot the mid profile in the 2D domain or the one from the 1D domain
            
            if m>1
                opt = Util.setDefault(opt,'iprof',[round(m*1/2),round(m*1/2)]);     %Default locations in the longshore dir
                opt = Util.setDefault(opt,'jprof',[1 n]);                           %Default locations in the crosshore dir
            else
                opt = Util.setDefault(opt,'iprof',[1 1]);
                opt = Util.setDefault(opt,'jprof',[1 n]);
            end
            opt.writeTextOutput = false;
            opt.interp = false;
            opt.profileName = {'Mid profile'};
            CosaTool.extractProfiles(opt);
            
            % Now do some mapplots
            %First, at peak time of mean variables
            
            nT = size(ds.MeanTime.data,1);
            mpOpt.variables = {'WaveHeightRMSMean','WatLevMean'};
            mpOpt.timeInd = round(nT/2);
            mpOpt.outputFolder = opt.outputFolder;
            
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
            
            %First, at peak time of global variables
            nT = size(ds.GlobalTime.data,1);
            mpOpt.variables = {'WaveDir'};
            mpOpt.timeInd = round(nT/2);
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
            
            %Then, at end time
            nT = size(ds.GlobalTime.data,1);
            if ~isfield(ds,'Sedero')
                ds.Sedero.data = ds.BotDep.data - ds.BotDep.data(1,:,:);
                ds.Sedero.unit = ds.BotDep.unit;
            end
            mpOpt.variables = {'Sedero'};
            mpOpt.timeInd = nT;
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
         end
         
          function [watLines] = wetDryBeachVariations(watLines,opt)
             
             
            % [watLines] = CosaTool.wetDryBeachVariations(opt,watLines)
            %
            % Make set of standard postprocessing figures of XBeach run for
            % the Coastal Safety layout
            %
            % HCA - 08/19
            %
            %
            % INPUT:
            % - opt: Structure with the following fields:
            %   - slr: Sea level rise variation
            %   - bathyData: includes X, with the cross-shore values, and Z
            %   and zInit with the modified and initial Z values
            % - watLines:
            %   - HWOldZ: Original High water elevation
            %   - LWOldZ: Original Low water elevation
            %
            % OUTPUT:
            % - watLines:
            %   - HWNewZ: New High water elevation, after SLR
            %   - LWNewZ: New Low water elevation, after SLR
            %   - HWOldX: High water original cross-shore point 
            %   - LWOldX: Low water original cross-shore point
            %   - HWNewX: High water new cross-shore point 
            %   - LWNewX: Low water new cross-shore point
            %   - HWDif:  Cross-shore shift of high water line with SLR
            %   - LWDif:  Cross-shore shift of low water line with SLR
            %   - wetBeachWidth: width of the new wet beach (from HW to LW)
             

                watLines.HWNewZ = watLines.HWOldZ + opt.slr;
                watLines.LWNewZ  = watLines.LWOldZ + opt.slr;

                [~,iOldHW] = min(abs(opt.bathyData.zInit - watLines.HWOldZ));
                watLines.HWOldX = opt.bathyData.X(iOldHW);

                [~,iOldLW] = min(abs(opt.bathyData.zInit - watLines.LWOldZ));
                watLines.LWOldX =  opt.bathyData.X(iOldLW);

                [~,iNewHW] = min(abs(opt.bathyData.Z - watLines.HWNewZ));
                watLines.HWNewX = opt.bathyData.X(iNewHW);

                [~,iNewLW] = min(abs(opt.bathyData.Z - watLines.LWNewZ));
                watLines.LWNewX =  opt.bathyData.X(iNewLW);

                watLines.HWDif = watLines.HWOldX - watLines.HWNewX;
                watLines.LWDif = watLines.LWOldX - watLines.LWNewX;
                watLines.wetBeachWidthOld = watLines.HWOldX - watLines.LWOldX;
                watLines.wetBeachWidthNew = watLines.HWNewX - watLines.LWNewX;
                
                watLines.dryBeachWidthNew = opt.dryBeachFinalPointX - watLines.HWNewX;
                
                
         end
    end
end