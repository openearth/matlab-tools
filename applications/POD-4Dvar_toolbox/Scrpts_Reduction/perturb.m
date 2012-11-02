function [] = perturb(option,spath,fpath,trimname,ptime,epsilon,delta)
% PERTURB(SPATH, FPATH, TRIMNAME, PTIME, EPSILON, DELTA). Perturb makes the
% necessary perturbations to the Delft3D model, that allows to estimate the 
% a directional derivative for the POD based model reduction. 
  
  if strcmp(option,'directional')
    
    disp('Preparing for directional derivative run...')
    disp(['Perturbing file:        ', [fpath,trimname]]);
    
    trim    = vs_use([fpath,trimname],'quiet');
    ctime = round(cell2mat(vs_get(trim,'map-info-series','ITMAPC','quiet')).*vs_get(trim,'map-const','TUNIT','quiet')*vs_get(trim,'map-const','DT','quiet'))/60;
    index = find(ctime == ptime);
    if isempty(index), error('MATLAB:perturb:InitialtimeError','The start time for this re-start simulation is not present in the map-file'); end    
    dps =  vs_get(trim,'map-sed-series',{index},'DPS','quiet');

    disp(['Epsilon = ', num2str(epsilon)])
    perturbdps = dps + epsilon.*delta;
    vs_put(trim,'map-sed-series',{index},'DPS',perturbdps);
  else
    error('MATLAB:runPrturbs:NotEnoughInputs','Not enough input arguments.'); 
  end
end