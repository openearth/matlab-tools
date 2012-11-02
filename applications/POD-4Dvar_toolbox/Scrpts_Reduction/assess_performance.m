function [prformnc] = assess_performance(varargin)
% [prformnc] = assess_performance(ROM,Model.pars)

  if nargin ~= 3, error('MATLAB:assess_performance:WrongNumberInputs','Wrong number of input arguments, must be 2.'); end
  
  rom = varargin{1};
  pars = varargin{2};
  getinfoptions = varargin{3};

  inputTrials = {pars(:).configP};
  
  disp(['Loading the Snapshots as Reference Cases.',char(10)])
  for iTrial=1:1:length(inputTrials)
    
    trial(iTrial) = runrom(rom,inputTrials{iTrial}');
    
    truth = getRunsInfo({pars(iTrial).mainpath},pars(iTrial).mdf.runID,getinfoptions.time,getinfoptions.depthreshold);
  
    for iTstep = 1:1:length(trial(iTrial).info.dps)
      truthIndex = find([truth.info.dps{:,1}]'== trial(iTrial).info.dps{iTstep,1});
      if (trial(iTrial).info.dps{iTstep,1}-truth.info.dps{truthIndex,1}),error('MATLAB:assess_performance:AsynchronicComparison','Asynchronic comparison, times are different');end
      
      prformnc(iTrial).diff{iTstep,1} = trial(iTrial).info.dps{iTstep,1};
      prformnc(iTrial).diff{iTstep,2} = trial(iTrial).info.dps{iTstep,2}-truth.info.dps{truthIndex,2};
      
      prformnc(iTrial).L2norm{iTstep,1} = trial(iTrial).info.dps{iTstep,1};
      prformnc(iTrial).L2norm{iTstep,2} = sum(sum(prformnc(iTrial).diff{iTstep,2}.^2));
      
      prformnc(iTrial).maxDiff{iTstep,1} = trial(iTrial).info.dps{iTstep,1};
      prformnc(iTrial).maxDiff{iTstep,2} = max(max(abs(prformnc(iTrial).diff{iTstep,2})));
      
    end
    prformnc(iTrial).reference = truth;
    
    clear truth
    plotDataMD(:,iTrial) = [prformnc(iTrial).maxDiff{:,2}]';
    plotDataL2(:,iTrial) = [prformnc(iTrial).L2norm{:,2}]';
  end

  disp([char(10),' *** MAXIMUM DIFFERENCE OF THE ROM WITH RESPECT TO THE REFERENCES ***'])
  disp(num2str(plotDataMD));
  
  disp([char(10),' *** L2 NORM OF THE DIFFERENCES BETWEEN THE ROM AND THE REFERENCES ***'])
  disp(num2str(plotDataL2));