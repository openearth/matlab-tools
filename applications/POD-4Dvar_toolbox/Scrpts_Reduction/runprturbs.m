function [] = runprturbs(varargin)

    % How do you want to perturb the model
    perturbtype = varargin{1};

    if strcmpi('sensitivity',perturbtype)

        if nargin ~= 5, error('MATLAB:runPrturbs:InputsError','Wrong number of input arguments, must be 5.'); end

        Model             = varargin{2};
        Model.setuppath   = varargin{3};
        contStart         = varargin{4};
        numNodesInCluster = varargin{5};

    elseif strcmpi('directional',perturbtype)

        if nargin ~= 7, error('MATLAB:runPrturbs:InputsError','Wrong number of input arguments, must be 7.'); end
    
        Model             = varargin{2};
        Model.setuppath   = varargin{5};
        contStart         = varargin{6};
        numNodesInCluster = varargin{7};
    
        prturb = varargin{3};
        epsilon = varargin{4};
   
        mkdir([Model.mainpath]);
        save([Model.mainpath,'pattern.mat'],'prturb');
    end

    disp([char(10), 'Initializing perturbation runs'])


    while( ((contStart-1)*Model.mdf.mapInterval) < Model.Totalrun ) 
        % mapInterval se podria convertir en un parametro dependiente del
        % tiempo. Si se define como un vector y el condicional se hace
        % sobre suma acumulada de tiempos guardas en el vector.  

        Model.finalpath = [Model.mainpath,'Step',num2str(contStart,'%3.3i'),filesep];
        mkdir([Model.finalpath]);

        disp([char(10),'Source of Restart File: ',Model.setuppath ,'trim-', char(Model.runID),'.dat'])
        copyfile([Model.setuppath ,'trim-', char(Model.runID),'.dat'], [Model.finalpath, 'trim-',char(Model.runID),'0.dat']);    
        copyfile([Model.setuppath ,'trim-',char(Model.runID),'.def'],  [Model.finalpath, 'trim-',char(Model.runID),'0.def']);
        copyd3dfiles(Model.setuppath,Model.finalpath);


        Model.mdf.Tstart = Model.mor.coldstartSpinup + (contStart-1)*(Model.mdf.mapInterval);    % Read current starting time
        Model.mdf.Tstop  = Model.mdf.Tstart + Model.mor.restartSpinup + Model.mdf.mapInterval;   % Setup Stop time


     % -> Set the parameters that are a bit different
        Model.mdf.Flmap  = [num2str(Model.mdf.Tstop) ,' ',num2str(Model.mdf.mapInterval)     ,'  ',num2str(Model.mdf.Tstop)]; ...  Saving map files
        Model.mdf.Flpp   = [num2str(Model.mdf.Tstart),' ',num2str(Model.mdw.COMWriteInterval),'  ',num2str(Model.mdf.Tstop)]; ...  Communication files.
        Model.mdf.Restid = ['trim-',Model.runID,'0'];
        Model.mor.MorStt = Model.mor.restartSpinup;

     % Setup up the MDF file according to the necessary configuration
        disp(char(10));
        modmdf(Model.finalpath,Model.mdf);

     % Setup up the MOR file according to the necessary configuration
        disp(char(10));
        modmor(Model.finalpath,Model.mor);

     % Setup up the MDW file according to the necessary configuration
        disp(char(10));
        modmdw(Model.finalpath,Model.mdw);

     % Setup up the BCC file according to the necessary configuration
        modbcc([Model.finalpath,Model.bcc.runID],Model.mdf.Tstart,Model.mdf.Tstop);

     % Perturb the stat vector with the pattern
        if strcmpi('directional',perturbtype), 
            perturb(perturbtype,Model.setuppath,Model.finalpath,['trim-', char(Model.runID),'0'],Model.mdf.Tstart,epsilon,prturb); 
        end

     % Let's run the D3D
        rund3d(Model,numNodesInCluster)
        contStart = contStart+1;

    end