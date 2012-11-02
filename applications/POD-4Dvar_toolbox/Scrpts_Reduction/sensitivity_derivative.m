function [varargout] = sensitivity_derivative(varargin)
% Central difference scheme - sensitivity_derivative(options,patterns,params,steps,numParam,mpars,sensindex,bgpath)
% Forward difference scheme - sensitivity_derivative(options,patterns,params,steps,numParam,mpars,sensindex,bgpath,runbg)
  
  whattodo = varargin{1};
  options = varargin{2};

  if strcmpi(options.sensitivities.type,'central')
        
        if strcmpi(whattodo,'run')
            if nargin ~= 5, error('MATLAB:runPrturbs:NotEnoughInputs','Wrong number of input arguments, must be 5.'); end
            if nargout ~= 0, error('MATLAB:OutputError','Wrong number of output arguments, "run" produces none.'); end
            params   = varargin{3};
            numParam = varargin{4};
            mbg      = varargin{5};
            epsilon  = options.sensitivities.perturbation;
            
            mpars = configureSnapshotRuns('sensitivity',mbg,[-1 1]*epsilon,numParam,params);
            centraldiff(numParam,mpars,mbg.mainpath,options);
            
            
            
        elseif strcmpi(whattodo,'load')
            if nargin ~= 8, error('MATLAB:runPrturbs:NotEnoughInputs','Wrong number of input arguments, must be 8.'); end
            if nargout == 0, error('MATLAB:OutputError','Wrong number of output arguments, "load" produces one.'); end
            params   = varargin{3};
            numParam = varargin{4};
            mbg      = varargin{5};
            steps    = varargin{6};
            patterns = varargin{7};
            spdomain = varargin{8};
            epsilon = options.sensitivities.perturbation;
            mpars = configureSnapshotRuns('sensitivity',mbg,[-1 1]*epsilon,numParam,params);
            varargout{1} = centraldiffload(patterns,params,steps,numParam,mpars,epsilon,mbg.mainpath,spdomain,options);
        end
        
        
        
  elseif strcmpi(options.sensitivities.type,'forward')
    
        if strcmpi(whattodo,'run')
            if nargin ~= 5, error('MATLAB:runPrturbs:NotEnoughInputs','Wrong number of input arguments, must be 5.'); end
            if nargout ~= 0, error('MATLAB:OutputError','Wrong number of output arguments, "run" produces none.'); end
            params   = varargin{3};
            numParam = varargin{4};
            mbg      = varargin{5};
            epsilon = options.sensitivities.perturbation;
            mpars = configureSnapshotRuns('sensitivity',mbg,epsilon,numParam,params);
            forwarddiff(numParam,mpars,mbg.mainpath,options);
            
            
        elseif strcmpi(whattodo,'load')
            if nargin ~= 8, error('MATLAB:runPrturbs:NotEnoughInputs','Wrong number of input arguments, must be 7.'); end
            if nargout == 0, error('MATLAB:OutputError','Wrong number of output arguments, "load" produces one.'); end
            params   = varargin{3};
            numParam = varargin{4};
            mbg      = varargin{5};
            steps    = varargin{6};
            patterns = varargin{7};
            runbg    = varargin{8};
            epsilon = options.sensitivities.perturbation;
            mpars = configureSnapshotRuns('sensitivity',mbg,epsilon,numParam,params);
            varargout{1} = forwarddiffload(patterns,params,steps,numParam,mpars,epsilon,mbg.mainpath,runbg,options);
        end
    end
end

%  ________________________________________________________________________
%% (1) CENTRAL DIFFERENCE SCHEME
function [PdN_dAlpha] = centraldiff(numParam,mpars,bgpath,options)

    if options.sensitivities.runflag
        disp([char(10),'Executing perturbed parameter runs for sensitivity analysis']);           % Parameters perturbed runs
        for iModel = options.sensitivities.param_start:1:numParam
            
            mpars(iModel,1).mdf.Tstop = 0;                                          %Stop time
            runprturbs('sensitivity',mpars(iModel,1), bgpath,options.sensitivities.step_start,options.numNodesInCluster);

            mpars(iModel,2).mdf.tfinal = 0;                                          %Stop time
            runprturbs('sensitivity',mpars(iModel,2), bgpath,options.sensitivities.step_start,options.numNodesInCluster);
        end
    end
    
end
function [PdN_dAlpha] = centraldiffload(patterns,params,steps,numParam,mpars,epsilon,bgpath,thedomain,options)

    if options.sensitivities.loadinfoflag
        
        d3dfinish('garcia_in',10)
        for iModel=1:1:numParam
            Perturb_back(iModel)  = getrunsinfo(mpars(iModel,1).mainpath,mpars(iModel).mdf.runID,options.getrunsinfo);            
            Perturb_ahead(iModel) = getrunsinfo(mpars(iModel,2).mainpath,mpars(iModel).mdf.runID,options.getrunsinfo);
        end

        save([bgpath(1:end-11),'sensitivity_back.mat'],'Perturb_back')
        save([bgpath(1:end-11),'sensitivity_ahead.mat'],'Perturb_ahead')
    else
        disp(['Loading: ',bgpath(1:end-11),'sensitivity_back']);    load([bgpath(1:end-11),'sensitivity_back']);
        disp(['Loading: ',bgpath(1:end-11),'sensitivity_ahead']);   load([bgpath(1:end-11),'sensitivity_ahead']);
    end

    % Central difference derivative estimation
    for jTStep = 1:1:steps
        
        PdN_dAlpha{jTStep} = nan(size(patterns,2),numParam);
        
        for iModel=1:1:numParam
            ladiff = (Perturb_ahead(iModel).vectors.dps(:,jTStep) - Perturb_back(iModel).vectors.dps(:,jTStep)).*thedomain;
            PdN_dAlpha{jTStep}(:,iModel) = patterns'*(ladiff./(2*epsilon*params(iModel).significant_figure));
        end
    end
end

%________________________________________________________________________
%% (2) FORWARD DIFFERENCE SCHEME
function [PdN_dAlpha] = forwarddiff(numParam,mpars,bgpath,options)

    if options.sensitivities.runflag
        disp([char(10),'Executing perturbed parameter runs for sensitivity analysis']);           % Parameters perturbed runs
        for iModel=options.sensitivities.param_start:1:numParam

            mpars(iModel).mdf.Tstop = 0;                                      % Stop time
            runprturbs('sensitivity',mpars(iModel),bgpath,options.sensitivities.step_start,options.numNodesInCluster);
        end
    end

end
function [PdN_dAlpha] = forwarddiffload(patterns,params,steps,numParam,mpars,epsilon,bgpath,runbg,options)
   
    if options.sensitivities.loadinfoflag
        
        d3dfinish('garcia_in',10)
        for iModel=1:1:numParam, 
            Perturb_ahead(iModel) = getrunsinfo([mpars(iModel).mainpath],mpars(iModel).mdf.runID,options.getrunsinfo); 
        end
        save([bgpath(1:end-11),'sensitivity_ahead.mat'],'Perturb_ahead')
    else
        disp(['Loading: ',bgpath(1:end-11),'sensitivity_ahead']); load([bgpath(1:end-11),'sensitivity_ahead']); 
    end
    
    % Forward difference derivative estimation
    for jTStep = 1:1:steps,
        PdN_dAlpha{jTStep} = nan(size(patterns,2),numParam);
        for iModel=1:1:numParam,
            ladiff = (Perturb_ahead(iModel).vectors.dps(:,jTStep) - runbg.vectors.dps(:,jTStep+1)).*runbg.vectors.morcells; 
            PdN_dAlpha{jTStep}(:,iModel) = patterns'*(ladiff./(epsilon*params(iModel).significant_figure)); 
        end
    end
end
