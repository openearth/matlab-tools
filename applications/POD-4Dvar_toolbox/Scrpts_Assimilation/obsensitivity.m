function [varargout] = obsensitivity(varargin)

    elrom          = varargin{1};
    theforecast    = varargin{2};
    theparameters  = varargin{3};
    obsCov = varargin{4};
    bg_covariance = varargin{5};
    
    
%    estimation.theoperator = varargin{6};    
    
    a = zeros(elrom.bg.n,elrom.bg.m);   a (60:80,15:25) = 1;
    estimation.theoperator = elrom.P'*(reshape(a,elrom.bg.n*elrom.bg.m,1));
    %estimation.thefulldomain = elrom.P'*ones(elrom.bg.n*elrom.bg.m,1);
    
    for iTStep = elrom.steps:-1:1
        estimation.drf_dDai{iTStep} = elrom.dN_dAlpha{iTStep};
        for jTStep = (iTStep+1):1:elrom.steps, estimation.drf_dDai{iTStep} = elrom.N{jTStep}*estimation.drf_dDai{iTStep}; end
    end

    for iTStep = elrom.steps:-1:1
        estimation.drf_dri{iTStep} = elrom.N{iTStep};
        for jTStep = iTStep+1:1:elrom.steps, estimation.drf_dri{iTStep} = elrom.N{jTStep}*estimation.drf_dri{iTStep}; end
    end

    for iTStep = elrom.steps:-1:1,            
%        obs_covariance = elrom.P'*sparse(1:eltamanio,1:eltamanio,1./obsCov(:,iTStep))*elrom.P;
        
        theweights.vectors.params(:,iTStep) = (estimation.drf_dDai{iTStep}'*estimation.theoperator);
        theweights.vectors.dps(:,iTStep) = elrom.P*(estimation.drf_dri{iTStep}'*estimation.theoperator);
        
        theweights.info.dps(iTStep,1) = {elrom.bg.info.dps{iTStep,1}};
        theweights.info.dps(iTStep,2) = {reshape(theweights.vectors.dps(:,iTStep),elrom.bg.n,elrom.bg.m)};
        theweights.info.dps(iTStep,3) = {norm(theweights.vectors.dps(:,iTStep))};
    end

    varargout{1} = estimation;
    varargout{2} = theweights;
    
    %lasvariabilities = elrom.P*theforecast(:,1)-elrom.P*theforecast(:,end);  
    %varindices = find(lasvariabilities == max(lasvariabilities));
    %estimation.theoperator = sparse([1:size(varindices,1)]',varindices,1,size(varindices,1),elrom.bg.n*elrom.bg.m)';
    %estimation.theoperator = (elrom.P'*estimation.theoperator);
