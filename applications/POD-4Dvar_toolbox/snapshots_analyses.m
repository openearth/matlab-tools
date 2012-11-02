function [prformnc] = snapshots_analyses(varargin)
% [prformnc] = snapshots_analyses(ROM.BG,Model.pars.Results)

  %if nargin ~= 2, error('MATLAB:snapshots_analyses:WrongNumberInputs','Wrong number of input arguments, must be 2.'); end
  
  rbg = varargin{1};
  rpars = varargin{2};
 
  disp(['Initiating snapshots Analyses.',char(10)])
  cont = 1;
  for iTstep = 1:1:length(rbg.info.dps)
    parIndex = find([rpars.info.dps{:,1}]'== rbg.info.dps{iTstep,1}, 1, 'first' );

    if ~isempty(parIndex)
      if (rpars.info.dps{parIndex,1} - rbg.info.dps{iTstep,1}), error('MATLAB:snapshots_analyses:AsynchronicComparison','Asynchronic comparison, times are different'); end

      rbg.info.dps{iTstep,2}(rbg.info.dps{iTstep,2}<0) = 0;
      rpars.info.dps{parIndex,2}(rpars.info.dps{parIndex,2}<0) = 0;

      prformnc.diff{cont,1} = rbg.info.dps{iTstep,1};
      prformnc.diff{cont,2} = rbg.info.Uvel{iTstep,2} - rpars.info.Uvel{parIndex,2};
      prformnc.diff{cont,3} = rbg.info.Vvel{iTstep,2} - rpars.info.Vvel{parIndex,2};
      prformnc.diff{cont,4} = rbg.info.dps{iTstep,2} - rpars.info.dps{parIndex,2}; %rbg.info.dps{iTstep,2}(2:end-1,2:end-1) - rpars.info.dps{parIndex,2}(2:end-1,2:end-1);
      prformnc.diff{cont,5} = rbg.info.dps{iTstep,2};%(2:end-1,2:end-1);
      prformnc.diff{cont,6} = rpars.info.dps{parIndex,2};%(2:end-1,2:end-1);

      prformnc.L2norm{cont,1} = prformnc.diff{cont,1};
      prformnc.L2norm{cont,2} = norm(prformnc.diff{cont,2},'fro');
      prformnc.L2norm{cont,3} = norm(prformnc.diff{cont,3},'fro');
      prformnc.L2norm{cont,4} = norm(prformnc.diff{cont,4},'fro');

      prformnc.maxDiff{cont,1} = prformnc.diff{cont,1};
      prformnc.maxDiff{cont,2} = max(max(abs(prformnc.diff{cont,2})));
      prformnc.maxDiff{cont,3} = max(max(abs(prformnc.diff{cont,3})));
      prformnc.maxDiff{cont,4} = max(max(abs(prformnc.diff{cont,4})));

      prformnc.meanDiff{cont,1} = prformnc.diff{cont,1};
      warning off
      prformnc.meanDiff{cont,2} = mean(mean(abs(prformnc.diff{cont,2}(prformnc.diff{cont,2}~=0))));
      prformnc.meanDiff{cont,3} = mean(mean(abs(prformnc.diff{cont,3}(prformnc.diff{cont,3}~=0))));
      prformnc.meanDiff{cont,4} = mean(mean(abs(prformnc.diff{cont,4}(prformnc.diff{cont,4}~=0))));  
      warning on
      cont=cont+1;
    end
    clear truth
  end