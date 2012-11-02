function [x, fval, Var4D] = optProcedure(options,rom, obs)  

    
    % TRANSFORMATION
    for iparam=1:1:rom.numParam
        a(iparam,1) = rom.Params(iparam).minValue-rom.Params(iparam).bgValue;
    	c(iparam,1) = rom.Params(iparam).maxValue-rom.Params(iparam).bgValue;
    end
    
    x = interval2real(zeros(rom.numParam,1),a,c);
    
    
    Var4D.dJ_dDa = [];
    Var4D.J = [];
    
    disp ('INITIALIZING ASSIMILATION PROCEDURES')
    % varIn is element of R^numparams
    tic	
         [x,fval] = fminlbfgs(@optJfunc,x,options);          
         x = real2interval(x',a,c);
    toc
    if isempty(fval), fval = NaN; end


    for iparam=1:1:rom.numParam
       if rom.Params(iparam).enforce_sigFig_in_value,  
           x(iparam) = roundto(x(iparam),ceil(abs(log10(rom.Params(iparam).significant_figure)))); 
       end
    end
    Var4D.romRun = runrom(rom,x);
    
    
    
% _________________________________________________________________________
%%  Objective function
    function [varargout]=optJfunc(varIn)
    % -inf < varIn < inf
    


    % TRANSFORMATION
    % theta = a + (c - a)*exp(-exp(x))
    % a < theta < c
    % -inf < x < inf
        
        [stateVector,transformation_derivative] = real2interval(varIn',a,c);
       
       
        Var4D.romRun = runrom(rom,stateVector);

        [Var4D.J(length(Var4D.J)+1), Var4D.dJ_dDa(:,size(Var4D.dJ_dDa,2)+1)] = ...
            evalcost_trans(options,Var4D.romRun,obs, ...
                           rom.initialGuess.matCov,  ...
                           rom.initialGuess.cumMovement+stateVector, ....
                           rom.P, ...
                           rom.dr_dDa, ...
                           transformation_derivative);

        varargout{1} = Var4D.J(length(Var4D.J));
        varargout{2} = Var4D.dJ_dDa(:,size(Var4D.dJ_dDa,2));
    end
    
    
    
end