function [ntrschied] = estdiff(obs,elmodel)
%% ESTDIFF estimates the differences between simulations and observations
% [ntrschied] = ESTDIFF(obs,elmodel). Both OBS and ELMODEL are structures.
% The structures shall have at least the following fields:
%
% obs.info.dps ........ Cell array in which the hour of the observation is
%                       stored in the first column. The corresponding
%                       observations shall be stored in the second column.
% obs.Operator ........ Double array in which the Observation Operator is
%                       stored. The observation operator maps the model
%                       results to the observation space. 
% obs.vectors.dps ..... Double array in which the observations are stored 
%                       as vectors in a columnwise fashion. The
%                       observations should be organized chronologically.
%
% In general, obs.vector.dps(:,i) = reshape(obs.info.dps{i,2},n*m,1)
%
% elmodel.info ........    Cell array in which the hour of the observation
%                          is stored in the first column. The corresponding
%                          observations shall be stored in the second
%                          column.
% elmodel.vectors.dps .    Double array in which the forecasts are stored
%                          as vectors in a columnwise fashion. The
%                          forecasts should be organized chronologically.
%
% In general, 
% elmodel.vector.dps(:,i) = reshape(elmodel.info.dps{i,2},n*m,1)

  cont = 1; ntrschied = [];
  for iTime=1:1:length(obs)        
    indRow = find(roundto(elmodel.times,6)==single(obs(iTime).times));

    if isempty(indRow), 
        %disp(['Warning: The observed time ',num2str(fix(obs(iTime).times)) ,' hr. was not modeled']); 
    else
        modelvalues = obs(iTime).operator*elmodel.vectors.dps(:,indRow);
        
        ntrschied.vectors(:,cont)  = modelvalues - obs(iTime).data(:,3);          % You want to know the norm? ntrschied.norm(cont) = norm(ntrschied.vectors(:,cont));
        ntrschied.operator{cont}   = obs(iTime).operator;                  % If an observation is skipped, then the operators of the obs struct are no longer usefull... we would need to know which operator to use. 
        
        ntrschied.matcov{cont}     = obs(iTime).matCov;
        ntrschied.modelIndex(cont) = indRow;
        cont = cont+1;
    end
  end
end