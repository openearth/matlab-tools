function [models] = configureSnapshotRuns(varargin)
% [parModel] = configureSnapshotRuns(options, mbg, paramAcronym, paramDelta, parVal)
% Setup model run as the background run and modify only the relevant stuff

%if nargin ~= 6, error('MATLAB:configureSnapshotRuns:WrongInputNumber','Incorrect number of input arguments.'); end

models = struct([]);

options = varargin{1};
mbg = varargin{2};
devs = varargin{3};
npars = varargin{4};
pars = varargin{5};

tFolder = mbg.mainpath(1:end-11);

if strcmpi(options,'oneByOne'),             models = oneByOne('snapshot',tFolder,devs,mbg,pars,npars);
elseif strfind(options,'simultaneous'),     nsnaps = varargin{6}; models = simultaneous(tFolder,devs,mbg,pars,npars,nsnaps);
elseif strcmpi(options,'sensitivity'),      models = oneByOne('sensitivity',tFolder,devs,mbg,pars,npars);
else                                        error('Unknown type of perturbation generation configuration.');
end

end

%  ________________________________________________________________________
%%
function [parModel] = oneByOne(typeModel,folder,deviations,modelBG,params,npars)

modelCont = 1;

    for iParam = 1:1:npars
        for iDev = 1:1:length(deviations)

            %Here we perturb with the standard deviation of the parameter.
            if strcmp(typeModel,'snapshot'),
                parModel(modelCont) = modelBG;                
                
                if params(iParam).enforce_sigFig_in_value,  
                    params(iParam).delta(iPert) = roundto(params(iParam).std*deviations(iDev),ceil(abs(log10(params(iParam).significant_figure)))); 
                    deviations(iDev) = params(iParam).delta(iPert)/params(iParam).std;
                else
                    params(iParam).delta(iDev) = params(iParam).std*deviations(iDev);
                end
        
                parVal = params(iParam).bgValue + params(iParam).delta(iDev);
                
                parModel(modelCont).mainpath = [folder,'Snapshot_'   ,num2str(modelCont,'%.2i'),filesep];
                parModel(modelCont).configP(iParam) = params(iParam).delta(iDev);                          % Perturbation configuration
                parModel(modelCont) = setfield(parModel(modelCont),params(iParam).filext,params(iParam).acronym,parVal);

            % Here we perturb with the significant figure.
            elseif strcmp(typeModel,'sensitivity'),
                
                
                parModel(iParam,iDev) = modelBG;
                
                params(iParam).delta(iDev) = params(iParam).significant_figure * deviations(iDev);
                parVal = params(iParam).bgValue + params(iParam).delta(iDev);
                
                parModel(iParam,iDev).mainpath = [folder,'Sensitivity',params(iParam).acronym,filesep,'Val_',num2str(parVal),filesep];
                
                %disp([num2str(iParam),'  ',num2str(iDev),'  ',folder,'Sensitivity',params(iParam).acronym,filesep,'Val_',num2str(parVal),filesep])
                parModel(iParam,iDev).configP(iParam) = params(iParam).delta(iDev);                 %Perturbation configuration
                parModel(iParam,iDev) = setfield(parModel(iParam,iDev),params(iParam).filext,params(iParam).acronym,parVal);

            end
            modelCont = modelCont + 1;
            
        end
    end   
end

%  ________________________________________________________________________
%%
function [parModel] = simultaneous(folder,deviations,modelBG,params,npars,nsnaps)

modelCont = 1;

for iPert = 1:1:nsnaps
    parModel(modelCont) = modelBG;
    for iParam = 1:1:npars,
        
        if params(iParam).enforce_sigFig_in_value,  
            params(iParam).delta(iPert) = roundto(params(iParam).std*deviations(iParam,iPert),ceil(abs(log10(params(iParam).significant_figure)))); 
            deviations(iParam,iPert) = params(iParam).delta(iPert)/params(iParam).std;
        else
            params(iParam).delta(iPert) = params(iParam).std*deviations(iParam,iPert);
        end
        
        parVal = params(iParam).bgValue + params(iParam).delta(iPert);
        
        parModel(modelCont).configP(iParam) = params(iParam).delta(iPert);
        parModel(modelCont) =                 setfield(parModel(modelCont),params(iParam).filext,params(iParam).acronym,parVal);
        parModel(modelCont).mainpath =        [folder,'Snapshot_'   ,num2str(modelCont,'%.2i'),filesep];
    end
    modelCont = modelCont + 1;
end

end