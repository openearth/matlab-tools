function [] = replace_state(spath,fpath,sourcetime,perturbtime)
% REPLACE_STATE(SPATH, FPATH, TRIMNAME, SOURCETIME, PERTURBTIME). Perturb
% makes the necessary perturbations to the Delft3D model, that allows to
% estimate the a directional derivative for the POD based model reduction. 
    
    disp(['Loading file:        ', spath]);
    strim    = vs_use(spath,'quiet');
    stime = round(cell2mat(vs_get(strim,'map-info-series','ITMAPC','quiet')).*vs_get(strim,'map-const','TUNIT','quiet')*vs_get(strim,'map-const','DT','quiet'))/60;
    index = find(stime == sourcetime);
    if isempty(index), error('MATLAB:perturb:InitialtimeError','The time in the source file was not found'); end
    dps2put =  vs_get(strim,'map-sed-series',{index},'DPS','quiet');
    
    disp(['Loading file:        ', fpath]);
    ftrim    = vs_use(fpath,'quiet');
    ftime = round(cell2mat(vs_get(ftrim,'map-info-series','ITMAPC','quiet')).*vs_get(ftrim,'map-const','TUNIT','quiet')*vs_get(ftrim,'map-const','DT','quiet'))/60;
    index = find(ftime == perturbtime);
    if isempty(index), error('MATLAB:perturb:InitialtimeError','The time for perturbation was not found.'); end    
    vs_put(ftrim,'map-sed-series',{index},'DPS',dps2put);
  
end