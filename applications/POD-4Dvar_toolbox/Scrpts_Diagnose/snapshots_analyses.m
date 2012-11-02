function [prformnc] = snapshots_analyses(rbg,rpars)
% [prformnc] = snapshots_analyses(ROM.BG,Model.pars.Results)

  %if nargin ~= 2, error('MATLAB:snapshots_analyses:WrongNumberInputs','Wrong number of input arguments, must be 2.'); end
   
  disp(['Loading the Snapshots for Analyses.',char(10)])
  for iSnapshot=1:1:length(rpars)
    
    for iTstep = 1:1:length(rpars{iSnapshot}.info.dps)
      bgIndex = find([rbg.info.dps{:,1}]'== rpars{iSnapshot}.info.dps{iTstep,1});
      
      if ~isempty(bgIndex)
        if (rpars{iSnapshot}.info.dps{iTstep,1} - rbg.info.dps{bgIndex,1}), error('MATLAB:snapshots_analyses:AsynchronicComparison','Asynchronic comparison, times are different'); end
        
        prformnc(iSnapshot).diff{iTstep,1} = rpars{iSnapshot}.info.dps{iTstep,1};
        prformnc(iSnapshot).diff{iTstep,2} = rpars{iSnapshot}.info.dps{iTstep,2}-rbg.info.dps{bgIndex,2};

        prformnc(iSnapshot).L2norm{iTstep,1} = rpars{iSnapshot}.info.dps{iTstep,1};
        prformnc(iSnapshot).L2norm{iTstep,2} = norm(prformnc(iSnapshot).diff{iTstep,2},'fro');

        prformnc(iSnapshot).maxDiff{iTstep,1} = rpars{iSnapshot}.info.dps{iTstep,1};
        prformnc(iSnapshot).maxDiff{iTstep,2} = max(max(abs(prformnc(iSnapshot).diff{iTstep,2})));
        
        prformnc(iSnapshot).meanDiff{iTstep,1} = rpars{iSnapshot}.info.dps{iTstep,1};
        prformnc(iSnapshot).meanDiff{iTstep,2} = mean(mean(abs(prformnc(iSnapshot).diff{iTstep,2})));
        
      end
      
    end
    clear truth
    plotDataMD(:,iSnapshot) =   [prformnc(iSnapshot).maxDiff{:,2}]';
    plotDataL2(:,iSnapshot) =   [prformnc(iSnapshot).L2norm{:,2}]';
    plotDataMean(:,iSnapshot) = [prformnc(iSnapshot).meanDiff{:,2}]';
  end

  disp([char(10),' *** MAXIMUM DIFFERENCE OF EACH SNAPSHOT WITH RESPECT TO THE BACKGROUND ***'])
  subplot(3,1,1)
  plot(plotDataMD);
  disp(num2str(plotDataMD));
  title('Maximum Difference')
  
  disp([char(10),' *** L2 NORM OF THE DIFFERENCES BETWEEN THE SNAPSHOTS AND THE BACKGROUND ***'])
  subplot(3,1,2)
  plot(plotDataL2);
  disp(num2str(plotDataL2));
  title('L2norm of the Difference')
  
  disp([char(10),' *** MEAN OF THE DIFFERENCES BETWEEN THE SNAPSHOTS AND THE BACKGROUND ***'])
  subplot(3,1,3)
  plot(plotDataMean);
  disp(num2str(plotDataMean));
  title('Mean Difference')