function [temp1,temp2] = evalcost(elmodel, obs, bgCov, bgTerm, patterns, sensitivities, parameters)                               
% EVALCOST estimates the sum of the square errors between Obs and ROM.
%
% J = EVALCOST(difference,observation_covariance,background_covariance,background_term)
% [J,dJ_dDa] = EVALCOST(difference,observation_covariance,background_covariance,background_term,operator,patterns,sensitivities)
  
       
    cont = 1; 
    ntrschied = [];
    
    for iTime=1:1:length(obs)        
        indRow = find(roundto(elmodel.times,6)==single(obs(iTime).times));

        if isempty(indRow), 
%            disp(['Warning: The observed time ',num2str(fix(obs(iTime).times)) ,' hr. was not modeled']); 
        else
            modelvalues = obs(iTime).operator*elmodel.vectors.dps(:,indRow);

            ntrschied.vectors(:,cont)  = modelvalues - obs(iTime).data(:,3);   % You want to know the norm? ntrschied.norm(cont) = norm(ntrschied.vectors(:,cont));
            ntrschied.operator{cont}   = obs(iTime).operator;                  % If an observation is skipped, then the operators of the obs struct are no longer usefull... we would need to know which operator to use. 

            ntrschied.matcov{cont}     = obs(iTime).matCov;
            ntrschied.modelIndex(cont) = indRow;
            cont = cont+1;
        end
    end
    
    bgCov = bgCov.*100;
    
    temp1 = 0.5*bgTerm'*(bgCov\bgTerm);
    temp2 = bgTerm'/bgCov;
    %term2 = 0;
    % Background term and Sum of Squared Errors
    for iTStep = 1:1:size(ntrschied.vectors,2)
     
      weightsmat = ntrschied.matcov{iTStep};
      temp1 = temp1 + 0.5*ntrschied.vectors(:,iTStep)'*(weightsmat\ntrschied.vectors(:,iTStep));
      temp2 = temp2 + (ntrschied.vectors(:,iTStep)'*(weightsmat\(ntrschied.operator{iTStep}*patterns)))*sensitivities{ntrschied.modelIndex(iTStep)};
      
    %  term2 = term2 + 0.5*ntrschied.vectors(:,iTStep)'*(weightsmat\ntrschied.vectors(:,iTStep));
    end
