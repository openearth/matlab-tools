function [diffs, sim1, sim2] = compare_maps(map1path,runid1,map2path,runid2)
   
    options.getrunsinfo.depthreshold = 0.01;                               % Depth threshold for reading from mapfile, nothing to-do with Delft3D
    options.getrunsinfo.time = 'flow';                                     
    
    options.getrunsinfo.bordermarginN = 1;
    options.getrunsinfo.bordermarginS = 1;
    options.getrunsinfo.bordermarginE = 1;
    options.getrunsinfo.bordermarginW = 1;
    
    options.getrunsinfo.velocitydata = 1;
    options.getrunsinfo.waterleveldata = 1;
        
    sim1 = getrunsinfo(map1path,runid1,options.getrunsinfo);
    sim2 = getrunsinfo(map2path,runid2,options.getrunsinfo);
    
    
    [loc_sim1,loc_sim2] = ismember(cellstr(datestr(sim1.times)),cellstr(datestr(sim2.times)));
    
    loc_sim1 = find(    loc_sim1);
    loc_sim2 = loc_sim2(loc_sim2~=0);
    
    diffs.m       = sim1.m;
    diffs.n       = sim1.n;
    diffs.refdate = sim1.refdate;
    diffs.times   = sim1.times(loc_sim1);
    
    diffs.dps     = sim1.vectors.dps(:,loc_sim1) - sim2.vectors.dps(:,loc_sim2);
    diffs.wlevel  = sim1.vectors.wlevel(:,loc_sim1) - sim2.vectors.wlevel(:,loc_sim2);
    diffs.vvel   = sim1.vectors.vvel(:,loc_sim1) - sim2.vectors.vvel(:,loc_sim2);
    diffs.uvel   = sim1.vectors.uvel(:,loc_sim1) - sim2.vectors.uvel(:,loc_sim2);
    
    
    figure
    plot( diffs.times,sqrt(1/(diffs.m*diffs.n)*sum(diffs.uvel.*diffs.uvel)), ...
          diffs.times,sqrt(1/(diffs.m*diffs.n)*sum(diffs.vvel.*diffs.vvel)))
    
    % A fair estimation of the errors is necessary. The difference between
    % each model run has been estimated for corresponding times. the times
    % inlcude spin up phase and morphodynamic phase. 
    %
    % Let us start by estimating the water depth change on every saving
    % step,
    tchange1 = sim1.vectors.dps(:,2:end) - sim1.vectors.dps(:,1:end-1);
    tchange2 = sim2.vectors.dps(:,2:end) - sim2.vectors.dps(:,1:end-1);
    % with this information available it is straight forward to estimate
    % the cumulative change in the system over one saving step. For this a
    % sumation of the absolute valu
    cumchange1 = sum(abs(tchange1));
    cumchange2 = sum(abs(tchange2));
    
    figure
       
end