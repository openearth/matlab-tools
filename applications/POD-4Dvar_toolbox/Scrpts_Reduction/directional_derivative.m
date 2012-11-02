function [varargout] = directional_derivative(varargin)
% Central difference scheme - directional_derivative(options,patterns,epsilon,steps,mbg)
% Forward difference scheme - directional_derivative(options,patterns,epsilon,steps,mbg,runbg)

    whattodo = varargin{1}; 
    options = varargin{2};

    if strcmpi(options.gateaux.type,'central')

        if strcmpi(whattodo,'run')
            if nargin ~= 5, error('MATLAB:InputError','Wrong number of input arguments, must be 5.'); end
            if nargout ~= 0, error('MATLAB:OutputError','Wrong number of output arguments, "run" produces none.'); end
            patterns = varargin{3};
            mbg      = varargin{5};
            epsilon  = varargin{4};
            
            centraldiff(patterns,epsilon,mbg,options);
            
        elseif strcmpi(whattodo,'load')
            if nargin ~= 7, error('MATLAB:InputError','Wrong number of input arguments, must be 6.'); end
            if nargout== 0, error('MATLAB:OutputError','Wrong number of output arguments, "load" produces one.'); end
            patterns = varargin{3};
            epsilon  = varargin{4};
            mbg      = varargin{5};
            steps    = varargin{6};
            spdomain = varargin{7};
            
            varargout{1} = centraldiffload(patterns,epsilon,steps,mbg.mainpath,mbg.mdf.runID,spdomain,options);
            
        end    

    elseif strcmpi(options.gateaux.type,'forward')

        if strcmpi(whattodo,'run')
            if nargin ~= 5, error('MATLAB:InputError','Wrong number of input arguments, must be 6.'); end
            if nargout ~= 0, error('MATLAB:OutputError','Wrong number of output arguments, "run" produces none.'); end
            patterns = varargin{3};
            mbg      = varargin{5};
            epsilon  = varargin{4};

            forwarddiff(patterns,epsilon,mbg,options);
            
        elseif strcmpi(whattodo,'load')
            if nargin ~= 7, error('MATLAB:InputError','Wrong number of input arguments, must be 6.'); end
            if nargout== 0, error('MATLAB:OutputError','Wrong number of output arguments, "load" produces one.'); end
            mbg      = varargin{5};
            steps    = varargin{6};
            patterns = varargin{3};
            runbg    = varargin{7};
            epsilon  = varargin{4};

            varargout{1} = forwarddiffload(patterns,epsilon,steps,mbg.mainpath,mbg.mdf.runID,runbg,options);
            
        end

    elseif strcmpi(options.gateaux.type,'solve')
        
        if nargin ~= 9, error('MATLAB:InputError','Wrong number of input arguments, must be 8.'); end

        patterns = varargin{3};
        snaps     = varargin{4};
        numsnaps = varargin{5};
        steps    = varargin{6};
        dN_da    = varargin{7};
        mainpath = varargin{8};
        bgrun    = varargin{9};
        
        disp(['Estimation of the dynamic component initiating:',char(10),...
                '- Number of patterns: ',num2str(patterns.No),char(10),...
                '- Number of snapshots: ',num2str(numsnaps),char(10),...
                '- Number of timesteps: ',num2str(steps),char(10),...
                '- Working in: ', mainpath]);
        
        
        if ~options.gateaux.loadinfoflag,
            disp(['Loading: ',mainpath,'gateaux_solve']);    
            load([mainpath,'gateaux_solve']);
            varargout{1} = N;
            return
        end
        
        for isnap=numsnaps:-1:1
            disp(['Opening: ',snaps(isnap).mainpath,'snap_results.mat'])
            rsnap(isnap) = importdata([snaps(isnap).mainpath,'snap_results.mat']);
            a(:,isnap) = snaps(isnap).configP';
        end
        clear snaps
        
        % Put the snapshot information in some nicer format.
        thesnaps = zeros(patterns.No,numsnaps,steps+1);
        for istep=1:1:steps+1
            for isnap=1:1:numsnaps  
                thesnaps(:,isnap,istep) = patterns.vectors'*(rsnap(isnap).vectors.dps(:,istep) - bgrun.vectors.dps(:,istep));
            end
        end    
        clear rsnap
        
        
        bfgs_options = struct('GradObj','on', ...
                'Display','iter', ...
                'LargeScale','off', ...
                'HessUpdate','bfgs', ...
                'InitialHessType','identity', ...
                'GoalsExactAchieve',1, ...
                'GradConstr',false, ...
                'MaxIter',options.gateaux.solver_num_iterations);

        varIn = zeros(steps*patterns.No^2,1);  % Initial guesss
        


% Lets make the matrix of state vectors
input(numsnaps) = struct();
output(numsnaps) = struct();

for isnap = 1:1:numsnaps
    % Input for the system
    input(isnap).states = cell(steps+1,steps+1);
    % What I should get
    output(isnap).states = cell(steps+1,steps+1);

    for icol = 1:1:steps+1

          input(isnap).states{icol,icol} = thesnaps(:,isnap,icol);
         output(isnap).states{icol,icol} = thesnaps(:,isnap,icol);

        for irow = icol+1:1:steps+1
             input(isnap).states{irow,icol} = dN_da{irow-1}*a(:,isnap);
            output(isnap).states{irow,icol} = thesnaps(:,isnap,irow);
        end
    end
end

        tic, [x,fval] = fminlbfgs(@runJ,varIn,bfgs_options); toc,
        
        N = cell(steps,1);
        for iN_dd=1:1:steps,    
            N{iN_dd} = reshape(x((iN_dd-1)*patterns.No^2+1:(iN_dd)*patterns.No^2,1),patterns.No,patterns.No);   
        end
        save([mainpath,'gateaux_solve.mat'],'N')
        varargout{1} = N;
            
    end
    
    
    function [res1,res2] = runJ(inp)
        for iN=1:1:steps,   N{iN} = reshape(inp((iN-1)*patterns.No^2+1:(iN)*patterns.No^2,1),patterns.No,patterns.No);        end
        [res1,res2]=optJfunc(steps,patterns.No,N,numsnaps,input,output,a);
    end

end

%__________________________________________________________________________
%% (1) CENTRAL DIFFERENCE SCHEME
function [] = centraldiff(patterns,epsilon,mbg,options)

    if options.gateaux.runflag,
         disp([char(10),'Executing perturbed parameter runs for directional derivative']);           % Parameters perturbed runs
        gateaux(1:patterns.No) = struct(mbg);
        
        for iPattern = options.gateaux.pattern_start:1:patterns.No
            gateaux(iPattern) = mbg;
            gateaux(iPattern).mdf.Tstop = 0;                               %Stop time

            gateaux(iPattern).mainpath = [mbg.mainpath(1:end-11),'Pattern',num2str(iPattern,'%3.3i'),'_-E','Run',filesep];        % F(X-eP)
            runprturbs('directional',gateaux(iPattern), patterns.info{iPattern}, (-1*epsilon), mbg.mainpath,options.gateaux.step_start,options.numNodesInCluster);
            % losstepsfolders = dir([gateaux(iPattern).mainpath,'Step*']); for ifolder=1:1:length(losstepsfolders), d3dfinish([gateaux(iPattern).mainpath,losstepsfolders(ifolder).name,filesep],0); end
            
            gateaux(iPattern).mainpath = [mbg.mainpath(1:end-11),'Pattern',num2str(iPattern,'%3.3i'),'_+E','Run',filesep];        % F(X+eP)
            runprturbs('directional',gateaux(iPattern), patterns.info{iPattern}, (+1*epsilon), mbg.mainpath,options.gateaux.step_start,options.numNodesInCluster);
            % losstepsfolders = dir([gateaux(iPattern).mainpath,'Step*']); for ifolder=1:1:length(losstepsfolders), d3dfinish([gateaux(iPattern).mainpath,losstepsfolders(ifolder).name,filesep],0); end
        end
    end

end
function [N] = centraldiffload(patterns,epsilon,steps,mainpath,runid,thedomain,options)

    if options.gateaux.loadinfoflag,
        
        [~,b] = system('qstat -u garcia_in');
        while length(strfind(b, 'garcia_in')) > 2
            disp('Waiting for first batch of jobs to finish.')
            [~,b] = system('qstat -u garcia_in');
            strfind(b, 'garcia_in');
            pause(120);
        end
        clear b

        for iPattern=1:1:patterns.No
          
            gateaux(iPattern).mainpath = [mainpath(1:end-11),'Pattern',num2str(iPattern,'%3.3i'),'_-E','Run',filesep];           
            Perturb_back(iPattern) = getrunsinfo(gateaux(iPattern).mainpath,runid,options.getrunsinfo);

            gateaux(iPattern).mainpath = [mainpath(1:end-11),'Pattern',num2str(iPattern,'%3.3i'),'_+E','Run',filesep];
            Perturb_ahead(iPattern) = getrunsinfo(gateaux(iPattern).mainpath,runid,options.getrunsinfo);
        
        end
        save([mainpath(1:end-11),'gateaux_back.mat'],'Perturb_back')
        save([mainpath(1:end-11),'gateaux_ahead.mat'],'Perturb_ahead')
    else
        disp(['Loading: ',mainpath(1:end-11),'gateaux_back']);    load([mainpath(1:end-11),'gateaux_back']);
        disp(['Loading: ',mainpath(1:end-11),'gateaux_ahead']);   load([mainpath(1:end-11),'gateaux_ahead']);
    end

    % Central difference derivative estimation
    for jTStep = 1:1:steps
      ladiff = (Perturb_ahead(1).vectors.dps(:,jTStep) - Perturb_back(1).vectors.dps(:,jTStep)).*thedomain;
      N(jTStep) = {ladiff./(2*epsilon)};
      for iPattern=2:1:patterns.No
          ladiff = (Perturb_ahead(iPattern).vectors.dps(:,jTStep) - Perturb_back(iPattern).vectors.dps(:,jTStep)).*thedomain;
          N(jTStep) = {[N{jTStep}, ladiff./(2*epsilon)]};
      end
      N(jTStep) = {patterns.vectors'*N{jTStep}};
    end
end

%__________________________________________________________________________
%% (2) FORWARD DIFFERENCE SCHEME
function [] = forwarddiff(patterns,epsilon,mbg,options)

    if options.gateaux.runflag,
        disp([char(10),'Executing perturbed parameter runs for directional derivative']);           % Parameters perturbed runs
        gateaux(1:patterns.No) = struct(mbg);
        
        for iPattern = options.gateaux.pattern_start:1:patterns.No
            gateaux(iPattern) = mbg;                                       %Everything should be like in the background run
            gateaux(iPattern).mdf.Tstop = 0;                               %Stop time
      
            gateaux(iPattern).mainpath = [mbg.mainpath(1:end-11),'Pattern',num2str(iPattern,'%3.3i'),'_+E','Run',filesep];        % F(X+eP)
            runprturbs('directional', gateaux(iPattern), patterns.info{iPattern}, epsilon, mbg.mainpath,options.gateaux.step_start,options.numNodesInCluster); 
            % losstepsfolders = dir([gateaux(iPattern).mainpath,'Step*']); for ifolder=1:1:length(losstepsfolders), d3dfinish([gateaux(iPattern).mainpath,losstepsfolders(ifolder).name,filesep],10); end
        end
    end

end
function [N] = forwarddiffload(patterns,epsilon,steps,mainpath,runid,runbg,options)

    if options.gateaux.loadinfoflag,

         [~,b] = system('qstat -u garcia_in');
         while length(strfind(b, 'garcia_in')) > 2
             disp('Waiting for first batch of jobs to finish.')
             [~,b] = system('qstat -u garcia_in');
             strfind(b, 'garcia_in');
             pause(120);
         end
         clear b

        for iPattern = 1:1:patterns.No
            gateaux(iPattern).mainpath = [mainpath(1:end-11),'Pattern',num2str(iPattern,'%3.3i'),'_+E','Run',filesep];            % F(X+eP)
            Perturb_ahead(iPattern) = getrunsinfo(gateaux(iPattern).mainpath,runid,options.getrunsinfo);
        end
        
        save([mainpath(1:end-11),'gateaux_ahead.mat'],'Perturb_ahead')

    else

      disp(['Loading: ',mainpath(1:end-11),'gateaux_ahead']);
      load([mainpath(1:end-11),'gateaux_ahead']);
    end
  
    % Forward difference derivative estimation
    for jTStep = 1:1:steps
        ladiff = (Perturb_ahead(1).vectors.dps(:,jTStep) - runbg.vectors.dps(:,jTStep+1)).*runbg.vectors.morcells;
        N(jTStep) = {ladiff./epsilon};
        for iPattern=2:1:patterns.No
            ladiff = (Perturb_ahead(iPattern).vectors.dps(:,jTStep) - runbg.vectors.dps(:,jTStep+1)).*runbg.vectors.morcells;
            N(jTStep) = {[N{jTStep}, ladiff./epsilon]};
        end
        N(jTStep) = {patterns.vectors'*N{jTStep}};
    end
end

%__________________________________________________________________________
%% (3) Solve for forward
function [J,dJ_dN]=optJfunc(steps,numpatterns,N,numsnaps,input,output,a)

    %This is the system that we want to optimize. 
    theSystem = cell(steps,steps+1);
    for icol = 1:1:steps+1
        theSystem{icol,icol} = eye(numpatterns);        % The off-diagonal must be ones. 

        for irow = icol+1:1:steps+1,        theSystem{irow,icol} = N{irow-1}*theSystem{irow-1,icol};        end
    end

    
    % Lets get the derivative and cost
    J = 0;
    dJ_dN = cell(steps,1);
    for isnap = 1:1:numsnaps
        %disp(['Estimating cost in perturbed run: ',num2str(isnap)])
        
        d_dN = cell(steps,steps+1);
        for iInputCol =1:1:steps+1
        
            % The left hand side matrix is finished....
            thisproduct = cell_matrix_product(theSystem,input(isnap).states(:,iInputCol));
            thecosts    = cell_minus(thisproduct,output(isnap).states(:,iInputCol));
            
            for ir=1:1:steps+1, 
                if ~isempty(thecosts{ir}),  J = J + 0.5*thecosts{ir}'*thecosts{ir};  end
            end
            
            
            for idN = 1:1:steps
               
                term1 = kron(thisproduct{idN,1},eye(numpatterns));
                % I, N2', N3'N2', N4'N3'N2', ...
                for irow = idN+1:1:steps+1,

                    if ~isempty(term1),   d_dN{idN,irow} = term1*theSystem{irow,idN+1}';
                    else                  d_dN{idN,irow} = [];
                    end

                end
            end
            clear thisproduct
            
            
            
            dJ_dN = cell_plus(dJ_dN,  cell_matrix_product(d_dN,thecosts)  );
            clear thecosts
            
        end
    end
    
    dJ_dN = cell2mat(dJ_dN);
end
%% Cell-matrix operations:


%%
function [result] = cell_matrix_product(cellarray1,cellarray2)
    
    [ca1_n,ca1_m] = size(cellarray1);
    [ca2_n,ca2_m] = size(cellarray2);
    
    if ca1_m ~= ca2_n
        error('dimension_mismatch','number of columns in cellarray1 should match number of rows in cellarray2')
    end
    
    result = cell(ca1_n,ca2_m);
    
    for irow_ca1 = 1:1:ca1_n
        for icol_ca2 = 1:1:ca2_m
            common_ind = logical(~(cellfun('isempty',cellarray2(:,icol_ca2))).*~(cellfun('isempty',cellarray1(irow_ca1,:)))');
            temp = cellfun(@mtimes,cellarray1(irow_ca1,common_ind),cellarray2(common_ind,icol_ca2)','Un',0);
            
            if ~isempty(temp)
                result{irow_ca1,icol_ca2} = temp{1};
                for i=2:1:length(temp), result{irow_ca1,icol_ca2} = result{irow_ca1,icol_ca2}+ temp{i}; end
            end
        end
    end
    
end
function [result] = cell_minus(cellarray1,cellarray2)
    
    [ca1_n,ca1_m] = size(cellarray1);
    [ca2_n,ca2_m] = size(cellarray2);
    
    if (ca1_m ~= ca2_m || ca1_n ~= ca2_n)
        error('dimension_mismatch','number of columns in cellarray1 should match number of rows in cellarray2')
    end
    
    result = cell(ca1_n,ca1_m);
    result = cellfun(@minus,cellarray1,cellarray2,'Un',0);

end
function [result] = cell_plus(cellarray1,cellarray2)
    
    [ca1_n,ca1_m] = size(cellarray1);
    [ca2_n,ca2_m] = size(cellarray2);
    
    if (ca1_m ~= ca2_m || ca1_n ~= ca2_n)
        error(['dimension_mismatch','number of columns in cellarray1(',num2str(ca1_n),',',num2str(ca1_m),') should match number of rows in cellarray2(',num2str(ca2_n),',',num2str(ca2_m),')'])
    end
    
    result = cell(ca1_n,ca1_m);

    losind = (~cellfun('isempty',cellarray1)-~cellfun('isempty',cellarray2));
    result(losind == 0) = cellfun(@plus,cellarray1(losind == 0),cellarray2(losind == 0),'Un',0);
    result(losind < 0) = cellarray2(losind < 0);
    result(losind > 0) = cellarray1(losind > 0);
    
end
