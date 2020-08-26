

classdef Dremo < handle
    % Dremo (Dumpsite Response Model)
    %
    % @author THL
    % @version 0.1, 09/09/2014
    %
    
    % Public properties
    properties
        Property1;
    end
    
    %Dependent properties
    properties(Dependent = true, SetAccess = private)
        
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
    
    %Static Private methods
    methods (Static,Access = 'private')
        function [x,fval,exitflag,output] = fminsearch2(funfcn,x,options,varargin)
            %FMINSEARCH Multidimensional unconstrained nonlinear minimization (Nelder-Mead).
            %   X = FMINSEARCH(FUN,X0) starts at X0 and attempts to find a local minimizer
            %   X of the function FUN.  FUN is a function handle.  FUN accepts input X and
            %   returns a scalar function value F evaluated at X. X0 can be a scalar, vector
            %   or matrix.
            %
            %   X = FMINSEARCH(FUN,X0,OPTIONS)  minimizes with the default optimization
            %   parameters replaced by values in the structure OPTIONS, created
            %   with the OPTIMSET function.  See OPTIMSET for details.  FMINSEARCH uses
            %   these options: Display, TolX, TolFun, MaxFunEvals, MaxIter, FunValCheck,
            %   PlotFcns, and OutputFcn.
            %
            %   X = FMINSEARCH(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a
            %   structure with the function FUN in PROBLEM.objective, the start point
            %   in PROBLEM.x0, the options structure in PROBLEM.options, and solver
            %   name 'fminsearch' in PROBLEM.solver. The PROBLEM structure must have
            %   all the fields.
            %
            %   [X,FVAL]= FMINSEARCH(...) returns the value of the objective function,
            %   described in FUN, at X.
            %
            %   [X,FVAL,EXITFLAG] = FMINSEARCH(...) returns an EXITFLAG that describes
            %   the exit condition of FMINSEARCH. Possible values of EXITFLAG and the
            %   corresponding exit conditions are
            %
            %    1  Maximum coordinate difference between current best point and other
            %       points in simplex is less than or equal to TolX, and corresponding
            %       difference in function values is less than or equal to TolFun.
            %    0  Maximum number of function evaluations or iterations reached.
            %   -1  Algorithm terminated by the output function.
            %
            %   [X,FVAL,EXITFLAG,OUTPUT] = FMINSEARCH(...) returns a structure
            %   OUTPUT with the number of iterations taken in OUTPUT.iterations, the
            %   number of function evaluations in OUTPUT.funcCount, the algorithm name
            %   in OUTPUT.algorithm, and the exit message in OUTPUT.message.
            %
            %   Examples
            %     FUN can be specified using @:
            %        X = fminsearch(@sin,3)
            %     finds a minimum of the SIN function near 3.
            %     In this case, SIN is a function that returns a scalar function value
            %     SIN evaluated at X.
            %
            %     FUN can be an anonymous function:
            %        X = fminsearch(@(x) norm(x),[1;2;3])
            %     returns a point near the minimizer [0;0;0].
            %
            %     FUN can be a parameterized function. Use an anonymous function to
            %     capture the problem-dependent parameters:
            %        f = @(x,c) x(1).^2+c.*x(2).^2;  % The parameterized function.
            %        c = 1.5;                        % The parameter.
            %        X = fminsearch(@(x) f(x,c),[0.3;1])
            %
            %   FMINSEARCH uses the Nelder-Mead simplex (direct search) method.
            %
            %   See also OPTIMSET, FMINBND, FUNCTION_HANDLE.
            
            %   Reference: Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright,
            %   Paul E. Wright, "Convergence Properties of the Nelder-Mead Simplex
            %   Method in Low Dimensions", SIAM Journal of Optimization, 9(1):
            %   p.112-147, 1998.
            
            %   Copyright 1984-2012 The MathWorks, Inc.
            
            
            defaultopt = struct('Display','notify','MaxIter','200*numberOfVariables',...
                'MaxFunEvals','200*numberOfVariables','TolX',1e-4,'TolFun',1e-4, ...
                'FunValCheck','off','OutputFcn',[],'PlotFcns',[]);
            
            % If just 'defaults' passed in, return the default options in X
            if nargin==1 && nargout <= 1 && isequal(funfcn,'defaults')
                x = defaultopt;
                return
            end
            
            if nargin<3, options = []; end
            
            % Detect problem structure input
            if nargin == 1
                if isa(funfcn,'struct')
                    [funfcn,x,options] = separateOptimStruct(funfcn);
                else % Single input and non-structure
                    error(message('MATLAB:fminsearch:InputArg'));
                end
            end
            
            if nargin == 0
                error(message('MATLAB:fminsearch:NotEnoughInputs'));
            end
            
            
            % Check for non-double inputs
            if ~isa(x,'double')
                error(message('MATLAB:fminsearch:NonDoubleInput'))
            end
            
            n = numel(x);
            numberOfVariables = n;
            
            printtype = optimget(options,'Display',defaultopt,'fast');
            tolx = optimget(options,'TolX',defaultopt,'fast');
            tolf = optimget(options,'TolFun',defaultopt,'fast');
            maxfun = optimget(options,'MaxFunEvals',defaultopt,'fast');
            maxiter = optimget(options,'MaxIter',defaultopt,'fast');
            funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
            
            % In case the defaults were gathered from calling: optimset('fminsearch'):
            if ischar(maxfun)
                if isequal(lower(maxfun),'200*numberofvariables')
                    maxfun = 200*numberOfVariables;
                else
                    error(message('MATLAB:fminsearch:OptMaxFunEvalsNotInteger'))
                end
            end
            if ischar(maxiter)
                if isequal(lower(maxiter),'200*numberofvariables')
                    maxiter = 200*numberOfVariables;
                else
                    error(message('MATLAB:fminsearch:OptMaxIterNotInteger'))
                end
            end
            
            switch printtype
                case {'notify','notify-detailed'}
                    prnt = 1;
                case {'none','off'}
                    prnt = 0;
                case {'iter','iter-detailed'}
                    prnt = 3;
                case {'final','final-detailed'}
                    prnt = 2;
                case 'simplex'
                    prnt = 4;
                otherwise
                    prnt = 1;
            end
            % Handle the output
            outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
            if isempty(outputfcn)
                haveoutputfcn = false;
            else
                haveoutputfcn = true;
                xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
                % Parse OutputFcn which is needed to support cell array syntax for OutputFcn.
                outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
            end
            
            % Handle the plot
            plotfcns = optimget(options,'PlotFcns',defaultopt,'fast');
            if isempty(plotfcns)
                haveplotfcn = false;
            else
                haveplotfcn = true;
                xOutputfcn = x; % Last x passed to plotfcns; has the input x's shape
                % Parse PlotFcns which is needed to support cell array syntax for PlotFcns.
                plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
            end
            
            header = ' Iteration   Func-count     min f(x)         Procedure';
            
            % Convert to function handle as needed.
            funfcn = fcnchk(funfcn,length(varargin));
            % Add a wrapper function to check for Inf/NaN/complex values
            if funValCheck
                % Add a wrapper function, CHECKFUN, to check for NaN/complex values without
                % having to change the calls that look like this:
                % f = funfcn(x,varargin{:});
                % x is the first argument to CHECKFUN, then the user's function,
                % then the elements of varargin. To accomplish this we need to add the
                % user's function to the beginning of varargin, and change funfcn to be
                % CHECKFUN.
                varargin = {funfcn, varargin{:}};
                funfcn = @checkfun;
            end
            
            n = numel(x);
            
            % Initialize parameters
            rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
            onesn = ones(1,n);
            two2np1 = 2:n+1;
            one2n = 1:n;
            
            % Set up a simplex near the initial guess.
            xin = x(:); % Force xin to be a column vector
            v = zeros(n,n+1); fv = zeros(1,n+1);
            v(:,1) = xin;    % Place input guess in the simplex! (credit L.Pfeffer at Stanford)
            x(:) = xin;    % Change x to the form expected by funfcn
            fv(:,1) = funfcn(x,varargin{:});
            func_evals = 1;
            itercount = 0;
            how = '';
            % Initial simplex setup continues later
            
            % Initialize the output and plot functions.
            if haveoutputfcn || haveplotfcn
                [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,v(:,1),xOutputfcn,'init',itercount, ...
                    func_evals, how, fv(:,1),varargin{:});
                if stop
                    [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
                    if  prnt > 0
                        disp(output.message)
                    end
                    return;
                end
            end
            
            % Print out initial f(x) as 0th iteration
            if prnt == 3
                disp(' ')
                disp(header)
                fprintf(' %5.0f        %5.0f     %12.6g         %s\n', itercount, func_evals, fv(1), how);
            elseif prnt == 4
                clc
                formatsave.format = get(0,'format');
                formatsave.formatspacing = get(0,'formatspacing');
                % reset format when done
                oc1 = onCleanup(@()set(0,'format',formatsave.format));
                oc2 = onCleanup(@()set(0,'formatspacing',formatsave.formatspacing));
                format compact
                format short e
                disp(' ')
                disp(how)
                v
                fv
                func_evals
            end
            % OutputFcn and PlotFcns call
            if haveoutputfcn || haveplotfcn
                [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,v(:,1),xOutputfcn,'iter',itercount, ...
                    func_evals, how, fv(:,1),varargin{:});
                if stop  % Stop per user request.
                    [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
                    if  prnt > 0
                        disp(output.message)
                    end
                    return;
                end
            end
            
            % Continue setting up the initial simplex.
            % Following improvement suggested by L.Pfeffer at Stanford
            usual_delta = 0.05;             % 5 percent deltas for non-zero terms
            zero_term_delta = 0.00025;      % Even smaller delta for zero elements of x
            for j = 1:n
                y = xin;
                if y(j) ~= 0
                    y(j) = (1 + usual_delta)*y(j);
                else
                    y(j) = zero_term_delta;
                end
                v(:,j+1) = y;
                x(:) = y; f = funfcn(x,varargin{:});
                fv(1,j+1) = f;
            end
            
            % sort so v(1,:) has the lowest function value
            [fv,j] = sort(fv);
            v = v(:,j);
            
            how = 'initial simplex';
            itercount = itercount + 1;
            func_evals = n+1;
            if prnt == 3
                fprintf(' %5.0f        %5.0f     %12.6g         %s\n', itercount, func_evals, fv(1), how)
            elseif prnt == 4
                disp(' ')
                disp(how)
                v
                fv
                func_evals
            end
            % OutputFcn and PlotFcns call
            if haveoutputfcn || haveplotfcn
                [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,v(:,1),xOutputfcn,'iter',itercount, ...
                    func_evals, how, fv(:,1),varargin{:});
                if stop  % Stop per user request.
                    [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
                    if  prnt > 0
                        disp(output.message)
                    end
                    return;
                end
            end
            exitflag = 1;
            
            % Main algorithm: iterate until
            % (a) the maximum coordinate difference between the current best point and the
            % other points in the simplex is less than or equal to TolX. Specifically,
            % until max(||v2-v1||,||v2-v1||,...,||v(n+1)-v1||) <= TolX,
            % where ||.|| is the infinity-norm, and v1 holds the
            % vertex with the current lowest value; AND
            % (b) the corresponding difference in function values is less than or equal
            % to TolFun. (Cannot use OR instead of AND.)
            % The iteration stops if the maximum number of iterations or function evaluations
            % are exceeded
            
            while func_evals < maxfun && itercount < maxiter
                % =====================================================================
                % EDITS IMDC
                % THL, MARCH 2015
                % =====================================================================
                % Make the stopping criterion depend on relative error instead of
                % absolute error (see fminsearch).
                if max(abs(fv(1)-fv(two2np1))./abs(fv(1))) <= max(tolf,10*eps(fv(1))) && ...
                        max(max(abs(v(:,two2np1)-v(:,onesn))./abs(v(:,onesn)))) <= max(tolx,10*eps(max(v(:,1))))
                    break
                end
                % =====================================================================
                % END EDITS IMDC
                % =====================================================================
                
                % Compute the reflection point
                
                % xbar = average of the n (NOT n+1) best points
                xbar = sum(v(:,one2n), 2)/n;
                xr = (1 + rho)*xbar - rho*v(:,end);
                x(:) = xr; fxr = funfcn(x,varargin{:});
                func_evals = func_evals+1;
                
                if fxr < fv(:,1)
                    % Calculate the expansion point
                    xe = (1 + rho*chi)*xbar - rho*chi*v(:,end);
                    x(:) = xe; fxe = funfcn(x,varargin{:});
                    func_evals = func_evals+1;
                    if fxe < fxr
                        v(:,end) = xe;
                        fv(:,end) = fxe;
                        how = 'expand';
                    else
                        v(:,end) = xr;
                        fv(:,end) = fxr;
                        how = 'reflect';
                    end
                else % fv(:,1) <= fxr
                    if fxr < fv(:,n)
                        v(:,end) = xr;
                        fv(:,end) = fxr;
                        how = 'reflect';
                    else % fxr >= fv(:,n)
                        % Perform contraction
                        if fxr < fv(:,end)
                            % Perform an outside contraction
                            xc = (1 + psi*rho)*xbar - psi*rho*v(:,end);
                            x(:) = xc; fxc = funfcn(x,varargin{:});
                            func_evals = func_evals+1;
                            
                            if fxc <= fxr
                                v(:,end) = xc;
                                fv(:,end) = fxc;
                                how = 'contract outside';
                            else
                                % perform a shrink
                                how = 'shrink';
                            end
                        else
                            % Perform an inside contraction
                            xcc = (1-psi)*xbar + psi*v(:,end);
                            x(:) = xcc; fxcc = funfcn(x,varargin{:});
                            func_evals = func_evals+1;
                            
                            if fxcc < fv(:,end)
                                v(:,end) = xcc;
                                fv(:,end) = fxcc;
                                how = 'contract inside';
                            else
                                % perform a shrink
                                how = 'shrink';
                            end
                        end
                        if strcmp(how,'shrink')
                            for j=two2np1
                                v(:,j)=v(:,1)+sigma*(v(:,j) - v(:,1));
                                x(:) = v(:,j); fv(:,j) = funfcn(x,varargin{:});
                            end
                            func_evals = func_evals + n;
                        end
                    end
                end
                [fv,j] = sort(fv);
                v = v(:,j);
                itercount = itercount + 1;
                if prnt == 3
                    fprintf(' %5.0f        %5.0f     %12.6g         %s\n', itercount, func_evals, fv(1), how)
                elseif prnt == 4
                    disp(' ')
                    disp(how)
                    v
                    fv
                    func_evals
                end
                % OutputFcn and PlotFcns call
                if haveoutputfcn || haveplotfcn
                    [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,v(:,1),xOutputfcn,'iter',itercount, ...
                        func_evals, how, fv(:,1),varargin{:});
                    if stop  % Stop per user request.
                        [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
                        if  prnt > 0
                            disp(output.message)
                        end
                        return;
                    end
                end
            end   % while
            
            x(:) = v(:,1);
            fval = fv(:,1);
            
            output.iterations = itercount;
            output.funcCount = func_evals;
            output.algorithm = 'Nelder-Mead simplex direct search';
            
            % OutputFcn and PlotFcns call
            if haveoutputfcn || haveplotfcn
                callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,'done',itercount, func_evals, how, fval, varargin{:});
            end
            
            if func_evals >= maxfun
                msg = getString(message('MATLAB:fminsearch:ExitingMaxFunctionEvals', sprintf('%f',fval)));
                if prnt > 0
                    disp(' ')
                    disp(msg)
                end
                exitflag = 0;
            elseif itercount >= maxiter
                msg = getString(message('MATLAB:fminsearch:ExitingMaxIterations', sprintf('%f',fval)));
                if prnt > 0
                    disp(' ')
                    disp(msg)
                end
                exitflag = 0;
            else
%                 msg = ...
%                     getString(message('MATLAB:fminsearch:OptimizationTerminatedXSatisfiesCriteria', ...
%                     sprintf('%e',tolx), sprintf('%e',tolf)));
                   msg = sprintf('Optimization terminated: %s the current x satisfies the termination criteria using OPTIONS.TolX of %e %s and F(X) satisfies the convergence criteria using OPTIONS.TolFun of %e',newline,tolx,newline,tolf);
     
%                 if prnt > 1
%                     disp(' ')
%                     disp(msg)
%                 end
                exitflag = 1;
            end
            
            output.message = msg;
        end
        %--------------------------------------------------------------------------
        function [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,state,iter,...
                numf,how,f,varargin)
            % CALLOUTPUTANDPLOTFCNS assigns values to the struct OptimValues and then calls the
            % outputfcn/plotfcns.
            %
            % state - can have the values 'init','iter', or 'done'.
            
            % For the 'done' state we do not check the value of 'stop' because the
            % optimization is already done.
            optimValues.iteration = iter;
            optimValues.funccount = numf;
            optimValues.fval = f;
            optimValues.procedure = how;
            
            xOutputfcn(:) = x;  % Set x to have user expected size
            stop = false;
            % Call output functions
            if ~isempty(outputfcn)
                switch state
                    case {'iter','init'}
                        stop = callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:}) || stop;
                    case 'done'
                        callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:});
                    otherwise
                        error(message('MATLAB:fminsearch:InvalidState'))
                end
            end
            % Call plot functions
            if ~isempty(plotfcns)
                switch state
                    case {'iter','init'}
                        stop = callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:}) || stop;
                    case 'done'
                        callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:});
                    otherwise
                        error(message('MATLAB:fminsearch:InvalidState'))
                end
            end
        end
        %--------------------------------------------------------------------------
        function [x,FVAL,EXITFLAG,OUTPUT] = cleanUpInterrupt(xOutputfcn,optimValues)
            % CLEANUPINTERRUPT updates or sets all the output arguments of FMINBND when the optimization
            % is interrupted.
            
            % Call plot function driver to finalize the plot function figure window. If
            % no plot functions have been specified or the plot function figure no
            % longer exists, this call just returns.
            callAllOptimPlotFcns('cleanuponstopsignal');
            
            x = xOutputfcn;
            FVAL = optimValues.fval;
            EXITFLAG = -1;
            OUTPUT.iterations = optimValues.iteration;
            OUTPUT.funcCount = optimValues.funccount;
            OUTPUT.algorithm = 'Nelder-Mead simplex direct search';
            OUTPUT.message = getString(message('MATLAB:fminsearch:OptimizationTerminatedPrematurelyByUser'));
        end
        %--------------------------------------------------------------------------
        function f = checkfun(x,userfcn,varargin)
            % CHECKFUN checks for complex or NaN results from userfcn.
            
            f = userfcn(x,varargin{:});
            % Note: we do not check for Inf as FMINSEARCH handles it naturally.
            if isnan(f)
                error(message('MATLAB:fminsearch:checkfun:NaNFval', localChar( userfcn )));
            elseif ~isreal(f)
                error(message('MATLAB:fminsearch:checkfun:ComplexFval', localChar( userfcn )));
            end
        end
        
        %--------------------------------------------------------------------------
        function strfcn = localChar(fcn)
            % Convert the fcn to a string for printing
            
            if ischar(fcn)
                strfcn = fcn;
            elseif isa(fcn,'inline')
                strfcn = char(fcn);
            elseif isa(fcn,'function_handle')
                strfcn = func2str(fcn);
            else
                try
                    strfcn = char(fcn);
                catch
                    strfcn = getString(message('MATLAB:fminsearch:NameNotPrintable'));
                end
            end
        end
        
        
        
    end
    
    %Static methods
    methods (Static)
        function [sctEqmod] = dremo(sctEqmod,opt);
            % Full wrapper function for the Dremo model
            % [] = dremo(sctEqmod,opt);
            % Options:
            % bBootstrap: boolean indicating whether bootstrapping should be done.
            %   Default = true.
            % bForecast: Boolean indicating whether forecast scenarios should be run.
            %   Default = false.
            % bPlot: Boolean indicating whether output should be plotted.
            %   Default = true.
            % startForecast: Start of forecast period
            % endForecast: End of forecast period
            % dumpPrognosisTime = Vector with dump times in dump prognosis
            % (for forecast mode)
            % dumpPrognosisVol = Vector with dump volumes in dump prognosis
            % (for forecast mode)
            % strFile: Output file name. A log file (.txt), a .png and a
            % .fig figure will be generated.
            
            if ~isfield(opt,'ddMode');
                error('User must choose either dredging or dumping mode, opt.ddMode = ''dredging'' or ''dumping''');
            end
            
            %% Set default options
            opt = Util.setDefault(opt,'bBootstrap',true);
            opt = Util.setDefault(opt,'bPlot',true);
            opt = Util.setDefault(opt,'bForecast',false);
            
            
            %% Turn on log file
            diary([opt.strFile '.txt']);
            
            %% Calibrate the model
            K = Dremo.calibrate(sctEqmod,opt);
            
            %% Calculate final model results
            [sctEqmod.vVolPred] = Dremo.solveModel(sctEqmod.vTimeModel,sctEqmod.vDumpVol,...
                K,sctEqmod.Veq0,sctEqmod.V0);
            
            %% Calculate MSE from final model
            [mse,R2] = Dremo.calcMSEModel(K,sctEqmod);
            
            %Calculate MSE validation
            rmseVal = sqrt(mean((sctEqmod.vVolValidate - ...
                interp1(sctEqmod.vTimeModel,sctEqmod.vVolPred,sctEqmod.vTimeValidate)).^2));
            R2val = Statistics.coeffdet(sctEqmod.vVolValidate,...
                interp1(sctEqmod.vTimeModel,sctEqmod.vVolPred,sctEqmod.vTimeValidate));
            %% Bootstrap
            if opt.bBootstrap;
                % Set initial guess in bootstrap to the calibrated K value
                % to speed up convergence
                optBootstrap = opt;
                optBootstrap.K0 = K;
                
                % Fit bootstraps
                [sctEqmod,allK,Kupper,Klower] = Dremo.bootstrapFit(sctEqmod,optBootstrap);
                % Evaluate bootstraps
                [sctEqmod] = Dremo.bootstrapEval(sctEqmod,allK,optBootstrap);
            else
                Kupper = nan(3,1);
                Klower = nan(3,1);
                allK = nan;
            end
            
            
            %% Output results to log file
            fprintf('DREMO results:\n');
            fprintf('k1 = %.3e\tk2 = %.3e\tk3 = %.3f\n',K);
            fprintf('T1/2 = %.0f dagen\n',log(2)/K(1));
            fprintf('R2 training = %.4f\n',R2);
            fprintf('R2 validation = %.4f\n',R2val);
            if opt.bBootstrap
                fprintf('95%% CI upper k1 = %.3e\tk2 = %.3e\tk3 = %.3f\n',Klower(1),Klower(2),Klower(3));
                fprintf('95%% CI lower k1 = %.3e\tk2 = %.3e\tk3 = %.3f\n',Kupper(1),Kupper(2),Kupper(3));
            end
            fprintf('%.2e\t%.2e\t%.2e\n',K(1),Klower(1),Kupper(1));
            fprintf('%.2f\t%.2f\t%.2f\n',K(2),Klower(2),Kupper(2));
            fprintf('%.2f\t%.2f\t%.2f\n',K(3),Klower(3),Kupper(3));
            fprintf('%.0f\t%.0f\t%.0f\n',log(2)/K(1),log(2)/Kupper(1),log(2)/Klower(1));
            
            fprintf('%.2f\t%.2f\t%.2e\t\n',K(1),Klower(1),Kupper(1));
            
            fprintf('\n%.2f\t%.2f\t%.0f (%.0f,%.0f)\t%.0f (%.0f,%.0f)\t%.2f (%.2f,%.2f)\n',R2,R2val,...
                log(2)/K(1),log(2)/Kupper(1),log(2)/Klower(1),...
                K(2),Klower(2),Kupper(2),...
                K(3),Klower(3),Kupper(3));
            
            
            %% Output for paper
            
            
            %% Plot results
            if opt.bPlot;
                Dremo.plotResults(sctEqmod,opt);
            end
            
            %% Run forecasts
            if opt.bForecast
                
                % Make new structure
                sctEqmod2 = sctEqmod;
                sctEqmod2.vTimeModel = sctEqmod.vTimeModel(1):opt.endForecast; %Extend time vector to foreast period
                sctEqmod2.vDumpVol = zeros(size(sctEqmod2.vTimeModel)); %Preallocate dump volumes
                
                %Add dump volumes from historic timeseries
                sctEqmod2.vDumpVol(sctEqmod2.vTimeModel < opt.startForecast) = ...
                    interp1(sctEqmod.vTimeModel,sctEqmod.vDumpVol,...
                    sctEqmod2.vTimeModel(sctEqmod2.vTimeModel < opt.startForecast),'nearest',0);
                
                %Add dump volumes from forecast timeseries
                for i = 1:numel(sctEqmod.dumpPrognosisTime);
                    sctEqmod2.vDumpVol(sctEqmod2.vTimeModel == sctEqmod.dumpPrognosisTime(i)) = sctEqmod.dumpPrognosisVol(i);
                end
                
                [sctEqmod2.vVolPred] = Dremo.solveModel(sctEqmod2.vTimeModel,sctEqmod2.vDumpVol,...
                    K,sctEqmod2.Veq0,sctEqmod2.V0);
                
                %% Bootstrap
                if opt.bBootstrap;
                    [sctEqmod2] = Dremo.bootstrapEval(sctEqmod2,allK,opt);
                end
                
                %% Plot forecast results
                opt2 = opt;
                opt2.strFile = [opt2.strFile '_forecast'];
                if opt.bPlot;
                    Dremo.plotResults(sctEqmod2,opt2);
                end
                %% Print forecast results
                fprintf('%.0fm許t%.0fm許t%.0fm許n',sctEqmod2.vVolPred(end),sctEqmod2.vVolPredLowerPI(end),sctEqmod2.vVolPredUpperPI(end));
                
                fprintf('Last measured sounding volume %s (scenario 2):\t %.0f m許n',datestr(sctEqmod2.vTimeMeasured(end)),sctEqmod.vVolMeasured(end));
                fprintf('Forecasted sounding volume on %s (scenario 2):\tMean: %.0f;\tPrediction interval %.0f m3\t--- %.0f m3\n',datestr(sctEqmod2.vTimeModel(end)),sctEqmod2.vVolPred(end),sctEqmod2.vVolPredLowerPI(end),sctEqmod2.vVolPredUpperPI(end));
                fprintf('A change of %.0f\n',sctEqmod.vVolMeasured(end)-sctEqmod2.vVolPred(end));
                
                
                sctEqmod = sctEqmod2;
                
            end
            
            %% Turn off diary
            diary off;
            
        end
        
        
        
        function [K] = calibrate(sctEqmod,opt);
            % Calibrate the model
            % [K] = calibrate(sctEqmod,opt);
            % options:
            % opt.K0: [1x3] array containing initial guesses for [k1,k2,k3] (default: [0.001 100 0.3])
            % opt.freeParams: which of the parameters should be held free for fitting.
            %   Default: [true true true] (all parameters are fit).
            % opt.calibOptions: Calibration options set by optimSet
            
            %Set defaults
            switch opt.ddMode;
                case 'dumping'
                    opt = Util.setDefault(opt,'K0',[0.001 100 0.3]);
                    opt = Util.setDefault(opt,'freeParams',[true true true]);
                case 'dredging'
                    opt = Util.setDefault(opt,'K0',[0.001 100 0]);
                    opt = Util.setDefault(opt,'freeParams',[true true false]);
            end
            %Calibration options
            opt = Util.setDefault(opt,'calibOptions',optimset('maxiter',20000,'maxfunevals',20000,'tolFun',1e-5,'tolx',1e-5));
            
            %Store the non-free parameters in the sctEqmod structure
            sctEqmod.K0 = opt.K0;
            sctEqmod.freeParams = opt.freeParams;
            
            %Fit the free parameters
            Kfree = Dremo.fminsearch2(@(x) Dremo.calcMSEModel(x,sctEqmod),opt.K0(opt.freeParams),opt.calibOptions); %Fit the free parameters
            
            K = opt.K0; %Full parameters
            K(opt.freeParams) = Kfree;
        end
        
        function [sctEqmod,allK,Kupper,Klower] = bootstrapFit(sctEqmod,opt);
            % Fit bootstraps
            % [sctEqmod,allK,Kupper,Klower] = bootstrapFit(sctEqmod,opt);
            % Options (in the opt structure):
            % opt.numBoot: number of bootstraps. Default = 1000.
            
            % Set defaults
            opt = Util.setDefault(opt,'numBoot',1000);
            
            % Generate random numbers of bootstrap matrix
            numMeas = numel(sctEqmod.vTimeMeasured);
            randBoot = randi(numMeas,opt.numBoot,numMeas);
            
            % Preallocate all K values
            allK = zeros(opt.numBoot,3);
            sctEqmodBoot = sctEqmod; %Bootsrap structure
            
            wb = waitbar(0,'Calculating bootstrap fits');
            
            opt.calibOptions = optimset('maxiter',20000,...
                'maxfunevals',20000,'tolFun',1e-5,'tolx',1e-3);%Relax the convergence criterion for tolX for faster calculation
            
            for k = 1:opt.numBoot;
                % Get bootstrap timeseries
                sctEqmodBoot.vTimeMeasured = sctEqmod.vTimeMeasured(randBoot(k,:));
                sctEqmodBoot.vVolMeasured = sctEqmod.vVolMeasured(randBoot(k,:));
                
                allK(k,:) = Dremo.calibrate(sctEqmodBoot,opt);
                waitbar(k/opt.numBoot,wb);
            end
            close(wb)
            
            %Calculate confidence intervals
            allKSorted = nan(size(allK));
            Kupper = nan(1,3);
            Klower = nan(1,3);
            for j = 1:3;
                allKSorted(:,j) =sort(allK(:,j));
                Kupper(j) = allKSorted(round(opt.numBoot*.975),j);
                Klower(j) = allKSorted(round(opt.numBoot*.025),j);
            end
        end
        
        function [sctEqmod] = bootstrapEval(sctEqmod,allK,opt);
            %Evaluate bootstraps
            %[sctEqmod] = bootstrapEval(sctEqmod,allK,opt);
            % Options (in the opt structure):
            % opt.numBoot: number of bootstraps. Default = 1000.
            
            % Set defaults
            opt = Util.setDefault(opt,'numBoot',1000);
            
            %% Prediction interval
            
            allV = nan(numel(sctEqmod.vTimeModel),opt.numBoot);% Preallocate all bootstrap result timeseries
            for k = 1:opt.numBoot;
                allV(:,k) = Dremo.solveModel(sctEqmod.vTimeModel,sctEqmod.vDumpVol,...
                    allK(k,:),sctEqmod.Veq0,sctEqmod.V0);
            end
            
            Vsorted = sort(allV,2);
            %Confidence interval
            sctEqmod.vVolPredUpperCI = Vsorted(:,round(opt.numBoot*.975));
            sctEqmod.vVolPredLowerCI = Vsorted(:,round(opt.numBoot*.025));
            
            %Calculate rmse for prediction interval
            sctEqmod.vModelatMeastime = interp1(sctEqmod.vTimeModel,sctEqmod.vVolPred,sctEqmod.vTimeMeasured);
            rmse = sqrt(mean((sctEqmod.vModelatMeastime-sctEqmod.vVolMeasured).^2));
            
            %Prediction interval
            sctEqmod.vVolPredUpperPI = sctEqmod.vVolPredUpperCI+1.96*rmse;
            sctEqmod.vVolPredLowerPI = sctEqmod.vVolPredLowerCI-1.96*rmse;
        end
        
        function [] = eqmod2xls(sctEqmod,opt);
            % Save eqmod structure to Excel sheet
            % [] = eqmod2xls(sctEqmod,opt);
            % Options:
            % opt.dremoXls: File name for Excel file
            
            warning('off','MATLAB:xlswrite:AddSheet'); %Turn off that stupid warning every time you add a sheet
            
            
            % Save measured volumes
            sheet = 'MeasuredSoundingVolumes';
            tab(:,1) = cellstr(datestr(sctEqmod.vTimeMeasured,'yyyy-mm-dd'));
            tab(:,2) = num2cell(sctEqmod.vVolMeasured);
            xlswrite(opt.dremoXls,tab,sheet);
            clear tab;
            
            % Save validation volumes
            sheet = 'ValidationSoundingVolumes';
            tab(:,1) = cellstr(datestr(sctEqmod.vTimeValidate,'yyyy-mm-dd'));
            if ~isempty(sctEqmod.vVolValidate);
                tab(:,2) = num2cell(sctEqmod.vVolValidate);
            else
                tab(:,2) = {''};
            end
            xlswrite(opt.dremoXls,tab,sheet);
            clear tab;
            
            % Save dumping volumes
            sheet = 'DumpingVolumes';
            tab(:,1) = cellstr(datestr(sctEqmod.vTimeModel,'yyyy-mm-dd'));
            tab(:,2) = num2cell(sctEqmod.vDumpVol);
            xlswrite(opt.dremoXls,tab,sheet);
            clear tab;
            
            % Save V0;
            sheet = 'V0';
            tab = {sctEqmod.V0};
            xlswrite(opt.dremoXls,tab,sheet);
            clear tab;
            
            % Save Veq0;
            sheet = 'Veq0';
            tab = {sctEqmod.Veq0};
            xlswrite(opt.dremoXls,tab,sheet);
            clear tab;
            
            % Save dumping prognosis
            if isfield(sctEqmod,'dumpPrognosisTime');
                sheet = 'DumpingPrognosis';
                tab(:,1) = cellstr(datestr(sctEqmod.dumpPrognosisTime,'yyyy-mm-dd'));
                tab(:,2) = num2cell(sctEqmod.dumpPrognosisVol);
                xlswrite(opt.dremoXls,tab,sheet);
            end
            clear tab;
            
            warning('on','MATLAB:xlswrite:AddSheet');
        end
        
        function [sctEqmod] = xls2eqmod(opt);
            % Load eqmod structure to Excel sheet
            % [sctEqmod] = eqmod2xls(opt);
            
            % Load measured volumes
            sheet = 'MeasuredSoundingVolumes';
            [~,~,tab] = xlsread(opt.dremoXls,sheet);
            sctEqmod.vTimeMeasured = datenum(tab(:,1),'dd/mm/yyyy');
            sctEqmod.vVolMeasured = cell2mat(tab(:,2));
            clear tab;
            
            try;
                % Load validation volumes
                sheet = 'ValidationSoundingVolumes';
                [~,~,tab] = xlsread(opt.dremoXls,sheet);
                sctEqmod.vTimeValidate = datenum(tab(:,1),'dd/mm/yyyy');
                sctEqmod.vVolValidate = cell2mat(tab(:,2));
                clear tab;
            catch;
                sctEqmod.vTimeValidate = [];
                sctEqmod.vVolValidate = [];
            end
            
            % Load dumping volumes
            sheet = 'DumpingVolumes';
            [~,~,tab] = xlsread(opt.dremoXls,sheet);
            dumpTimes =  datenum(tab(:,1),'dd/mm/yyyy');
            dumpVolumes = cell2mat(tab(:,2));
            
            sctEqmod.vTimeModel = floor(min(dumpTimes)):1:floor(max(dumpTimes));
            sctEqmod.vDumpVol = nan(size(sctEqmod.vTimeModel));
            for iTime = 1:numel(sctEqmod.vTimeModel);
                mask = find(sctEqmod.vTimeModel(iTime) == round(dumpTimes));
                sctEqmod.vDumpVol(iTime) = sum(dumpVolumes(mask));
            end
            
            clear tab;
            
            % Load V0
            try;
                sheet = 'V0';
                [sctEqmod.V0,~,~] = xlsread(opt.dremoXls,sheet);
            catch;
                sctEqmod.V0=0;
            end
            
            % Load Veq0
            try;
                sheet = 'Veq0';
                [sctEqmod.Veq0,~,~] = xlsread(opt.dremoXls,sheet);
            catch;
                sctEqmod.Veq0 =0;
            end
            % Load dumping prognosis
            try;
                sheet = 'DumpingPrognosis';
                [~,~,tab] = xlsread(opt.dremoXls,sheet);
                sctEqmod.dumpPrognosisTime = datenum(tab(:,1),'dd/mm/yyyy');
                sctEqmod.dumpPrognosisVol = cell2mat(tab(:,2));
                clear tab;
            end
            
        end
        
        function [] = plotResults(sctEqmod,opt);
            % Plot results of Dremo model
            % [] = plotResults(sctEqmod,opt);
            
            %% Set defaults
                                
            opt = Util.setDefault(opt,'nXInt',90);
            opt = Util.setDefault(opt,'cYlabels1',{'In-situ Volume [x 10 ^6 m設'});
            opt = Util.setDefault(opt,'nScalingFactor',1/1000000);
            opt = Util.setDefault(opt,'legendLocation','best');
            opt = Util.setDefault(opt,'vXlim',[min(sctEqmod.vTimeModel) max(sctEqmod.vTimeModel+20)]);
            opt = Util.setDefault(opt,'axesChoice',0) %0 is the default, just one y axis
            opt = Util.setDefault (opt, 'area', 0) % is the default, that is no specification for SH41 or SH51 
            
            %% PLOT THE DATA
            %%%%%%%%%%%%%%%%%
             if opt.axesChoice == 1
                 UtilPlot.reportFigureTemplate('Portrait',6); 
             else
                 UtilPlot.reportFigureTemplate('Portrait',8);
             end
            set(gcf,...
                'defaultaxesfontsize',8,...
                'defaulttextfontsize',8);
            hAx1 = axes;
            
            hold all;
            grid on;
            box on;
            
            if opt.axesChoice == 1
                yyaxis right 
                ylabel (hAx1, 'In-situ Volume [x 10^6 m^3 ]', 'color', 'k'); 
                if opt.area == 1 % for SH41
                ylim ([-1, 7]); 
                yticks ([-1 0 1 2 3 4 5 6 7])
                end
                if opt.area == 2 % for SH51
                     ylim ([-1, 5]); 
                yticks ([-1 0 1 2 3 4 5])   
                end
                set (hAx1, 'YColor', 'k'); 
%                 set(get(hAx1,'ylabel'), 'color', 'k', 'String','In-situ Volume [x 10^6 m^3 ]', 'color', 'red');
%                  ylabel (hAxl,'String','In-situ Volume [x 10^6 m^3 ]', 'color', 'red');
            end
            
            
            plot(hAx1,sctEqmod.vTimeModel,sctEqmod.vVolPred.* opt.nScalingFactor,...
                '-','color',[245 135 0]/255,'markersize',4,...
                'displayname','Peilvolume model','linewidth',2);
            
            if opt.bBootstrap;
                plot(hAx1,sctEqmod.vTimeModel,sctEqmod.vVolPredUpperPI.* opt.nScalingFactor,...
                    '--','color',[245 135 0]/255,'markersize',4,...
                    'displayname','Peilvolume model (95% PI boven)','linewidth',1);
                plot(hAx1,sctEqmod.vTimeModel,sctEqmod.vVolPredLowerPI.* opt.nScalingFactor,...
                    '--','color',[245 135 0]/255,'markersize',4,...
                    'displayname','Peilvolume model (95% PI onder)','linewidth',1);
            end
            plot(hAx1,sctEqmod.vTimeMeasured,sctEqmod.vVolMeasured .* opt.nScalingFactor,'bo','markersize',4,...
                'markerfacecolor','b','displayname','Peilvolume metingen');
            if isfield(sctEqmod,'vTimeValidate'); %Als er validatiemetingen worden meegerekend
                plot(hAx1,sctEqmod.vTimeValidate,sctEqmod.vVolValidate .* opt.nScalingFactor,'^','markersize',4,...
                    'color',[0 0.8 0],'markerfacecolor',[0 0.8 0],'displayname','Peilvolume metingen (validatie)');
            end
            
            if opt.axesChoice == 1
                yyaxis left  % EKR
                
                if opt.area == 1 % for SH41
                    ylim ([-5, 35])
                    yticks ([-5 0 5 10 15 20 25 30 35])
                end
                if opt.area == 2 % for SH51
                    ylim ([-2, 10])
                    yticks ([-2 0 2 4 6 8 10])
                end
                set (hAx1, 'YColor', 'k');
                ylabel (hAx1, 'Stortvolume [x 10^6 m^3 ]', 'Color', 'red');
            end
            
            switch opt.ddMode;
                case 'dumping'
                    plot(hAx1,sctEqmod.vTimeModel,cumsum(sctEqmod.vDumpVol).* opt.nScalingFactor,'r-','color',[0.95 0.2 0]','markersize',4,...
                        'displayname','Stortvolume');
                case 'dredging'
                    plot(hAx1,sctEqmod.vTimeModel,-1*cumsum(sctEqmod.vDumpVol).* opt.nScalingFactor,'r-','color',[0.95 0.2 0]','markersize',4,...
                        'displayname','Baggervolume');
                    
            end
            
            
            %% Layout stuff


  if opt.axesChoice == 1
            legend(hAx1, 'location',opt.legendLocation); % EKR            
%         set(hAx1, {'XColor', 'YColor'}, {'k', 'k'}); 
    
  else
            ylabel(hAx1, opt.cYlabels1{1}); 
            legend(hAx1,'location',  opt.legendLocation );
            if isfield(opt,'vYlim');  
                ylim(opt.vYlim);
            end
  end
            
%             if isfield(opt,'vYlim');  %% EKR commented
%                 ylim(opt.vYlim);
%             end
            
                        
            % X-axis
            vXlim = opt.vXlim;
            if diff(vXlim)>5*365;%If plot is more than 1 year long
                %One tick per 12 months
                vXTickVec = datenum([(2005:2034)',ones(30,1),ones(30,1)]);
                set(hAx1, 'xtick', vXTickVec, 'xticklabel',datestr(vXTickVec,'yyyy'), 'xlim', vXlim);
            else
                if diff(vXlim)>1*370;%If plot is more than 1 year long
                    %One tick per 6 months
                    vXTickVec = datenum([2005*ones(12*30/6,1),[1:6:12*30]',ones(12*30/6,1)]);
                    set(hAx1, 'xtick', vXTickVec, 'xticklabel',datestr(vXTickVec,'mm/yyyy'), 'xlim', vXlim);
                else
                    %One tick per two months
                    vXTickVec = datenum([1900*ones(12*300/2,1),[1:2:12*300]',ones(12*300/2,1)]);
                    set(hAx1, 'xtick', vXTickVec, 'xticklabel',datestr(vXTickVec,'dd/mm/yyyy'), 'xlim', vXlim);
                    
                end
            end
            
            set(hAx1,'layer', 'top', 'linewidth', 1);
            
            %% SAVE FIGURE
            set(gcf,'Renderer','painters');
            UtilPlot.saveFig(strrep(opt.strFile,'.','_'));
            
            close gcf;
            
        end
        
        function sctEqmod = prepareDataDiepeDelen(sctDredging,sctVolStab,sctSounding,opt);
            % Prepare data based on result files from Diepe Delen
            % sctEqmod = prepareDataDiepeDelen(sctDredging,sctVolStab,sctSounding,opt);
            %
            % Inputs
            %
            % sctDredging: Struct containing the information from the dredging file,
            % containing:
            %     strFile: Filename (incl path) of the excel file with dredging data
            %     strTab: Naam of sheet (tabblad) containing dredging data
            %     vColTime: Column in excelsheet with time
            %     nColVol: Column in excelhsheet with dredged volumes
            %
            % sctSounding: Struct containing the sounding volumes data
            %     strFile: Filename (incl path) of the excel file with souding data
            %     strTab: Naam of sheet (tabblad) containing  data
            %     vColTime: Column in excelsheet with time
            %     vColLabels: Columns containing names of sounding areas.
            %     cNameSelection: Which section/polygon is to be extracted from the sheet
            %
            % sctVolStab: Struct containing information from the volumetric stability calculations, containing:
            %     strFile: Filename (incl path) of the excel file with volumetric stability data
            %     strTab: Naam of sheet (tabblad) containing data
            %     nColTime: Column in excelsheet with time
            %     nColSoundingNum: Column with sounding numbers
            %     nColSoundingVol: Column with sounding volumes
            % The volumetric stability data contains just the same sounding volumes as the sounding dataset,
            % except that in the volumetric stability excelsheet soundings with less than a certain coverage
            % are thrown out (e.g. soundings that only cover 30% of the study area. So the volstab could be replaced
            % by sounding data.
            %
            % opt: Structure containign optional stuff, containg the following
            % fields
            % ddmode: string (either 'dredging' or 'dumping') indicating if it's a
            %   dredging or dumping area
            % strT0: name of first sounding (default: 't00')
            % startValidation: Start of validation period. Only data from before this
            %   date is included in the trainig dataset of the model (don't define this
            %   if you don't use validation mode)
            
            
            %% Set defaults
            opt = Util.setDefault(opt,'strT0','t00');
            
            
            %% Load dumping data
            [~,~,sctDredging.cData] = xlsread(sctDredging.strFile, sctDredging.strTab);
            sctDredging.cHeader = sctDredging.cData(1,:);
            sctDredging.cUnit = [];
            sctDredging.cData(1,:) = [];
            sctDredging.vTime = datenum(sctDredging.cData(:,sctDredging.vColTime(1)),'dd/mm/yyyy');
            sctDredging.vVol = cell2mat(sctDredging.cData(:,sctDredging.nColVol));
            
            %% Load Volumetric stability data (for sounding information)
            [~,~,sctVolStab.cData] = xlsread(sctVolStab.strFile, sctVolStab.strTab);
            sctVolStab.cHeader = sctVolStab.cData(1,:);
            sctVolStab.cUnit = [];
            sctVolStab.cData(1:2,:) = [];
            sctVolStab.vTime = datenum(sctVolStab.cData(:,sctVolStab.nColTime),'dd/mm/yyyy');
            sctVolStab.cSoundingNum = sctVolStab.cData(:,sctVolStab.nColSoundingNum);
            sctVolStab.vSoundingVol = cell2mat(sctVolStab.cData(:,sctVolStab.nColSoundingVol));
            
            %% Load sounding data
            [~,~,sctSounding.cData] = xlsread(sctSounding.strFile, sctSounding.strTab);
            sctSounding.cHeader = sctSounding.cData(1,:);
            sctSounding.cUnit = [];
            sctSounding.cData([1 2],:) = [];
            sctSounding.vTime = [datenum(sctSounding.cData(:,sctSounding.vColTime(1)),'dd/mm/yyyy');
                datenum(sctSounding.cData(:,sctSounding.vColTime(2)),'dd/mm/yyyy')];
            sctSounding.cLabel = [sctSounding.cData(:,sctSounding.vColLabels(1));sctSounding.cData(:,sctSounding.vColLabels(2))];
            [sctSounding.vTime,ia] =unique(sctSounding.vTime);
            sctSounding.cLabel = sctSounding.cLabel(ia);
            
            %% Select only the time range after start sounding opt.strT0
            opt.nStartTime = sctSounding.vTime(strcmpi(sctSounding.cLabel,opt.strT0));
            vMask = sctDredging.vTime>=opt.nStartTime;
            
            %% Make equilibrium model input data
            sctEqmod.vTimeModel = sctDredging.vTime(vMask); %Time vector ---> all days since start;
            %             sctEqmod.vTimeModel = sctEqmod.vTimeModel(sctEqmod.vTimeModel<=max(sctVolStab.vTime));
            switch opt.ddMode;
                case 'dredging';
                    sctEqmod.vDumpVol = -sctDredging.vVol(vMask);
                    
                case 'dumping';
                    sctEqmod.vDumpVol = sctDredging.vVol(vMask);
                otherwise;
                    error('User must choose either dredging or dumping mode, opt.ddMode = ''dredging'' or ''dumping''');
            end
            
            if sctEqmod.vTimeModel(1)> sctVolStab.vTime(1);
                nt = numel(sctVolStab.vTime(1):sctEqmod.vTimeModel(1)-1);
                sctEqmod.vTimeModel = [sctVolStab.vTime(1):sctEqmod.vTimeModel(1)-1 sctEqmod.vTimeModel']';
                sctEqmod.vDumpVol = [zeros(nt,1);sctEqmod.vDumpVol];
            end
            
            startTime = sctEqmod.vTimeModel(1);
            
            %Selecteer enkel de peilingen VOOR de validatieperiode om het model te
            %kallibreren
            vMask2 = sctVolStab.vTime>=opt.nStartTime & sctVolStab.vTime < opt.startValidatie;
            sctEqmod.vTimeMeasured = sctVolStab.vTime(vMask2);
            sctEqmod.vVolMeasured = sctVolStab.vSoundingVol(vMask2);
            
            vMask3 = sctVolStab.vTime>=opt.startValidatie;
            sctEqmod.vTimeValidate = sctVolStab.vTime(vMask3);
            sctEqmod.vVolValidate = sctVolStab.vSoundingVol(vMask3);
            
            sctEqmod.Veq0 =  sctEqmod.vVolMeasured(1);%Equilibrium profile volume
            sctEqmod.V0 = sctEqmod.vVolMeasured(1);
            
        end
        
        function [mse,R2] = calcMSEModel(Kfree,opt);
            % Function that calls the equilibrium model and returns the mean
            % square error. For optimization algorithm.
            %
            % [mse,R2] = calcMSEModel(Kfree,opt);
            %
            % Inputs:
            % K: [1x3] array containg fitting paramters [k1,k2,k3]
            % Opt: Structure containng the following fields:
            % vTimeModel: Time vector for model
            % vDumpVol: Vector containing dumping volumes
            % vEq0: Initial value for equilibrium volume (typically 0)
            % opt: Initial value for sounding volume (typically 0)
            % vTimeMeasured: Time vector for measured sounding volumes
            % vVolMeasured: Measured sounding volumes
            % opt.K0: [1x3] array containing initial guesses for [k1,k2,k3] (default: [0.001 100 0.3])
            % opt.freeParams: which of the parameters should be held free for fitting.
            %   Default: [1 1 1] (all parameters are fit).
            %
            % Outputs:
            % mse: Mean square error of the model calculation
            % R2: Coefficient of determination
            %Set defaults
            opt = Util.setDefault(opt,'K0',[0.001 100 0.3]);
            opt = Util.setDefault(opt,'freeParams',[true true true]);
            
            %Fill the full calibration vector with the fixed parameters
            %(from K0) and the free parameters
            K = opt.K0;
            K(opt.freeParams) = Kfree;
            
            %% Numerically solve the evolution
            [vVolPred] = Dremo.solveModel(opt.vTimeModel,opt.vDumpVol,...
                K,opt.Veq0,opt.V0);
            
            vVolPred_measTime = interp1(opt.vTimeModel,vVolPred,opt.vTimeMeasured);
            
            mse = mean((vVolPred_measTime-opt.vVolMeasured).^2);
            R2 = Statistics.coeffdet(opt.vVolMeasured,vVolPred_measTime);
            if K(1) < 0 & K(1) ~=-999;
                mse = mse*100*10^(-1*K(1));
            end
            if K(3) < 0;
                mse = mse*100*10^(-1*K(3));
            end
            if K(3) > 1;
                mse = mse*100*10^(K(3));
            end
            
        end
        
        function [V] = solveModel(t,Vdump,K,Veq0,V0);
            %Solve Dremo model equation
            % [V] = solveModel(t,Vdump,K,Veq0,V0);
            %
            %
            % Inputs:
            % t: time vector of the model. Usually has a time step of 1 day
            % Vdump: vector containing dumping volumes (same size as t)
            % K = [k1 k2 k3] with
            %   k1: First fitting parameter (decay constant)
            %   k2: Second fitting parameter (linear evolution constant)
            %   k3: Third fitting parameter (loss factor)
            % vEq0: Initial value for equilibrium volume (typically 0)
            % V0: Initial value for the sounding volume
            %
            % Outputs:
            % V: Sounding volume time series calculated by the model
            
            % Unwrap calibration value vector
            k1 = K(1);
            k2 = K(2);
            k3 = K(3);
            
            if k1 ~= -999; %Normal mode; k1 = -999 is a special mode
                
                % Make sum of all dumping volumes, already with a decay term
                sumDecayVDumpPrime = nan(size(t)); %Initial dump decay vector
                sumDecayVDumpPrime(1) = Vdump(1);
                for i= 2:numel(sumDecayVDumpPrime);
                    sumDecayVDumpPrime(i) = Vdump(i) + ...
                        sumDecayVDumpPrime(i-1) * exp(-k1*(t(i)-t(i-1)));
                    
                end;
                %Calculate resulting sounding volume timeseries
                V = (V0 - Veq0 + k2/k1) * exp(-k1 * (t - t(1))) ...
                    + k2 * (t - t(1)) ...
                    + Veq0 - k2/k1 ...
                    + (1-k3) * sumDecayVDumpPrime;
            else
                % Make sum of all dumping volumes, already with a decay term
                sumDecayVDumpPrime = nan(size(t)); %Initial dump decay vector
                sumDecayVDumpPrime(1) = Vdump(1);
                for i= 2:numel(sumDecayVDumpPrime);
                    sumDecayVDumpPrime(i) = Vdump(i) + ...
                        sumDecayVDumpPrime(i-1);
                    
                end;
                %Calculate resulting sounding volume timeseries
                V = ...
                    + k2 * (t - t(1)) ...
                    + Veq0 ...
                    + (1-k3) * sumDecayVDumpPrime;
                
            end
            
        end
        
        
    end
end